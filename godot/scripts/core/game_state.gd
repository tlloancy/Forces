class_name GameState
extends RefCounted

signal phase_changed(phase: GameConstants.GamePhase)
signal round_advanced(round_number: int)
signal piece_moved(piece_id: int, from_sector: String, to_sector: String)

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
		power_tokens[camp] = 0
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


func _add_piece(camp: GameConstants.Camp, type: GameConstants.PieceType, sector: String, reserve: bool) -> void:
	pieces.append(PieceInstance.new(_next_piece_id, camp, type, sector, reserve))
	_next_piece_id += 1


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


func try_move_piece(piece: PieceInstance, to_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Pas en phase de planification."
	if not is_alive(piece.camp):
		return "Camp éliminé."
	if has_piece_moved(piece.id):
		return "Pièce déjà déplacée ce tour."
	var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece.type, null)
	if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
		return "Type de pièce inconnu."
	var stats: Dictionary = stats_variant as Dictionary
	var max_move: int = int(stats.get("max_move", 1))
	if not BoardGraph.has_sector(piece.sector_id):
		return "Déplacement mer/air non implémenté."
	var dests := BoardGraph.land_destinations(piece.sector_id, max_move)
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


func advance_round() -> void:
	round_number += 1
	_clear_round_orders()
	round_advanced.emit(round_number)
