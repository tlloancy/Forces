class_name AiPlanner
extends RefCounted

const AGGRESSION: Dictionary = {
	GameSession.Difficulty.EASY: 0.55,
	GameSession.Difficulty.NORMAL: 0.78,
	GameSession.Difficulty.HARD: 0.98,
}

const BUY_CHANCE: Dictionary = {
	GameSession.Difficulty.EASY: 0.25,
	GameSession.Difficulty.NORMAL: 0.55,
	GameSession.Difficulty.HARD: 0.85,
}

const DEPLOY_CHANCE: Dictionary = {
	GameSession.Difficulty.EASY: 0.35,
	GameSession.Difficulty.NORMAL: 0.7,
	GameSession.Difficulty.HARD: 0.92,
}


static func run_all_ai(state: GameState) -> Array[String]:
	var logs: Array[String] = []
	for camp: GameConstants.Camp in [
		GameConstants.Camp.GREEN,
		GameConstants.Camp.BLUE,
		GameConstants.Camp.RED,
		GameConstants.Camp.YELLOW,
	]:
		if not state.is_alive(camp):
			continue
		if not GameSession.is_ai(camp):
			continue
		var diff: GameSession.Difficulty = GameSession.slot_difficulty(camp)
		logs.append(GameOrder.feed_ai_header(camp, GameSession.difficulty_label(diff).left(1).to_upper()))
		logs.append_array(plan_turn(state, camp, diff))
	return logs


static func plan_turn(state: GameState, camp: GameConstants.Camp, difficulty: GameSession.Difficulty) -> Array[String]:
	var logs: Array[String] = []
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var aggression: float = float(AGGRESSION.get(difficulty, 0.75))
	var target_hq: String = _pick_target_hq(state, camp)
	var candidates: Array[PieceInstance] = _movable_pieces(state, camp)
	candidates.sort_custom(func(a: PieceInstance, b: PieceInstance) -> bool:
		return _piece_priority(a) > _piece_priority(b)
	)
	while state.camp_orders_used(camp) < GameConstants.MAX_ORDERS_PER_ROUND and not candidates.is_empty():
		var piece: PieceInstance = candidates.pop_front()
		if state.has_piece_moved(piece.id):
			continue
		var dest: String = _pick_destination(state, piece, camp, target_hq, aggression, difficulty, rng)
		if dest.is_empty():
			continue
		var err: String = state.try_move_piece(piece, dest)
		if err.is_empty():
			var order: GameOrder = state.orders_for_camp(camp).back()
			if order != null:
				logs.append("  " + order.bbcode_label())
	_maybe_ai_buy(state, camp, difficulty, rng, logs)
	_maybe_ai_deploy(state, camp, difficulty, rng, logs)
	_maybe_ai_exchange(state, camp, difficulty, rng, logs)
	_maybe_ai_hbomb(state, camp, difficulty, rng, logs)
	if logs.is_empty():
		logs.append("  " + GameOrder.feed_no_orders())
	return logs


static func _piece_priority(piece: PieceInstance) -> int:
	match piece.type:
		GameConstants.PieceType.COMMANDO:
			return 90
		GameConstants.PieceType.RAIDER:
			return 70
		GameConstants.PieceType.CRUISER:
			return 65
		GameConstants.PieceType.HUNTER:
			return 55
		GameConstants.PieceType.SOLDIER:
			return 40
		_:
			return 30


static func _movable_pieces(state: GameState, camp: GameConstants.Camp) -> Array[PieceInstance]:
	var result: Array[PieceInstance] = []
	for p: PieceInstance in state.pieces:
		if p.camp != camp or p.in_reserve:
			continue
		if state.has_piece_moved(p.id):
			continue
		if not _sector_valid_for_piece(p):
			continue
		result.append(p)
	return result


static func _sector_valid_for_piece(piece: PieceInstance) -> bool:
	match GameConstants.piece_movement_domain(piece.type):
		GameConstants.MovementDomain.LAND:
			return BoardGraph.has_land_sector(piece.sector_id)
		GameConstants.MovementDomain.SEA:
			return BoardGraph.has_sea_sector(piece.sector_id)
		GameConstants.MovementDomain.AIR:
			return BoardGraph.has_air_sector(piece.sector_id)
		_:
			return false


