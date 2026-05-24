class_name GameState
extends RefCounted

signal phase_changed(phase: GameConstants.GamePhase)
signal round_advanced(round_number: int)
signal piece_moved(piece_id: int, from_sector: String, to_sector: String)
signal power_changed(camp: GameConstants.Camp, amount: int)

var phase: GameConstants.GamePhase = GameConstants.GamePhase.MENU
var round_number: int = 1
var human_camp: GameConstants.Camp = GameConstants.Camp.GREEN

var alive: Dictionary = {
	GameConstants.Camp.GREEN: true,
	GameConstants.Camp.BLUE: true,
	GameConstants.Camp.RED: true,
	GameConstants.Camp.YELLOW: true,
}
var power_tokens: Dictionary = {
	GameConstants.Camp.GREEN: 0,
	GameConstants.Camp.BLUE: 0,
	GameConstants.Camp.RED: 0,
	GameConstants.Camp.YELLOW: 0,
}
var pieces: Array[PieceInstance] = []
var pending_orders: Array[GameOrder] = []
var orders_by_camp: Dictionary = {}
var pieces_moved_this_round: Array[int] = []
var _next_piece_id: int = 1


func reset_match() -> void:
	round_number = 1
	_clear_round_orders()
	for camp: GameConstants.Camp in alive:
		alive[camp] = true
		power_tokens[camp] = GameConstants.STARTING_POWER
	pieces.clear()
	_next_piece_id = 1
	_spawn_starting_forces()
	set_phase(GameConstants.GamePhase.PLANNING)


func _clear_round_orders() -> void:
	orders_by_camp.clear()
	pieces_moved_this_round.clear()
	pending_orders.clear()


func _spawn_starting_forces() -> void:
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		var hq: String = BoardCatalog.hq_for_camp(camp)
		for _i in 2:
			_add_piece(camp, GameConstants.PieceType.SOLDIER, hq, false)
			_add_piece(camp, GameConstants.PieceType.RAIDER, hq, false)
			_add_piece(camp, GameConstants.PieceType.HUNTER, hq, false)
			_add_piece(camp, GameConstants.PieceType.CRUISER, hq, false)


func _add_piece(camp: GameConstants.Camp, type: GameConstants.PieceType, sector: String, reserve: bool) -> PieceInstance:
	var piece := PieceInstance.new(_next_piece_id, camp, type, sector, reserve)
	pieces.append(piece)
	_next_piece_id += 1
	return piece


func camp_power(camp: GameConstants.Camp) -> int:
	return int(power_tokens.get(camp, 0))


func reserve_pieces(camp: GameConstants.Camp) -> Array[PieceInstance]:
	var result: Array[PieceInstance] = []
	for p: PieceInstance in pieces:
		if p.camp == camp and p.in_reserve:
			result.append(p)
	return result


func is_alive(camp: GameConstants.Camp) -> bool:
	return bool(alive.get(camp, false))


func set_phase(new_phase: GameConstants.GamePhase) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	phase_changed.emit(phase)


func camp_orders_used(camp: GameConstants.Camp) -> int:
	return int(orders_by_camp.get(camp, 0))


func has_piece_moved(piece_id: int) -> bool:
	return piece_id in pieces_moved_this_round


func queue_order(order: GameOrder) -> bool:
	var camp: GameConstants.Camp = order.camp
	if camp_orders_used(camp) >= GameConstants.MAX_ORDERS_PER_ROUND:
		return false
	pending_orders.append(order)
	orders_by_camp[camp] = camp_orders_used(camp) + 1
	return true


func find_piece(piece_id: int) -> PieceInstance:
	for p in pieces:
		if p.id == piece_id:
			return p
	return null


func pieces_on_sector(sector_id: String) -> Array[PieceInstance]:
	var result: Array[PieceInstance] = []
	for p in pieces:
		if not p.in_reserve and p.sector_id == sector_id:
			result.append(p)
	return result


func human_pieces_on_sector(sector_id: String) -> Array[PieceInstance]:
	var result: Array[PieceInstance] = []
	for p in pieces_on_sector(sector_id):
		if p.camp == human_camp:
			result.append(p)
	return result


