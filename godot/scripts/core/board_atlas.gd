class_name BoardAtlas
extends RefCounted
## Atlas FORCE-AD-13a — tuiles et fond plateau (Unity ContainsPlace / Decor).

const ATLAS_PATH := "res://assets/textures/FORCE-AD-13a.png"
const DATA_PATH := "res://data/atlas_sprites.json"

static var _data: Dictionary = {}
static var _texture: Texture2D
static var _loaded: bool = false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(DATA_PATH):
		push_error("Missing atlas_sprites.json — run tools/parse_atlas_meta.py")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_data = parsed as Dictionary
	if ResourceLoader.exists(ATLAS_PATH):
		_texture = load(ATLAS_PATH) as Texture2D


static func texture() -> Texture2D:
	_load()
	return _texture


static func board_reference_rect() -> Rect2:
	_load()
	var h: Variant = _data.get("highlights", {}).get("board_reference", null)
	if h == null or typeof(h) != TYPE_DICTIONARY:
		return Rect2()
	var d: Dictionary = h as Dictionary
	return Rect2(float(d.get("x", 0)), float(d.get("y", 0)), float(d.get("w", 1)), float(d.get("h", 1)))


static func make_atlas(sprite_id: String) -> AtlasTexture:
	_load()
	var atlas := AtlasTexture.new()
	atlas.atlas = _texture
	var sprites: Dictionary = _data.get("sprites", {}) as Dictionary
	var entry: Variant = sprites.get(sprite_id, null)
	if entry == null or typeof(entry) != TYPE_DICTIONARY:
		return atlas
	var d: Dictionary = entry as Dictionary
	atlas.region = Rect2(float(d["x"]), float(d["y"]), float(d["w"]), float(d["h"]))
	return atlas


static func tile_sprite_id(sector_id: String) -> String:
	_load()
	var defaults: Dictionary = _data.get("tile_defaults", {}) as Dictionary
	if sector_id.begins_with("HQ_"):
		return str(defaults.get("hq", "FORCE-AD-13a_67"))
	if sector_id.begins_with("Space_"):
		return str(defaults.get("sea", "FORCE-AD-13a_68"))
	if sector_id.begins_with("Moon_") or sector_id == "Sun":
		return str(defaults.get("neutral", "FORCE-AD-13a_68"))
	return str(defaults.get("land", "FORCE-AD-13a_68"))


static func sector_tint(sector_id: String) -> Color:
	if BoardCatalog.sector_kind(sector_id) == GameConstants.SectorKind.SEA:
		return Color(0.55, 0.58, 0.62, 1.0)
	if BoardCatalog.is_neutral(sector_id):
		return Color(0.92, 0.92, 0.95, 1.0)
	return GameConstants.CAMP_COLORS[BoardCatalog.camp_for_sector(sector_id)]


static func board_reference_id() -> String:
	_load()
	var h: Dictionary = _data.get("highlights", {}) as Dictionary
	var ref: Variant = h.get("board_reference", null)
	if ref is Dictionary:
		return str((ref as Dictionary).get("id", "FORCE-AD-13a_13"))
	return "FORCE-AD-13a_13"
