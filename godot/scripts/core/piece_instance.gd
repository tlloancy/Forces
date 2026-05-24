class_name PieceInstance
extends RefCounted

var id: int
var camp: GameConstants.Camp
var type: GameConstants.PieceType
var sector_id: String
var in_reserve: bool = false


func _init(p_id: int, p_camp: GameConstants.Camp, p_type: GameConstants.PieceType, p_sector: String = "", p_reserve: bool = true) -> void:
	id = p_id
	camp = p_camp
	type = p_type
	sector_id = p_sector
	in_reserve = p_reserve


func combat_force() -> int:
	var stats_variant: Variant = GameConstants.PIECE_STATS.get(type, null)
	if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
		return 0
	var stats: Dictionary = stats_variant as Dictionary
	return int(stats.get("force", 0))


func label() -> String:
	return GameConstants.piece_type_label(type)