func _piece_stats(piece: PieceInstance) -> Dictionary:
	var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece.type, null)
	if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
		return {}
	return stats_variant as Dictionary


func _sector_valid_for_piece(piece: PieceInstance) -> bool:
	match GameConstants.piece_movement_domain(piece.type):
		GameConstants.MovementDomain.LAND:
			return BoardGraph.has_land_sector(piece.sector_id)
		GameConstants.MovementDomain.SEA:
			return BoardGraph.has_sea_sector(piece.sector_id)
		GameConstants.MovementDomain.AIR:
			return BoardGraph.has_air_sector(piece.sector_id)
		_:
			return false


func destinations_for(piece: PieceInstance) -> PackedStringArray:
	var stats: Dictionary = _piece_stats(piece)
	if stats.is_empty():
		return PackedStringArray()
	var max_move: int = int(stats.get("max_move", 1))
	return BoardGraph.piece_destinations(piece.type, piece.sector_id, max_move)


func try_buy_to_reserve(camp: GameConstants.Camp, piece_type: GameConstants.PieceType) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Pas en phase de planification."
	if not is_alive(camp):
		return "Camp éliminé."
	if not GameConstants.is_basic_buy(piece_type):
		return "Recrutement Power : 4 unités de base seulement."
	var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece_type, null)
	if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
		return "Type inconnu."
	var stats: Dictionary = stats_variant as Dictionary
	var cost: int = int(stats.get("power_cost", 0))
	if camp_power(camp) < cost:
		return "Power insuffisant (%d requis)." % cost
	var hq: String = BoardCatalog.hq_for_camp(camp)
	power_tokens[camp] = camp_power(camp) - cost
	power_changed.emit(camp, camp_power(camp))
	_add_piece(camp, piece_type, hq, true)
	var order := GameOrder.new(GameOrder.Kind.BUY, camp)
	order.piece_type = piece_type
	if not queue_order(order):
		power_tokens[camp] = camp_power(camp) + cost
		pieces.pop_back()
		_next_piece_id -= 1
		power_changed.emit(camp, camp_power(camp))
		return "Nombre max d'ordres atteint."
	return ""


