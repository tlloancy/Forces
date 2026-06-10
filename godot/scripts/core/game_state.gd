class_name GameState
extends RefCounted

const RoundResolverScript = preload("res://scripts/core/round_resolver.gd")

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
## Début de manche (avant résolution) : piece_id → { sector_id, in_reserve } — rebonds égalité.
var round_board_snapshot: Dictionary = {}
var _next_piece_id: int = 1
## 0 = utilise GameConstants.PLANNING_TIMER_SECONDS (tests peuvent réduire).
var match_timer_seconds: int = 0


func planning_time_limit() -> int:
	if match_timer_seconds > 0:
		return match_timer_seconds
	return GameConstants.PLANNING_TIMER_SECONDS


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


func survivors_count() -> int:
	var n: int = 0
	for camp: GameConstants.Camp in alive:
		if is_alive(camp):
			n += 1
	return n


func apply_planning_timeout(logs: Array[String]) -> void:
	for camp: GameConstants.Camp in alive:
		alive[camp] = false
	logs.append(GameOrder.feed_timeout())
	set_phase(GameConstants.GamePhase.GAME_OVER)


func set_phase(new_phase: GameConstants.GamePhase) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	phase_changed.emit(phase)


func camp_orders_used(camp: GameConstants.Camp) -> int:
	return int(orders_by_camp.get(camp, 0))


func orders_for_camp(camp: GameConstants.Camp) -> Array[GameOrder]:
	var result: Array[GameOrder] = []
	for order: GameOrder in pending_orders:
		if order.camp == camp:
			result.append(order)
	return result


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


## Présence affichée en planification (ordres de mouvement / déploiement pris en compte).
func sector_presence_counts(sector_id: String) -> Dictionary:
	var by_camp: Dictionary = {}
	for p: PieceInstance in pieces_on_sector(sector_id):
		_presence_inc(by_camp, p.camp, p.type, 1)
	if phase != GameConstants.GamePhase.PLANNING:
		return by_camp
	for order: GameOrder in pending_orders:
		match order.kind:
			GameOrder.Kind.MOVE:
				if order.from_sector == sector_id:
					var piece: PieceInstance = find_piece(order.piece_id)
					if piece != null:
						_presence_dec(by_camp, piece.camp, piece.type, 1)
				if order.to_sector == sector_id:
					_presence_inc(by_camp, order.camp, order.piece_type, 1)
			GameOrder.Kind.DEPLOY_FROM_RESERVE:
				if order.to_sector == sector_id:
					_presence_inc(by_camp, order.camp, order.piece_type, 1)
	return by_camp


func planning_pieces_on_sector(sector_id: String) -> Array[PieceInstance]:
	var leaving: Dictionary = {}
	for order: GameOrder in pending_orders:
		if order.kind == GameOrder.Kind.MOVE and order.from_sector == sector_id:
			leaving[order.piece_id] = true
	var result: Array[PieceInstance] = []
	for p: PieceInstance in pieces_on_sector(sector_id):
		if not leaving.has(p.id):
			result.append(p)
	return result


static func _presence_inc(by_camp: Dictionary, camp: GameConstants.Camp, ptype: GameConstants.PieceType, n: int) -> void:
	if not by_camp.has(camp):
		by_camp[camp] = {}
	var counts: Dictionary = by_camp[camp] as Dictionary
	var key: int = int(ptype)
	counts[key] = int(counts.get(key, 0)) + n


static func _presence_dec(by_camp: Dictionary, camp: GameConstants.Camp, ptype: GameConstants.PieceType, n: int) -> void:
	if not by_camp.has(camp):
		return
	var counts: Dictionary = by_camp[camp] as Dictionary
	var key: int = int(ptype)
	var v: int = int(counts.get(key, 0)) - n
	if v <= 0:
		counts.erase(key)
	else:
		counts[key] = v
	if counts.is_empty():
		by_camp.erase(camp)


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
	if piece.type == GameConstants.PieceType.HBOMB:
		return BoardGraph.has_sector(piece.sector_id)
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
	if piece.type == GameConstants.PieceType.HBOMB:
		return _hbomb_strike_targets(piece)
	return BoardGraph.piece_destinations(piece.type, piece.sector_id, 0)


