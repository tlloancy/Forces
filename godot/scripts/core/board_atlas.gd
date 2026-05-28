class_name BoardAtlas
extends RefCounted
## Atlas FORCE-AD-13a — tuiles, icônes UI et pièces (Unity ContainsPlace / Reserve).

const ATLAS_PATH := "res://assets/textures/FORCE-AD-13a.png"
const DATA_PATH := "res://data/atlas_sprites.json"
const LAND_STEP := 88.0 / 3.0

static var _data: Dictionary = {}
static var _texture: Texture2D
static var _loaded: bool = false
static var _cache: Dictionary = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(DATA_PATH):
		push_error("Missing atlas_sprites.json — run tools/parse_atlas_meta.py")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		_data = parsed as Dictionary
	if ResourceLoader.exists(ATLAS_PATH):
		var loaded: Resource = ResourceLoader.load(ATLAS_PATH)
		if loaded is Texture2D:
			_texture = loaded as Texture2D
		else:
			push_error("BoardAtlas: %s n'est pas une Texture2D" % ATLAS_PATH)


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
	if _cache.has(sprite_id):
		return _cache[sprite_id] as AtlasTexture
	var atlas := AtlasTexture.new()
	atlas.atlas = _texture
	var sprites: Dictionary = _data.get("sprites", {}) as Dictionary
	var entry: Variant = sprites.get(sprite_id, null)
	if entry != null and typeof(entry) == TYPE_DICTIONARY:
		var d: Dictionary = entry as Dictionary
		atlas.region = Rect2(float(d["x"]), float(d["y"]), float(d["w"]), float(d["h"]))
	_cache[sprite_id] = atlas
	return atlas


static func icon_id(key: String) -> String:
	_load()
	var icons: Dictionary = _data.get("piece_icons", {}) as Dictionary
	return str(icons.get(key, "FORCE-AD-13a_19"))


static func icon_texture(key: String) -> AtlasTexture:
	return make_atlas(icon_id(key))


static func piece_shape_key(piece_type: GameConstants.PieceType, filled: bool) -> String:
	match piece_type:
		GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO:
			return "circle_filled" if filled else "circle_outline"
		GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER:
			return "square_filled" if filled else "square_outline"
		GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER:
			return "triangle_filled" if filled else "triangle_outline"
		GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER:
			return "diamond_filled" if filled else "diamond_outline"
		GameConstants.PieceType.HBOMB:
			return "hbomb_h"
		_:
			return "circle_filled"


static func piece_board_texture(piece_type: GameConstants.PieceType) -> AtlasTexture:
	var filled: bool = piece_type not in [
		GameConstants.PieceType.SOLDIER,
		GameConstants.PieceType.RAIDER,
		GameConstants.PieceType.HUNTER,
		GameConstants.PieceType.CRUISER,
	]
	return icon_texture(piece_shape_key(piece_type, filled))


static func tile_sprite_id(sector_id: String) -> String:
	_load()
	var defaults: Dictionary = _data.get("tile_defaults", {}) as Dictionary
	var shapes: Dictionary = _data.get("tile_shapes", {}) as Dictionary
	if sector_id.begins_with("HQ_"):
		return str(shapes.get("HQ", defaults.get("hq", "FORCE-AD-13a_67")))
	if sector_id.begins_with("Space_"):
		var sp_key := "Sp" + sector_id.trim_prefix("Space_")
		if shapes.has(sp_key):
			return str(shapes[sp_key])
		return str(defaults.get("sea", defaults.get("neutral", "FORCE-AD-13a_106")))
	if sector_id == "Sun":
		return str(shapes.get("CE", defaults.get("neutral", "FORCE-AD-13a_77")))
	if sector_id.begins_with("Moon_"):
		return str(shapes.get("CE", defaults.get("neutral", "FORCE-AD-13a_77")))
	# Îles 3×3 : forme octogonale par suffixe (Unity filtre_sprite NW/N/…/SE).
	for prefix: String in ["Plains", "Ice", "Jungle", "Desert"]:
		if sector_id.begins_with(prefix + "_"):
			var suffix: String = sector_id.trim_prefix(prefix + "_")
			if shapes.has(suffix):
				return str(shapes[suffix])
	return str(shapes.get("CE", defaults.get("land", "FORCE-AD-13a_77")))


static func sector_tint(sector_id: String) -> Color:
	return sector_tile_modulate(sector_id)


static func sector_tile_modulate(sector_id: String) -> Color:
	if sector_id.begins_with("Space_"):
		return Color(0.55, 0.58, 0.62, 1.0)
	if sector_id == "Sun" or sector_id.begins_with("Moon_"):
		return Color(0.92, 0.93, 0.96, 1.0)
	if BoardCatalog.is_neutral(sector_id):
		return Color(0.92, 0.93, 0.96, 1.0)
	var tint := _camp_multiply_color(BoardCatalog.camp_for_sector(sector_id))
	if sector_id.begins_with("HQ_"):
		return Color(
			minf(tint.r * 1.15, 1.0),
			minf(tint.g * 1.15, 1.0),
			minf(tint.b * 1.15, 1.0),
			1.0
		)
	return Color(tint.r, tint.g, tint.b, 1.0)


static func tile_texture(sector_id: String) -> AtlasTexture:
	return make_atlas(tile_sprite_id(sector_id))


static func tile_native_size(sector_id: String) -> Vector2:
	var tex := tile_texture(sector_id)
	if tex == null:
		return Vector2(70.0, 70.0)
	var sz := tex.get_size()
	return Vector2(float(sz.x), float(sz.y))


## Tailles des tuiles sur board_composed.png (compose_board_from_tiles.py).
static func highlight_design_size(sector_id: String) -> Vector2:
	if sector_id.begins_with("Space_"):
		return Vector2(14.0, 14.0)
	if sector_id.begins_with("HQ_"):
		return Vector2(28.0, 28.0)
	if sector_id == "Sun":
		return Vector2(24.0, 24.0)
	if sector_id.begins_with("Moon_"):
		return Vector2(22.0, 22.0)
	return Vector2(27.0, 27.0)


static func tile_design_size(sector_id: String) -> Vector2:
	return highlight_design_size(sector_id)


static func _camp_multiply_color(camp: GameConstants.Camp) -> Color:
	## Teinte île / HQ — alignée sur CAMP_COLORS (plus de swap vert↔rouge).
	var c: Color = GameConstants.CAMP_COLORS.get(camp, Color.WHITE) as Color
	return Color(
		minf(c.r * 1.45, 1.0),
		minf(c.g * 1.45, 1.0),
		minf(c.b * 1.45, 1.0),
		1.0,
	)


static func board_reference_id() -> String:
	_load()
	var h: Dictionary = _data.get("highlights", {}) as Dictionary
	var ref: Variant = h.get("board_reference", null)
	if ref is Dictionary:
		return str((ref as Dictionary).get("id", "FORCE-AD-13a_13"))
	return "FORCE-AD-13a_13"
