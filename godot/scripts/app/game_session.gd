extends Node
## Configuration de partie persistée entre menu et bataille (remplace le flux Unity menu → Create_Menu → Battleground).

enum SlotKind { HUMAN, AI }
enum Difficulty { EASY, NORMAL, HARD }

const CONFIGURABLE_CAMPS: Array[GameConstants.Camp] = [
	GameConstants.Camp.BLUE,
	GameConstants.Camp.RED,
	GameConstants.Camp.YELLOW,
]

var human_camp: GameConstants.Camp = GameConstants.Camp.GREEN
var slots: Dictionary = {}
var music_volume: float = 0.8
var sfx_volume: float = 0.8


func _ready() -> void:
	reset_to_solo_defaults()


func reset_to_solo_defaults() -> void:
	human_camp = GameConstants.Camp.GREEN
	slots = {
		GameConstants.Camp.BLUE: _slot(SlotKind.AI, Difficulty.NORMAL),
		GameConstants.Camp.RED: _slot(SlotKind.AI, Difficulty.NORMAL),
		GameConstants.Camp.YELLOW: _slot(SlotKind.AI, Difficulty.NORMAL),
	}


func _slot(kind: SlotKind, difficulty: Difficulty) -> Dictionary:
	return {"kind": kind, "difficulty": difficulty}


func set_slot(camp: GameConstants.Camp, kind: SlotKind, difficulty: Difficulty = Difficulty.NORMAL) -> void:
	if not slots.has(camp):
		slots[camp] = _slot(kind, difficulty)
	else:
		slots[camp]["kind"] = kind
		slots[camp]["difficulty"] = difficulty


func slot_kind(camp: GameConstants.Camp) -> SlotKind:
	return int(slots.get(camp, _slot(SlotKind.AI, Difficulty.NORMAL))["kind"])


func slot_difficulty(camp: GameConstants.Camp) -> Difficulty:
	return int(slots.get(camp, _slot(SlotKind.AI, Difficulty.NORMAL))["difficulty"])


func is_ai(camp: GameConstants.Camp) -> bool:
	if camp == human_camp:
		return false
	return slot_kind(camp) == SlotKind.AI


func human_player_count() -> int:
	var n: int = 1
	for camp: GameConstants.Camp in CONFIGURABLE_CAMPS:
		if slot_kind(camp) == SlotKind.HUMAN:
			n += 1
	return n


func difficulty_label(d: Difficulty) -> String:
	match d:
		Difficulty.EASY: return "Facile"
		Difficulty.NORMAL: return "Normal"
		Difficulty.HARD: return "Difficile"
		_: return "?"


func slot_summary(camp: GameConstants.Camp) -> String:
	if camp == human_camp:
		return "Joueur (vous)"
	if slot_kind(camp) == SlotKind.HUMAN:
		return "Joueur (réseau — bientôt)"
	return "IA (%s)" % difficulty_label(slot_difficulty(camp))


func setup_summary_lines() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("%s : %s" % [GameConstants.camp_to_string(human_camp), slot_summary(human_camp)])
	for camp: GameConstants.Camp in CONFIGURABLE_CAMPS:
		lines.append("%s : %s" % [GameConstants.camp_to_string(camp), slot_summary(camp)])
	return lines
