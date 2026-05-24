class_name BattleResolver
extends RefCounted

## Résolution simplifiée : somme des forces par camp ; le plus fort capture les pièces adverses.


static func resolve_sector(state: GameState, sector_id: String) -> String:
	var stack: Array[PieceInstance] = state.pieces_on_sector(sector_id)
	if stack.size() <= 1:
		return ""
	var force_by_camp: Dictionary = {}
	for p in stack:
		if not state.is_alive(p.camp):
			continue
		force_by_camp[p.camp] = int(force_by_camp.get(p.camp, 0)) + p.combat_force()
	if force_by_camp.is_empty():
		return ""
	var winner: GameConstants.Camp = GameConstants.Camp.GREEN
	var best: int = -1
	for camp: GameConstants.Camp in force_by_camp:
		var f: int = int(force_by_camp[camp])
		if f > best:
			best = f
			winner = camp
	# Égalité : pas de capture (simplifié)
	var tied: bool = false
	for camp: GameConstants.Camp in force_by_camp:
		if camp != winner and int(force_by_camp[camp]) == best:
			tied = true
			break
	if tied:
		return "Égalité sur %s — pas de capture." % sector_id
	var captured: int = 0
	for p in stack:
		if p.camp != winner:
			p.camp = winner
			captured += 1
	return "Combat %s : %s gagne (F%d), %d pièce(s) capturée(s)." % [
		sector_id,
		GameConstants.camp_to_string(winner),
		best,
		captured,
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
		if stack.size() > 1:
			var camps: Dictionary = {}
			for s in stack:
				camps[s.camp] = true
			if camps.size() > 1:
				var msg := resolve_sector(state, p.sector_id)
				if msg != "":
					logs.append(msg)
		seen[p.sector_id] = true
	return logs
