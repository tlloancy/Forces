extends Node
## Référentiel des secteurs — ordre et noms issus de Biblidecor.js (Unity).

const SECTOR_IDS: PackedStringArray = [
	"HQ_Blue", "Ice_NE", "Ice_E", "Ice_SE", "Ice_N", "Ice_C", "Ice_S",
	"Ice_NW", "Ice_W", "Ice_SW",
	"HQ_Yellow", "Desert_NE", "Desert_E", "Desert_SE", "Desert_N", "Desert_C",
	"Desert_S", "Desert_NW", "Desert_W", "Desert_SW",
	"HQ_Green", "Plains_NE", "Plains_E", "Plains_SE", "Plains_N", "Plains_C",
	"Plains_S", "Plains_NW", "Plains_W", "Plains_SW",
	"HQ_Red", "Jungle_NE", "Jungle_E", "Jungle_SE", "Jungle_N", "Jungle_C",
	"Jungle_S", "Jungle_NW", "Jungle_W", "Jungle_SW",
	"Moon_E", "Sun", "Moon_N", "Moon_S", "Moon_W",
	"Space_2", "Space_3", "Space_4", "Space_1",
	"Space_7", "Space_8", "Space_9", "Space_10", "Space_11", "Space_12",
	"Space_5", "Space_6",
]

const TURN_ORDER_BY_CAMP: Dictionary = {
	GameConstants.Camp.BLUE: [
		"HQ_Blue", "Ice_NE", "Ice_E", "Ice_SE", "Ice_N", "Ice_C", "Ice_S",
		"Ice_NW", "Ice_W", "Ice_SW", "HQ_Yellow", "Desert_NE", "Desert_E",
		"Desert_SE", "Desert_N", "Desert_C", "Desert_S", "Desert_NW",
		"Desert_W", "Desert_SW", "HQ_Green", "Plains_NE", "Plains_E",
		"Plains_SE", "Plains_N", "Plains_C", "Plains_S", "Plains_NW",
		"Plains_W", "Plains_SW", "HQ_Red", "Jungle_NE", "Jungle_E",
		"Jungle_SE", "Jungle_N", "Jungle_C", "Jungle_S", "Jungle_NW",
		"Jungle_W", "Jungle_SW", "Moon_E", "Sun", "Moon_N", "Moon_S",
		"Moon_W", "Space_2", "Space_3", "Space_4", "Space_1", "Space_7",
		"Space_8", "Space_9", "Space_10", "Space_11", "Space_12",
		"Space_5", "Space_6",
	],
	GameConstants.Camp.RED: [
		"HQ_Red", "Jungle_SW", "Jungle_W", "Jungle_NW", "Jungle_S", "Jungle_C",
		"Jungle_N", "Jungle_SE", "Jungle_E", "Jungle_NE", "HQ_Green", "Plains_SW",
		"Plains_W", "Plains_NW", "Plains_S", "Plains_C", "Plains_N", "Plains_SE",
		"Plains_E", "Plains_NE", "HQ_Yellow", "Desert_SW", "Desert_W",
		"Desert_NW", "Desert_S", "Desert_C", "Desert_N", "Desert_SE", "Desert_E",
		"Desert_NE", "HQ_Blue", "Ice_SW", "Ice_W", "Ice_NW", "Ice_S", "Ice_C",
		"Ice_N", "Ice_SE", "Ice_E", "Ice_NE", "Moon_W", "Sun", "Moon_S",
		"Moon_N", "Moon_E", "Space_4", "Space_1", "Space_2", "Space_3",
		"Space_11", "Space_12", "Space_5", "Space_6", "Space_7", "Space_8",
		"Space_9", "Space_10",
	],
	GameConstants.Camp.YELLOW: [
		"HQ_Yellow", "Desert_SE", "Desert_S", "Desert_SW", "Desert_E", "Desert_C",
		"Desert_W", "Desert_NE", "Desert_N", "Desert_NW", "HQ_Red", "Jungle_SE",
		"Jungle_S", "Jungle_SW", "Jungle_E", "Jungle_C", "Jungle_W", "Jungle_NE",
		"Jungle_N", "Jungle_NW", "HQ_Blue", "Ice_SE", "Ice_S", "Ice_SW", "Ice_E",
		"Ice_C", "Ice_W", "Ice_NE", "Ice_N", "Ice_NW", "HQ_Green", "Plains_SE",
		"Plains_S", "Plains_SW", "Plains_E", "Plains_C", "Plains_W", "Plains_NE",
		"Plains_N", "Plains_NW", "Moon_S", "Sun", "Moon_E", "Moon_W", "Moon_N",
		"Space_3", "Space_4", "Space_1", "Space_2", "Space_9", "Space_10",
		"Space_11", "Space_12", "Space_5", "Space_6", "Space_7", "Space_8",
	],
}


func hq_for_camp(camp: GameConstants.Camp) -> String:
	match camp:
		GameConstants.Camp.GREEN:
			return "HQ_Green"
		GameConstants.Camp.BLUE:
			return "HQ_Blue"
		GameConstants.Camp.RED:
			return "HQ_Red"
		GameConstants.Camp.YELLOW:
			return "HQ_Yellow"
		_:
			return ""


func sector_index(sector_id: String) -> int:
	return SECTOR_IDS.find(sector_id)


func camp_for_sector(sector_id: String) -> GameConstants.Camp:
	if sector_id.begins_with("HQ_Green") or sector_id.begins_with("Plains_"):
		return GameConstants.Camp.GREEN
	if sector_id.begins_with("HQ_Blue") or sector_id.begins_with("Ice_"):
		return GameConstants.Camp.BLUE
	if sector_id.begins_with("HQ_Red") or sector_id.begins_with("Jungle_"):
		return GameConstants.Camp.RED
	if sector_id.begins_with("HQ_Yellow") or sector_id.begins_with("Desert_"):
		return GameConstants.Camp.YELLOW
	return GameConstants.Camp.GREEN


func sector_kind(sector_id: String) -> GameConstants.SectorKind:
	if sector_id.begins_with("HQ_"):
		return GameConstants.SectorKind.HQ
	if sector_id.begins_with("Space_") or sector_id.begins_with("Moon_") or sector_id == "Sun":
		return GameConstants.SectorKind.SEA
	return GameConstants.SectorKind.LAND


func is_neutral(sector_id: String) -> bool:
	return sector_kind(sector_id) == GameConstants.SectorKind.SEA or sector_id in ["Sun", "Moon_N", "Moon_E", "Moon_S", "Moon_W"]


func turn_order(camp: GameConstants.Camp) -> PackedStringArray:
	if camp == GameConstants.Camp.GREEN:
		return TURN_ORDER_BY_CAMP[GameConstants.Camp.BLUE]
	var order: Variant = TURN_ORDER_BY_CAMP.get(camp, SECTOR_IDS)
	return order as PackedStringArray