static func _pick_target_hq(state: GameState, camp: GameConstants.Camp) -> String:
	var best_hq: String = ""
	var best_score: float = -INF
	var from_hq: String = BoardCatalog.hq_for_camp(camp)
	for other: GameConstants.Camp in [
		GameConstants.Camp.GREEN,
		GameConstants.Camp.BLUE,
		GameConstants.Camp.RED,
		GameConstants.Camp.YELLOW,
	]:
		if other == camp or not state.is_alive(other):
			continue
		var hq: String = BoardCatalog.hq_for_camp(other)
		var score: float = 100.0 - float(BoardGraph.land_distance(from_hq, hq))
		if other == GameConstants.Camp.GREEN:
			score += 40.0
		if score > best_score:
			best_score = score
			best_hq = hq
	return best_hq


static func _pick_destination(
	state: GameState,
	piece: PieceInstance,
	camp: GameConstants.Camp,
	target_hq: String,
	aggression: float,
	difficulty: GameSession.Difficulty,
	rng: RandomNumberGenerator,
) -> String:
	if not GameConstants.PIECE_STATS.has(piece.type):
		return ""
	var dests: PackedStringArray = state.destinations_for(piece)
	if dests.is_empty():
		return ""
	var best_sector: String = ""
	var best_score: float = -INF
	for dest: String in dests:
		var score: float = _score_destination(state, piece, camp, dest, target_hq, aggression, rng)
		if score > best_score:
			best_score = score
			best_sector = dest
	if best_sector.is_empty():
		return ""
	if difficulty == GameSession.Difficulty.EASY and best_score < 8.0 and rng.randf() > aggression:
		return ""
	if difficulty == GameSession.Difficulty.NORMAL and best_score < 3.0 and rng.randf() > aggression * 0.5:
		return ""
	return best_sector


static func _score_destination(
	state: GameState,
	piece: PieceInstance,
	camp: GameConstants.Camp,
	dest: String,
	target_hq: String,
	aggression: float,
	rng: RandomNumberGenerator,
) -> float:
	var score: float = rng.randf_range(0.0, 2.0)
	var my_force: int = piece.combat_force()
	var enemy_force: int = _enemy_force_on_sector(state, dest, camp)
	var ally_force: int = _ally_force_on_sector(state, dest, camp, piece.id)
	if enemy_force > 0:
		if my_force + ally_force > enemy_force:
			score += 85.0 + float(enemy_force)
		elif my_force + ally_force == enemy_force:
			score += 30.0 * aggression
		else:
			score += 5.0 * aggression
	else:
		score += 18.0
	# Pénalise un assaut clairement perdant (force ennemie >> la nôtre) sauf agressivité extrême.
	if enemy_force > 0 and my_force + ally_force < enemy_force:
		var deficit: float = float(enemy_force - (my_force + ally_force))
		score -= deficit * (4.0 - 3.0 * aggression)
	var dest_camp: GameConstants.Camp = BoardCatalog.camp_for_sector(dest)
	if dest_camp != camp and not BoardCatalog.is_neutral(dest):
		score += 45.0 * aggression
	if dest == target_hq:
		score += 120.0
	elif not target_hq.is_empty():
		var closer: int = BoardGraph.land_distance(piece.sector_id, target_hq)
		var after: int = BoardGraph.land_distance(dest, target_hq)
		score += float(closer - after) * 18.0
	var my_hq: String = BoardCatalog.hq_for_camp(camp)
	if piece.sector_id == my_hq and dest != my_hq:
		score += 25.0
	if dest.begins_with("HQ_") and BoardCatalog.camp_for_sector(dest) != camp:
		score += 80.0
	match GameConstants.piece_movement_domain(piece.type):
		GameConstants.MovementDomain.SEA:
			if dest.begins_with("Space_"):
				score += 35.0
			if dest == "Space_5" or dest == "Space_8" or dest == "Space_12" or dest == "Space_10":
				score += 25.0
		GameConstants.MovementDomain.AIR:
			if dest.begins_with("Space_") or dest.begins_with("Moon_") or dest == "Sun":
				score += 22.0
	if dest == piece.sector_id:
		score -= 50.0
	return score


static func _enemy_force_on_sector(state: GameState, sector_id: String, camp: GameConstants.Camp) -> int:
	var total: int = 0
	for p: PieceInstance in state.pieces_on_sector(sector_id):
		if p.camp != camp:
			total += p.combat_force()
	return total