func human_pending_move_targets() -> Dictionary:
	var out: Dictionary = {}
	for order: GameOrder in pending_orders:
		if order.camp != human_camp or order.kind != GameOrder.Kind.MOVE:
			continue
		if order.to_sector != "":
			out[order.to_sector] = true
	return out


func _hbomb_strike_targets(hbomb: PieceInstance) -> PackedStringArray:
	var result: Array[String] = []
	for sector_id: String in BoardCatalog.SECTOR_IDS:
		if sector_id == hbomb.sector_id:
			continue
		result.append(sector_id)
	return PackedStringArray(result)


func hbomb_on_board(camp: GameConstants.Camp) -> PieceInstance:
	for p: PieceInstance in pieces:
		if p.camp == camp and p.type == GameConstants.PieceType.HBOMB and not p.in_reserve:
			return p
	return null


func reserve_force_available(camp: GameConstants.Camp) -> int:
	var total: int = 0
	for p: PieceInstance in reserve_pieces(camp):
		total += GameConstants.reserve_force_value(p.type)
	return total


func hbomb_fusion_force_available(camp: GameConstants.Camp, fusion_sector: String) -> int:
	var total: int = reserve_force_available(camp) + camp_power(camp)
	if fusion_sector != "":
		for p: PieceInstance in pieces_on_sector(fusion_sector):
			if p.camp == camp and not p.in_reserve and p.type != GameConstants.PieceType.HBOMB:
				total += GameConstants.reserve_force_value(p.type)
	return total


