class_name RoundResolver
extends RefCounted
## Phases de fin de manche — séparées pour logs + animations futures.

enum Phase { MOVES, COMBATS, FLAG_CHECK, POWER_HARVEST }

const PHASE_LABELS: Dictionary = {
	Phase.MOVES: "→",
	Phase.COMBATS: "⚔",
	Phase.FLAG_CHECK: "⚑",
	Phase.POWER_HARVEST: "⚡",
}


## Îles ennemies occupées par `camp` — +1 Force par île (Unity collect_force), pas par case.
static func occupied_enemy_islands(state: GameState, camp: GameConstants.Camp) -> Array[GameConstants.Camp]:
	var result: Array[GameConstants.Camp] = []
	var seen: Dictionary = {}
	for p: PieceInstance in state.pieces:
		if p.in_reserve or p.camp != camp or p.type == GameConstants.PieceType.HBOMB:
			continue
		if BoardCatalog.sector_kind(p.sector_id) != GameConstants.SectorKind.LAND:
			continue
		var owner: GameConstants.Camp = BoardCatalog.camp_for_sector(p.sector_id)
		if owner == camp or not state.is_alive(owner):
			continue
		if seen.has(owner):
			continue
		seen[owner] = true
		result.append(owner)
	return result


## Une case représentative par île créditée (flash UI).
static func representative_sectors_for_islands(
	state: GameState,
	occupier: GameConstants.Camp,
	enemy_islands: Array[GameConstants.Camp],
) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	for enemy: GameConstants.Camp in enemy_islands:
		for p: PieceInstance in state.pieces:
			if p.in_reserve or p.camp != occupier:
				continue
			if BoardCatalog.camp_for_sector(p.sector_id) == enemy:
				result.append(p.sector_id)
				break
	return result


static func apply_power_harvest(state: GameState, logs: Array[String]) -> Dictionary:
	## Retourne { camp: PackedStringArray } — secteurs témoins pour l'animation.
	var by_camp: Dictionary = {}
	for occupier: GameConstants.Camp in [
		GameConstants.Camp.GREEN,
		GameConstants.Camp.BLUE,
		GameConstants.Camp.RED,
		GameConstants.Camp.YELLOW,
	]:
		if not state.is_alive(occupier):
			continue
		var islands: Array[GameConstants.Camp] = occupied_enemy_islands(state, occupier)
		if islands.is_empty():
			continue
		by_camp[occupier] = representative_sectors_for_islands(state, occupier, islands)
		state.power_tokens[occupier] = state.camp_power(occupier) + islands.size()
		state.power_changed.emit(occupier, state.camp_power(occupier))
		for enemy: GameConstants.Camp in islands:
			logs.append("  · " + GameOrder.feed_harvest(occupier, enemy))
	return by_camp