static func _ally_force_on_sector(state: GameState, sector_id: String, camp: GameConstants.Camp, exclude_id: int) -> int:
	var total: int = 0
	for p: PieceInstance in state.pieces_on_sector(sector_id):
		if p.camp == camp and p.id != exclude_id:
			total += p.combat_force()
	return total


static func _maybe_ai_buy(
	state: GameState,
	camp: GameConstants.Camp,
	difficulty: GameSession.Difficulty,
	rng: RandomNumberGenerator,
	logs: Array[String],
) -> void:
	if state.camp_orders_used(camp) >= GameConstants.MAX_ORDERS_PER_ROUND:
		return
	if state.camp_power(camp) < 6:
		return
	if rng.randf() > float(BUY_CHANCE.get(difficulty, 0.5)):
		return
	var types: Array[GameConstants.PieceType] = [
		GameConstants.PieceType.SOLDIER,
		GameConstants.PieceType.RAIDER,
		GameConstants.PieceType.CRUISER,
	]
	if difficulty == GameSession.Difficulty.HARD:
		types.append(GameConstants.PieceType.HUNTER)
	var pick: GameConstants.PieceType = types[rng.randi_range(0, types.size() - 1)]
	var err: String = state.try_buy_to_reserve(camp, pick)
	if err.is_empty():
		var order: GameOrder = state.orders_for_camp(camp).back()
		if order != null:
			logs.append("  " + order.bbcode_label())


static func _maybe_ai_deploy(
	state: GameState,
	camp: GameConstants.Camp,
	difficulty: GameSession.Difficulty,
	rng: RandomNumberGenerator,
	logs: Array[String],
) -> void:
	if state.camp_orders_used(camp) >= GameConstants.MAX_ORDERS_PER_ROUND:
		return
	if rng.randf() > float(DEPLOY_CHANCE.get(difficulty, 0.6)):
		return
	var reserves: Array[PieceInstance] = state.reserve_pieces(camp)
	if reserves.is_empty():
		return
	reserves.sort_custom(func(a: PieceInstance, b: PieceInstance) -> bool:
		return a.combat_force() > b.combat_force()
	)
	var hq: String = BoardCatalog.hq_for_camp(camp)
	for piece: PieceInstance in reserves:
		if state.has_piece_moved(piece.id):
			continue
		var err: String = state.try_deploy_from_reserve(piece, hq)
		if err.is_empty():
			var order: GameOrder = state.orders_for_camp(camp).back()
			if order != null:
				logs.append("  " + order.bbcode_label())
			return


static func _maybe_ai_exchange(
	state: GameState,
	camp: GameConstants.Camp,
	difficulty: GameSession.Difficulty,
	rng: RandomNumberGenerator,
	logs: Array[String],
) -> void:
	if difficulty != GameSession.Difficulty.HARD:
		return
	if state.camp_orders_used(camp) >= GameConstants.MAX_ORDERS_PER_ROUND:
		return
	if rng.randf() > 0.4:
		return
	for result_type: GameConstants.PieceType in [
		GameConstants.PieceType.COMMANDO,
		GameConstants.PieceType.BOMBER,
	]:
		if state.try_exchange_to_reserve(camp, result_type).is_empty():
			var order: GameOrder = state.orders_for_camp(camp).back()
			if order != null:
				logs.append("  " + order.bbcode_label())
			return


static func _maybe_ai_hbomb(
	state: GameState,
	camp: GameConstants.Camp,
	difficulty: GameSession.Difficulty,
	rng: RandomNumberGenerator,
	logs: Array[String],
) -> void:
	if difficulty != GameSession.Difficulty.HARD:
		return
	if state.hbomb_on_board(camp) != null:
		return
	if state.camp_orders_used(camp) >= GameConstants.MAX_ORDERS_PER_ROUND:
		return
	var hq: String = BoardCatalog.hq_for_camp(camp)
	if state.hbomb_fusion_force_available(camp, hq) < GameConstants.HBOMB_FUSION_FORCE:
		return
	if rng.randf() > 0.35:
		return
	if state.try_place_hbomb(camp, hq).is_empty():
		var order: GameOrder = state.orders_for_camp(camp).back()
		if order != null:
			logs.append("  " + order.bbcode_label())
