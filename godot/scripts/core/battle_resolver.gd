class_name BattleResolver
extends RefCounted

## Résolution des conflits multi-camps (inspiré fight_eg Unity).


static func resolve_sector_result(state: GameState, sector_id: String) -> Dictionary:
	var empty: Dictionary = {"log": "", "winner": -1, "tie": false}
	var stack: Array[PieceInstance] = state.pieces_on_sector(sector_id)
	if stack.size() <= 1:
		return empty
	var force_by_camp: Dictionary = {}
	for p in stack:
		if p.in_reserve or p.type == GameConstants.PieceType.HBOMB:
			continue
		if not state.is_alive(p.camp):
			continue
		force_by_camp[p.camp] = int(force_by_camp.get(p.camp, 0)) + p.combat_force()
	if force_by_camp.size() < 2:
		return empty
	var ranked: Array = []
	for camp: GameConstants.Camp in force_by_camp:
		ranked.append({"camp": camp, "force": int(force_by_camp[camp])})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["force"]) > int(b["force"])
	)
	var best: Dictionary = ranked[0]
	var second_force: int = int(ranked[1]["force"]) if ranked.size() > 1 else 0
	if int(best["force"]) <= second_force:
		_revert_sector_to_round_start(state, sector_id)
		return {
			"log": GameOrder.feed_combat_tie(sector_id, int(best["force"]), second_force),
			"winner": -1,
			"tie": true,
		}
	var winner: GameConstants.Camp = best["camp"] as GameConstants.Camp
	var winner_hq: String = BoardCatalog.hq_for_camp(winner)
	for p in stack:
		if p.camp == winner or p.type == GameConstants.PieceType.HBOMB:
			continue
		# Unity fight_change_reserve : pièce capturée → réserve du VAINQUEUR (pas du perdant).
		p.camp = winner
		p.in_reserve = true
		p.sector_id = winner_hq
	return {
		"log": GameOrder.feed_combat_win(sector_id, winner, int(best["force"]), second_force),
		"winner": int(winner),
		"tie": false,
	}


static func resolve_sector(state: GameState, sector_id: String) -> String:
	return str(resolve_sector_result(state, sector_id).get("log", ""))


static func _revert_sector_to_round_start(state: GameState, sector_id: String) -> void:
	if state.round_board_snapshot.is_empty():
		return
	for p: PieceInstance in state.pieces_on_sector(sector_id):
		var snap: Variant = state.round_board_snapshot.get(p.id)
		if snap == null or not (snap is Dictionary):
			continue
		p.sector_id = str(snap["sector_id"])
		p.in_reserve = bool(snap["in_reserve"])


static func resolve_hbomb_strike(state: GameState, target_sector: String, attacker: GameConstants.Camp) -> String:
	var removed: int = 0
	for i in range(state.pieces.size() - 1, -1, -1):
		var p: PieceInstance = state.pieces[i]
		if p.in_reserve or p.sector_id != target_sector:
			continue
		state.pieces.remove_at(i)
		removed += 1
	return GameOrder.feed_hbomb_strike(attacker, target_sector, removed)


## Secteurs où au moins deux camps ont des pièces (après application des ordres).
static func conflict_sectors(state: GameState) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var seen: Dictionary = {}
	for p: PieceInstance in state.pieces:
		if p.in_reserve or seen.has(p.sector_id):
			continue
		var camps: Dictionary = {}
		for s: PieceInstance in state.pieces_on_sector(p.sector_id):
			if s.type == GameConstants.PieceType.HBOMB:
				continue
			camps[s.camp] = true
		if camps.size() > 1:
			result.append(p.sector_id)
		seen[p.sector_id] = true
	return result


static func resolve_all_conflicts(state: GameState) -> Array[String]:
	var logs: Array[String] = []
	var safety: int = 48
	while safety > 0:
		safety -= 1
		var sectors: PackedStringArray = conflict_sectors(state)
		if sectors.is_empty():
			break
		var progressed: bool = false
		for sector_id: String in sectors:
			var msg: String = resolve_sector(state, sector_id)
			if msg.is_empty():
				continue
			logs.append(msg)
			if not msg.contains("═"):
				progressed = true
		if not progressed:
			break
	return logs