func try_place_hbomb(camp: GameConstants.Camp, board_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	if not is_alive(camp):
		return "Camp eliminated."
	if hbomb_on_board(camp) != null or _has_pending_hbomb_place(camp):
		return "An H-bomb is already in play."
	if not BoardGraph.has_sector(board_sector):
		return "Invalid sector."
	var available: int = hbomb_fusion_force_available(camp, board_sector)
	if available < GameConstants.HBOMB_FUSION_FORCE:
		return "Insufficient fusion (%d F required, %d on %s)." % [
			GameConstants.HBOMB_FUSION_FORCE,
			available,
			BoardCatalog.sector_short_label(board_sector),
		]
	var consumed: int = _consume_hbomb_fusion_budget(camp, board_sector, GameConstants.HBOMB_FUSION_FORCE)
	if consumed < GameConstants.HBOMB_FUSION_FORCE:
		return "H-bomb fusion failed (%d/%d F consumed)." % [consumed, GameConstants.HBOMB_FUSION_FORCE]
	var order := GameOrder.new(GameOrder.Kind.HBOMB_PLACE, camp)
	order.to_sector = board_sector
	if not queue_order(order):
		return "Max orders reached."
	return ""


func try_hbomb_strike(camp: GameConstants.Camp, target_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	var hbomb: PieceInstance = hbomb_on_board(camp)
	if hbomb == null:
		return "No H-bomb on the board."
	if target_sector == hbomb.sector_id:
		return "Invalid target."
	if not BoardGraph.has_sector(target_sector):
		return "Unknown sector."
	var from_sector: String = hbomb.sector_id
	var order := GameOrder.new(GameOrder.Kind.HBOMB_STRIKE, camp)
	order.from_sector = from_sector
	order.to_sector = target_sector
	if not queue_order(order):
		return "Max orders reached."
	order.piece_id = hbomb.id
	pieces_moved_this_round.append(hbomb.id)
	return ""


func try_place_hbomb_human(board_sector: String) -> String:
	return try_place_hbomb(human_camp, board_sector)


func try_hbomb_strike_human(target_sector: String) -> String:
	return try_hbomb_strike(human_camp, target_sector)


func _consume_hbomb_fusion_budget(camp: GameConstants.Camp, fusion_sector: String, need: int) -> int:
	var consumed: int = 0
	consumed += _consume_force_from_sector(camp, fusion_sector, need - consumed)
	if consumed >= need:
		return consumed
	consumed += _consume_reserve_force_budget(camp, need - consumed)
	if consumed >= need:
		return consumed
	while consumed < need and camp_power(camp) > 0:
		power_tokens[camp] = camp_power(camp) - 1
		power_changed.emit(camp, camp_power(camp))
		consumed += 1
	return consumed


func _consume_force_from_sector(camp: GameConstants.Camp, sector_id: String, need: int) -> int:
	var types: Array[GameConstants.PieceType] = _fusion_consume_priority()
	var consumed: int = 0
	while consumed < need:
		var removed: bool = false
		for t: GameConstants.PieceType in types:
			for i in range(pieces.size() - 1, -1, -1):
				var p: PieceInstance = pieces[i]
				if p.camp != camp or p.sector_id != sector_id or p.in_reserve or p.type != t:
					continue
				if p.type == GameConstants.PieceType.HBOMB:
					continue
				pieces.remove_at(i)
				consumed += GameConstants.reserve_force_value(t)
				removed = true
				break
			if removed:
				break
		if not removed:
			break
	return consumed


func _consume_reserve_force_budget(camp: GameConstants.Camp, need: int) -> int:
	var types: Array[GameConstants.PieceType] = _fusion_consume_priority()
	var consumed: int = 0
	while consumed < need:
		var removed: bool = false
		for t: GameConstants.PieceType in types:
			if _consume_reserve(camp, t, 1):
				consumed += GameConstants.reserve_force_value(t)
				removed = true
				break
		if not removed:
			break
	return consumed


static func _fusion_consume_priority() -> Array[GameConstants.PieceType]:
	return [
		GameConstants.PieceType.DESTROYER,
		GameConstants.PieceType.BOMBER,
		GameConstants.PieceType.FIGHTER,
		GameConstants.PieceType.COMMANDO,
		GameConstants.PieceType.CRUISER,
		GameConstants.PieceType.HUNTER,
		GameConstants.PieceType.RAIDER,
		GameConstants.PieceType.SOLDIER,
	]


func _remove_piece_by_id(piece_id: int) -> void:
	for i in range(pieces.size() - 1, -1, -1):
		if pieces[i].id == piece_id:
			pieces.remove_at(i)
			return


func try_buy_to_reserve(camp: GameConstants.Camp, piece_type: GameConstants.PieceType) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	if not is_alive(camp):
		return "Camp eliminated."
	if not GameConstants.is_basic_buy(piece_type):
		return "Power recruitment: basic units only."
	var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece_type, null)
	if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
		return "Unknown type."
	var stats: Dictionary = stats_variant as Dictionary
	var cost: int = int(stats.get("power_cost", 0))
	if camp_power(camp) < cost:
		return "Not enough Power (%d required)." % cost
	var hq: String = BoardCatalog.hq_for_camp(camp)
	power_tokens[camp] = camp_power(camp) - cost
	power_changed.emit(camp, camp_power(camp))
	_add_piece(camp, piece_type, hq, true)
	var order := GameOrder.new(GameOrder.Kind.BUY, camp)
	order.piece_type = piece_type
	order.piece_id = pieces[pieces.size() - 1].id
	if not queue_order(order):
		power_tokens[camp] = camp_power(camp) + cost
		pieces.pop_back()
		_next_piece_id -= 1
		power_changed.emit(camp, camp_power(camp))
		return "Max orders reached."
	return ""


func try_deploy_from_reserve(piece: PieceInstance, to_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	if not piece.in_reserve:
		return "Piece already on the board."
	if has_piece_moved(piece.id):
		return "Piece already activated this turn."
	var hq: String = BoardCatalog.hq_for_camp(piece.camp)
	if to_sector != hq:
		return "Deploy from reserve only on your HQ (%s)." % hq
	if not pieces_on_sector(to_sector).is_empty():
		for p in pieces_on_sector(to_sector):
			if p.camp == piece.camp:
				continue
			return "HQ occupied by enemy."
	pieces_moved_this_round.append(piece.id)
	var order := GameOrder.new(GameOrder.Kind.DEPLOY_FROM_RESERVE, piece.camp)
	order.piece_id = piece.id
	order.piece_type = piece.type
	order.to_sector = to_sector
	if not queue_order(order):
		pieces_moved_this_round.erase(piece.id)
		return "Max orders reached."
	return ""


func try_move_piece(piece: PieceInstance, to_sector: String) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	if not is_alive(piece.camp):
		return "Camp eliminated."
	if piece.type == GameConstants.PieceType.HBOMB:
		return try_hbomb_strike(piece.camp, to_sector)
	if piece.in_reserve:
		return "Piece in reserve — deploy it first."
	if has_piece_moved(piece.id):
		return "Piece already moved this turn."
	if not _sector_valid_for_piece(piece):
		return "Sector incompatible with movement mode."
	var dests := destinations_for(piece)
	if to_sector not in dests:
		return "Invalid destination for %s." % piece.label()
	var from: String = piece.sector_id
	pieces_moved_this_round.append(piece.id)
	var order := GameOrder.new(GameOrder.Kind.MOVE, piece.camp)
	order.piece_id = piece.id
	order.piece_type = piece.type
	order.from_sector = from
	order.to_sector = to_sector
	if not queue_order(order):
		pieces_moved_this_round.erase(piece.id)
		return "Max orders reached for this camp."
	return ""


func try_move_human_piece(piece: PieceInstance, to_sector: String) -> String:
	if piece.camp != human_camp:
		return "Not your piece."
	return try_move_piece(piece, to_sector)


func try_buy_human(piece_type: GameConstants.PieceType) -> String:
	return try_buy_to_reserve(human_camp, piece_type)


func try_exchange_to_reserve(camp: GameConstants.Camp, result_type: GameConstants.PieceType) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	if not is_alive(camp):
		return "Camp eliminated."
	var recipe: Dictionary = GameConstants.exchange_recipe(result_type)
	if recipe.is_empty():
		return "Unknown exchange."
	var from_type: GameConstants.PieceType = recipe["from"]
	var need: int = int(recipe["count"])
	if _count_reserve(camp, from_type) < need:
		return "Insufficient reserve (%d × %s required)." % [need, GameConstants.piece_type_label(from_type)]
	var hq: String = BoardCatalog.hq_for_camp(camp)
	if not _consume_reserve(camp, from_type, need):
		return "Exchange failed."
	_add_piece(camp, result_type, hq, true)
	var order := GameOrder.new(GameOrder.Kind.EXCHANGE, camp)
	order.piece_type = result_type
	order.exchange_result = result_type
	order.piece_id = pieces[pieces.size() - 1].id
	if not queue_order(order):
		for _i in range(need):
			_add_piece(camp, from_type, hq, true)
		pieces.pop_back()
		_next_piece_id -= 1
		return "Max orders reached."
	return ""


func try_exchange_human(result_type: GameConstants.PieceType) -> String:
	return try_exchange_to_reserve(human_camp, result_type)


func try_cancel_last_order(camp: GameConstants.Camp) -> String:
	if phase != GameConstants.GamePhase.PLANNING:
		return "✕"
	if camp_orders_used(camp) <= 0:
		return "∅"
	var order: GameOrder = _pop_last_order_for_camp(camp)
	if order == null:
		return "∅"
	match order.kind:
		GameOrder.Kind.MOVE, GameOrder.Kind.DEPLOY_FROM_RESERVE, GameOrder.Kind.HBOMB_STRIKE:
			pieces_moved_this_round.erase(order.piece_id)
		GameOrder.Kind.BUY:
			var stats: Dictionary = GameConstants.PIECE_STATS.get(order.piece_type, {}) as Dictionary
			var cost: int = int(stats.get("power_cost", 0))
			if order.piece_id >= 0:
				_remove_piece_by_id(order.piece_id)
			power_tokens[camp] = camp_power(camp) + cost
			power_changed.emit(camp, camp_power(camp))
		GameOrder.Kind.EXCHANGE:
			var recipe: Dictionary = GameConstants.exchange_recipe(order.exchange_result)
			if not recipe.is_empty():
				var from_type: GameConstants.PieceType = recipe["from"]
				var need: int = int(recipe["count"])
				var hq: String = BoardCatalog.hq_for_camp(camp)
				if order.piece_id >= 0:
					_remove_piece_by_id(order.piece_id)
				for _i in need:
					_add_piece(camp, from_type, hq, true)
		GameOrder.Kind.HBOMB_PLACE:
			# Fusion déjà consommée — pas d'annulation sûre.
			_restore_order(order)
			return "✕ H"
		_:
			pass
	return ""


func try_cancel_last_human_order() -> String:
	return try_cancel_last_order(human_camp)


## Host applies an order from a remote human player (online).
func try_apply_network_order(data: Dictionary) -> String:
	var order: GameOrder = _order_from_dict(data)
	if order.camp == human_camp:
		return ""
	if not GameSession.network_is_host:
		return "Host only."
	if GameSession.slot_kind(order.camp) != GameSession.SlotKind.NETWORK:
		return "Camp is not an online player."
	if phase != GameConstants.GamePhase.PLANNING:
		return "Not in planning phase."
	if not is_alive(order.camp):
		return "Camp eliminated."
	match order.kind:
		GameOrder.Kind.MOVE:
			var piece: PieceInstance = find_piece(order.piece_id)
			if piece == null:
				return "Unknown piece."
			if piece.camp != order.camp:
				return "Camp mismatch."
			return try_move_piece(piece, order.to_sector)
		GameOrder.Kind.BUY:
			return try_buy_to_reserve(order.camp, order.piece_type)
		GameOrder.Kind.EXCHANGE:
			return try_exchange_to_reserve(order.camp, order.exchange_result)
		GameOrder.Kind.DEPLOY_FROM_RESERVE:
			var deploy_piece: PieceInstance = find_piece(order.piece_id)
			if deploy_piece == null:
				return "Unknown piece."
			return try_deploy_from_reserve(deploy_piece, order.to_sector)
		GameOrder.Kind.HBOMB_PLACE:
			return try_place_hbomb(order.camp, order.to_sector)
		GameOrder.Kind.HBOMB_STRIKE:
			return try_hbomb_strike(order.camp, order.to_sector)
		_:
			return "Unknown order."


func _pop_last_order_for_camp(camp: GameConstants.Camp) -> GameOrder:
	for i in range(pending_orders.size() - 1, -1, -1):
		var order: GameOrder = pending_orders[i]
		if order.camp != camp:
			continue
		pending_orders.remove_at(i)
		orders_by_camp[camp] = maxi(0, camp_orders_used(camp) - 1)
		return order
	return null


func _restore_order(order: GameOrder) -> void:
	pending_orders.append(order)
	var camp: GameConstants.Camp = order.camp
	orders_by_camp[camp] = camp_orders_used(camp) + 1


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
		return "Not your piece."
	return try_deploy_from_reserve(piece, to_sector)


func _has_pending_hbomb_place(camp: GameConstants.Camp) -> bool:
	for order: GameOrder in pending_orders:
		if order.camp == camp and order.kind == GameOrder.Kind.HBOMB_PLACE:
			return true
	return false


func apply_planning_orders(logs: Array[String]) -> void:
	for order: GameOrder in pending_orders:
		apply_single_order(order, logs)


func apply_single_order(order: GameOrder, logs: Array[String]) -> void:
	match order.kind:
		GameOrder.Kind.MOVE:
			var piece: PieceInstance = find_piece(order.piece_id)
			if piece == null:
				return
			var from_s: String = piece.sector_id
			piece.sector_id = order.to_sector
			piece_moved.emit(piece.id, from_s, order.to_sector)
			logs.append("  · " + order.bbcode_label())
		GameOrder.Kind.DEPLOY_FROM_RESERVE:
			var deploy_piece: PieceInstance = find_piece(order.piece_id)
			if deploy_piece == null:
				return
			deploy_piece.in_reserve = false
			deploy_piece.sector_id = order.to_sector
			piece_moved.emit(deploy_piece.id, "reserve", order.to_sector)
			logs.append("  · " + order.bbcode_label())
		GameOrder.Kind.HBOMB_PLACE:
			_add_piece(order.camp, GameConstants.PieceType.HBOMB, order.to_sector, false)
			logs.append("  · " + order.bbcode_label())
		GameOrder.Kind.HBOMB_STRIKE:
			if order.piece_id >= 0:
				_remove_piece_by_id(order.piece_id)
			logs.append("  · " + BattleResolver.resolve_hbomb_strike(self, order.to_sector, order.camp))
		_:
			pass


func apply_territory_power(logs: Array[String]) -> Dictionary:
	return RoundResolverScript.apply_power_harvest(self, logs)


func end_planning_round() -> Array[String]:
	var logs: Array[String] = []
	resolve_round_moves(logs)
	resolve_round_combats(logs)
	resolve_round_flags(logs)
	resolve_round_harvest(logs)
	finish_round_after_resolution()
	return logs


func capture_round_board_snapshot() -> void:
	round_board_snapshot.clear()
	for p: PieceInstance in pieces:
		round_board_snapshot[p.id] = {
			"sector_id": p.sector_id,
			"in_reserve": p.in_reserve,
		}


func resolve_round_moves(logs: Array[String]) -> void:
	capture_round_board_snapshot()
	logs.append("[color=#888aa0]▸ %s[/color]" % RoundResolverScript.PHASE_LABELS[RoundResolverScript.Phase.MOVES])
	apply_planning_orders(logs)
	commit_movement_phase()


## Après exécution des ordres de mouvement — vide la file (sinon fantômes UI + combats faux).
func commit_movement_phase() -> void:
	pending_orders.clear()


func resolve_round_combats(logs: Array[String]) -> void:
	logs.append("[color=#888aa0]▸ %s[/color]" % RoundResolverScript.PHASE_LABELS[RoundResolverScript.Phase.COMBATS])
	var combat_logs: Array = BattleResolver.resolve_all_conflicts(self)
	for line: Variant in combat_logs:
		logs.append(str(line))


func resolve_round_flags(logs: Array[String]) -> void:
	logs.append("[color=#888aa0]▸ %s[/color]" % RoundResolverScript.PHASE_LABELS[RoundResolverScript.Phase.FLAG_CHECK])
	_check_flag_captures(logs)


func resolve_round_harvest(logs: Array[String]) -> Dictionary:
	logs.append("[color=#888aa0]▸ %s[/color]" % RoundResolverScript.PHASE_LABELS[RoundResolverScript.Phase.POWER_HARVEST])
	return apply_territory_power(logs)


func finish_round_after_resolution() -> void:
	advance_round()
	set_phase(GameConstants.GamePhase.PLANNING)


func _check_flag_captures(logs: Array[String]) -> void:
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if not is_alive(camp):
			continue
		var hq: String = BoardCatalog.hq_for_camp(camp)
		for p in pieces_on_sector(hq):
			if p.camp != camp and p.type != GameConstants.PieceType.HBOMB:
				alive[camp] = false
				logs.append(GameOrder.feed_flag_eliminated(camp))
				break


func advance_round() -> void:
	round_number += 1
	_clear_round_orders()
	round_advanced.emit(round_number)


func to_snapshot() -> Dictionary:
	var pieces_data: Array = []
	for p: PieceInstance in pieces:
		pieces_data.append({
			"id": p.id,
			"camp": int(p.camp),
			"type": int(p.type),
			"sector_id": p.sector_id,
			"in_reserve": p.in_reserve,
		})
	var orders_data: Array = []
	for order: GameOrder in pending_orders:
		orders_data.append(_order_to_dict(order))
	return {
		"phase": int(phase),
		"round_number": round_number,
		"human_camp": int(human_camp),
		"alive": alive.duplicate(),
		"power_tokens": power_tokens.duplicate(),
		"pieces": pieces_data,
		"pending_orders": orders_data,
		"orders_by_camp": orders_by_camp.duplicate(),
		"pieces_moved_this_round": pieces_moved_this_round.duplicate(),
		"next_piece_id": _next_piece_id,
		"match_timer_seconds": match_timer_seconds,
	}


func restore_from_snapshot(data: Dictionary) -> void:
	if data.is_empty():
		reset_match()
		return
	phase = int(data.get("phase", GameConstants.GamePhase.PLANNING)) as GameConstants.GamePhase
	round_number = int(data.get("round_number", 1))
	human_camp = int(data.get("human_camp", GameConstants.Camp.GREEN)) as GameConstants.Camp
	alive = (data.get("alive", alive) as Dictionary).duplicate()
	power_tokens = (data.get("power_tokens", power_tokens) as Dictionary).duplicate()
	pieces.clear()
	_next_piece_id = int(data.get("next_piece_id", 1))
	match_timer_seconds = int(data.get("match_timer_seconds", 0))
	for entry: Variant in data.get("pieces", []) as Array:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = entry as Dictionary
		var piece := PieceInstance.new(
			int(d.get("id", 0)),
			int(d.get("camp", 0)) as GameConstants.Camp,
			int(d.get("type", 0)) as GameConstants.PieceType,
			str(d.get("sector_id", "")),
			bool(d.get("in_reserve", false)),
		)
		pieces.append(piece)
		_next_piece_id = maxi(_next_piece_id, piece.id + 1)
	pending_orders.clear()
	for entry: Variant in data.get("pending_orders", []) as Array:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		pending_orders.append(_order_from_dict(entry as Dictionary))
	orders_by_camp = (data.get("orders_by_camp", {}) as Dictionary).duplicate()
	var moved_raw: Array = (data.get("pieces_moved_this_round", []) as Array).duplicate()
	pieces_moved_this_round.clear()
	for moved_id: Variant in moved_raw:
		pieces_moved_this_round.append(int(moved_id))
	phase_changed.emit(phase)


static func _order_to_dict(order: GameOrder) -> Dictionary:
	return {
		"kind": int(order.kind),
		"camp": int(order.camp),
		"piece_id": order.piece_id,
		"piece_type": int(order.piece_type),
		"from_sector": order.from_sector,
		"to_sector": order.to_sector,
		"exchange_result": int(order.exchange_result),
	}


static func _order_from_dict(data: Dictionary) -> GameOrder:
	var order := GameOrder.new(
		int(data.get("kind", 0)) as GameOrder.Kind,
		int(data.get("camp", 0)) as GameConstants.Camp,
	)
	order.piece_id = int(data.get("piece_id", -1))
	order.piece_type = int(data.get("piece_type", 0)) as GameConstants.PieceType
	order.from_sector = str(data.get("from_sector", ""))
	order.to_sector = str(data.get("to_sector", ""))
	order.exchange_result = int(data.get("exchange_result", 0)) as GameConstants.PieceType
	return order
