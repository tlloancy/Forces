class_name AiPlanner
extends RefCounted

const AGGRESSION: Dictionary = {
	GameSession.Difficulty.EASY: 0.35,
	GameSession.Difficulty.NORMAL: 0.62,
	GameSession.Difficulty.HARD: 0.88,
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
		logs.append("[b]IA %s[/b] (%s)" % [
			GameConstants.camp_to_string(camp),
			GameSession.difficulty_label(diff),
		])
		logs.append_array(plan_turn(state, camp, diff))
	return logs


static func plan_turn(state: GameState, camp: GameConstants.Camp, difficulty: GameSession.Difficulty) -> Array[String]:
	var logs: Array[String] = []
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var aggression: float = float(AGGRESSION.get(difficulty, 0.6))
	var candidates: Array[PieceInstance] = _movable_pieces(state, camp)
	candidates.sort_custom(func(a: PieceInstance, b: PieceInstance) -> bool:
		return a.combat_force() > b.combat_force()
	)
	var target_hq: String = _pick_target_hq(state, camp)
	while state.camp_orders_used(camp) < GameConstants.MAX_ORDERS_PER_ROUND and not candidates.is_empty():
		var piece: PieceInstance = candidates.pop_front()
		if state.has_piece_moved(piece.id):
			continue
		var dest: String = _pick_destination(state, piece, camp, target_hq, aggression, rng)
		if dest.is_empty():
			continue
		if rng.randf() > aggression and dest == piece.sector_id:
			continue
		var from_sector: String = piece.sector_id
		var err: String = state.try_move_piece(piece, dest)
		if err.is_empty():
			logs.append("  · %s : %s → %s" % [piece.label(), from_sector, dest])
	if logs.is_empty():
		logs.append("  · (aucun ordre)")
	return logs


static func _movable_pieces(state: GameState, camp: GameConstants.Camp) -> Array[PieceInstance]:
	var result: Array[PieceInstance] = []
	for p: PieceInstance in state.pieces:
		if p.camp != camp or p.in_reserve:
			continue
		if state.has_piece_moved(p.id):
			continue
		if not BoardGraph.has_sector(p.sector_id):
			continue
		result.append(p)
	return result


static func _pick_target_hq(state: GameState, camp: GameConstants.Camp) -> String:
	var best_hq: String = ""
	var best_dist: int = 999
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
		var d: int = BoardGraph.land_distance(from_hq, hq)
		if d < best_dist:
			best_dist = d
			best_hq = hq
	return best_hq


static func _pick_destination(
	state: GameState,
	piece: PieceInstance,
	camp: GameConstants.Camp,
	target_hq: String,
	aggression: float,
	rng: RandomNumberGenerator
) -> String:
	var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece.type, null)
	if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
		return ""
	var stats: Dictionary = stats_variant as Dictionary
	var max_move: int = int(stats.get("max_move", 1))
	var dests: PackedStringArray = BoardGraph.land_destinations(piece.sector_id, max_move)
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
	if best_score < 5.0 and rng.randf() > aggression:
		return ""
	return best_sector


static func _score_destination(
	state: GameState,
	piece: PieceInstance,
	camp: GameConstants.Camp,
	dest: String,
	target_hq: String,
	aggression: float,
	rng: RandomNumberGenerator
) -> float:
	var score: float = rng.randf_range(0.0, 3.0)
	var my_force: int = piece.combat_force()
	var enemy_force: int = _enemy_force_on_sector(state, dest, camp)
	var ally_force: int = _ally_force_on_sector(state, dest, camp, piece.id)
	if enemy_force > 0:
		if my_force + ally_force > enemy_force:
			score += 70.0 + float(enemy_force) * 0.5
		elif my_force + ally_force == enemy_force:
			score += 25.0 * aggression
		else:
			score += 10.0 * aggression
	else:
		score += 15.0
	var dest_camp: GameConstants.Camp = BoardCatalog.camp_for_sector(dest)
	if dest_camp != camp and not BoardCatalog.is_neutral(dest):
		score += 35.0 * aggression
	if dest == target_hq:
		score += 50.0
	elif not target_hq.is_empty():
		var closer: int = BoardGraph.land_distance(piece.sector_id, target_hq)
		var after: int = BoardGraph.land_distance(dest, target_hq)
		score += float(closer - after) * 12.0
	var my_hq: String = BoardCatalog.hq_for_camp(camp)
	if piece.sector_id == my_hq and dest != my_hq:
		score += 20.0 * aggression
	if dest == piece.sector_id:
		score -= 40.0
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
