class_name BattleResolver
extends RefCounted

## Résolution des conflits multi-camps (inspiré fight_eg Unity).


static func resolve_sector(state: GameState, sector_id: String) -> String:
	var stack: Array[PieceInstance] = state.pieces_on_sector(sector_id)
	if stack.size() <= 1:
		return ""
	var force_by_camp: Dictionary = {}
	for p in stack:
		if p.in_reserve or p.type == GameConstants.PieceType.HBOMB:
			continue
		if not state.is_alive(p.camp):
			continue
		force_by_camp[p.camp] = int(force_by_camp.get(p.camp, 0)) + p.combat_force()
	if force_by_camp.size() < 2:
		return ""
	var ranked: Array = []
	for camp: GameConstants.Camp in force_by_camp:
		ranked.append({"camp": camp, "force": int(force_by_camp[camp])})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["force"]) > int(b["force"])
	)
	var best: Dictionary = ranked[0]
	var second_force: int = int(ranked[1]["force"]) if ranked.size() > 1 else 0
	if int(best["force"]) <= second_force:
		return "Égalité sur %s (F%d vs F%d) — pas de capture." % [
			sector_id,
			int(best["force"]),
			second_force,
		]
	var winner: GameConstants.Camp = best["camp"] as GameConstants.Camp
	var captured: int = 0
	for p in stack:
		if p.camp != winner and p.type != GameConstants.PieceType.HBOMB:
			p.camp = winner
			captured += 1
	return "Combat %s : %s gagne (F%d vs F%d), %d capturée(s)." % [
		sector_id,
		GameConstants.camp_to_string(winner),
		int(best["force"]),
		second_force,
		captured,
	]


static func resolve_hbomb_strike(state: GameState, target_sector: String, attacker: GameConstants.Camp) -> String:
	var removed: int = 0
	for i in range(state.pieces.size() - 1, -1, -1):
		var p: PieceInstance = state.pieces[i]
		if p.in_reserve or p.sector_id != target_sector:
			continue
		state.pieces.remove_at(i)
		removed += 1
	return "Bombe H (%s) : %d pièce(s) détruites sur %s." % [
		GameConstants.camp_to_string(attacker),
		removed,
		BoardCatalog.sector_short_label(target_sector),
	]


static func resolve_all_conflicts(state: GameState) -> Array[String]:
	var logs: Array[String] = []
	var seen: Dictionary = {}
	for p in state.pieces:
		if p.in_reserve:
			continue
		if seen.has(p.sector_id):
			continue
		var stack := state.pieces_on_sector(p.sector_id)
		if stack.size() <= 1:
			seen[p.sector_id] = true
			continue
		var camps: Dictionary = {}
		for s in stack:
			if s.type == GameConstants.PieceType.HBOMB:
				continue
			camps[s.camp] = true
		if camps.size() > 1:
			var msg := resolve_sector(state, p.sector_id)
			if msg != "":
				logs.append(msg)
		seen[p.sector_id] = true
	return logs