func try_deploy_from_reserve(piece: PieceInstance, to_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Pas en phase de planification."
	if not piece.in_reserve:
		return "Pièce déjà sur le plateau."
	if has_piece_moved(piece.id):
		return "Pièce déjà activée ce tour."
	var hq: String = BoardCatalog.hq_for_camp(piece.camp)
	if to_sector != hq:
		return "Déploiement depuis la réserve uniquement sur votre QG (%s)." % hq
	if not pieces_on_sector(to_sector).is_empty():
		for p in pieces_on_sector(to_sector):
			if p.camp == piece.camp:
				continue
			return "QG occupé par l'ennemi."
	piece.in_reserve = false
	piece.sector_id = to_sector
	pieces_moved_this_round.append(piece.id)
	var order := GameOrder.new(GameOrder.Kind.DEPLOY_FROM_RESERVE, piece.camp)
	order.piece_type = piece.type
	order.to_sector = to_sector
	if not queue_order(order):
		piece.in_reserve = true
		pieces_moved_this_round.erase(piece.id)
		return "Nombre max d'ordres atteint."
	piece_moved.emit(piece.id, "réserve", to_sector)
	return ""


func try_move_piece(piece: PieceInstance, to_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Pas en phase de planification."
	if not is_alive(piece.camp):
		return "Camp éliminé."
	if piece.in_reserve:
		return "Pièce en réserve — déployez-la d'abord."
	if has_piece_moved(piece.id):
		return "Pièce déjà déplacée ce tour."
	if not _sector_valid_for_piece(piece):
		return "Secteur incompatible avec le mode de déplacement."
	var dests := destinations_for(piece)
	if to_sector not in dests:
		return "Destination invalide pour %s." % piece.label()
	var from: String = piece.sector_id
	piece.sector_id = to_sector
	pieces_moved_this_round.append(piece.id)
	var order := GameOrder.new(GameOrder.Kind.MOVE, piece.camp)
	order.piece_type = piece.type
	order.from_sector = from
	order.to_sector = to_sector
	if not queue_order(order):
		piece.sector_id = from
		pieces_moved_this_round.erase(piece.id)
		return "Nombre max d'ordres atteint pour ce camp."
	piece_moved.emit(piece.id, from, to_sector)
	return ""


func try_move_human_piece(piece: PieceInstance, to_sector: String) -> String:
	if piece.camp != human_camp:
		return "Ce n'est pas votre pièce."
	return try_move_piece(piece, to_sector)


func try_buy_human(piece_type: GameConstants.PieceType) -> String:
	return try_buy_to_reserve(human_camp, piece_type)


func try_exchange_to_reserve(camp: GameConstants.Camp, result_type: GameConstants.PieceType) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Pas en phase de planification."
	if not is_alive(camp):
		return "Camp éliminé."
	var recipe: Dictionary = GameConstants.exchange_recipe(result_type)
	if recipe.is_empty():
		return "Échange inconnu."
	var from_type: GameConstants.PieceType = recipe["from"]
	var need: int = int(recipe["count"])
	if _count_reserve(camp, from_type) < need:
		return "Réserve insuffisante (%d × %s requis)." % [need, GameConstants.piece_type_label(from_type)]
	var hq: String = BoardCatalog.hq_for_camp(camp)
	if not _consume_reserve(camp, from_type, need):
		return "Échange impossible."
	_add_piece(camp, result_type, hq, true)
	var order := GameOrder.new(GameOrder.Kind.EXCHANGE, camp)
	order.piece_type = result_type
	order.exchange_result = result_type
	if not queue_order(order):
		for _i in range(need):
			_add_piece(camp, from_type, hq, true)
		pieces.pop_back()
		_next_piece_id -= 1
		return "Nombre max d'ordres atteint."
	return ""


func try_exchange_human(result_type: GameConstants.PieceType) -> String:
	return try_exchange_to_reserve(human_camp, result_type)


func _count_reserve(camp: GameConstants.Camp, piece_type: GameConstants.PieceType) -> int:
	var n: int = 0
	for p: PieceInstance in pieces:
		if p.camp == camp and p.in_reserve and p.type == piece_type:
			n += 1
	return n


func _consume_reserve(camp: GameConstants.Camp, piece_type: GameConstants.PieceType, count: int) -> bool:
	var removed: int = 0
	for i in range(pieces.size() - 1, -1, -1):
		var p: PieceInstance = pieces[i]
		if p.camp != camp or not p.in_reserve or p.type != piece_type:
			continue
		pieces.remove_at(i)
		removed += 1
		if removed >= count:
			return true
	return false


func try_deploy_human(piece: PieceInstance, to_sector: String) -> String:
	if piece.camp != human_camp:
		return "Ce n'est pas votre pièce."
	return try_deploy_from_reserve(piece, to_sector)


func end_planning_round() -> Array[String]:
	var logs: Array[String] = []
	for order: GameOrder in pending_orders:
		logs.append("  · " + order.describe())
	logs.append_array(BattleResolver.resolve_all_conflicts(self))
	_check_flag_captures(logs)
	advance_round()
	set_phase(GameConstants.GamePhase.PLANNING)
	return logs


func _check_flag_captures(logs: Array[String]) -> void:
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if not is_alive(camp):
			continue
		var hq: String = BoardCatalog.hq_for_camp(camp)
		for p in pieces_on_sector(hq):
			if p.camp != camp and p.type != GameConstants.PieceType.HBOMB:
				alive[camp] = false
				logs.append("%s éliminé — drapeau menacé sur %s" % [
					GameConstants.camp_to_string(camp),
					hq,
				])
				break


func _apply_round_income() -> void:
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if not is_alive(camp):
			continue
		power_tokens[camp] = camp_power(camp) + GameConstants.POWER_PER_ROUND
		power_changed.emit(camp, camp_power(camp))


func advance_round() -> void:
	round_number += 1
	_apply_round_income()
	_clear_round_orders()
	round_advanced.emit(round_number)
