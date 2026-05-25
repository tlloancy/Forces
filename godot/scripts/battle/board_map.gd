extends Control
## Plateau plein écran — tuiles atlas individuelles + zones cliquables + pièces.

const BoardAtlas = preload("res://scripts/core/board_atlas.gd")

signal sector_pressed(sector_id: String)

const DESIGN := Vector2(280.0, 280.0)
const SIDEBAR_MARGIN := 218.0
const LAND_STEP := 88.0 / 3.0

var _layout: Dictionary = {}
var _layout_meta: Dictionary = {}
var _hits: Dictionary = {}
var _selected: String = ""
var _move_highlights: PackedStringArray = PackedStringArray()
var _highlight_color: Color = Color(0.95, 0.85, 0.35, 0.55)
var _state: GameState
var _flash_sectors: PackedStringArray = PackedStringArray()
var _flash_color: Color = Color(1.0, 0.45, 0.35, 0.7)
var _flash_time_left: float = 0.0


func _ready() -> void:
	_load_layout()
	_build()
	resized.connect(_on_resized)
	call_deferred("_on_resized")
	queue_redraw()


func _load_layout() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/sector_layout.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		_layout = parsed as Dictionary
		if _layout.has("_meta") and typeof(_layout["_meta"]) == TYPE_DICTIONARY:
			_layout_meta = _layout["_meta"] as Dictionary
		_layout.erase("_meta")


func _design_size() -> Vector2:
	var w: float = float(_layout_meta.get("design_width", DESIGN.x))
	var h: float = float(_layout_meta.get("design_height", DESIGN.y))
	return Vector2(w, h)


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_hits.clear()

	for sector_id: String in BoardCatalog.SECTOR_IDS:
		if not _layout.has(sector_id):
			continue
		var hit := Control.new()
		hit.name = sector_id
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		hit.gui_input.connect(_on_hit.bind(sector_id))
		add_child(hit)
		_hits[sector_id] = hit

	_relayout_hits()


func _board_rect() -> Rect2:
	var pad := 12.0
	var design := _design_size()
	var left := SIDEBAR_MARGIN + pad
	var avail := Rect2(left, pad, maxf(1.0, size.x - left - pad), maxf(1.0, size.y - pad * 2.0))
	var aspect := design.x / design.y
	var w := avail.size.x
	var h := w / aspect
	if h > avail.size.y:
		h = avail.size.y
		w = h * aspect
	var ox := left + (avail.size.x - w) * 0.5
	var oy := avail.position.y + (avail.size.y - h) * 0.5
	return Rect2(ox, oy, w, h)


func _on_resized() -> void:
	_relayout_hits()
	queue_redraw()


func _relayout_hits() -> void:
	if _hits.is_empty():
		return
	var board := _board_rect()
	var design := _design_size()
	var sx := board.size.x / design.x
	var sy := board.size.y / design.y
	var scale := minf(sx, sy)
	for sector_id: String in _hits:
		var hit: Control = _hits[sector_id]
		var d: Dictionary = _layout[sector_id] as Dictionary
		var r: float = float(d.get("r", 10)) * scale
		var cx := board.position.x + float(d["x"]) * sx
		var cy := board.position.y + float(d["y"]) * sy
		hit.position = Vector2(cx - r, cy - r)
		hit.size = Vector2(r * 2.0, r * 2.0)


func refresh(state: GameState) -> void:
	_state = state
	queue_redraw()


func set_selected(sector_id: String) -> void:
	_selected = sector_id
	queue_redraw()


func set_move_highlights(sectors: PackedStringArray) -> void:
	_move_highlights = sectors
	queue_redraw()


func set_highlight_color(color: Color) -> void:
	_highlight_color = color
	queue_redraw()


func flash_sectors(sectors: PackedStringArray, color: Color = Color(1.0, 0.45, 0.35, 0.75), duration: float = 0.85) -> void:
	_flash_sectors = sectors
	_flash_color = color
	_flash_time_left = maxf(duration, 0.1)


func _process(delta: float) -> void:
	if _flash_time_left > 0.0:
		_flash_time_left = maxf(0.0, _flash_time_left - delta)
		queue_redraw()


func _on_hit(event: InputEvent, sector_id: String) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			set_selected(sector_id)
			sector_pressed.emit(sector_id)


func _draw() -> void:
	var board := _board_rect()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.09, 0.11, 0.17))
	draw_rect(board.grow(4.0), Color(0.22, 0.24, 0.32))
	draw_rect(board.grow(2.0), Color(0.32, 0.34, 0.48, 0.35), false, 1.5)

	var design := _design_size()
	var sx := board.size.x / design.x
	var sy := board.size.y / design.y
	var scale := minf(sx, sy)

	_draw_tiles(board, sx, sy, scale)

	if _state == null:
		return

	if _flash_time_left > 0.0 and not _flash_sectors.is_empty():
		var pulse: float = 0.45 + 0.55 * sin(_flash_time_left * 14.0)
		var fc := Color(_flash_color.r, _flash_color.g, _flash_color.b, _flash_color.a * pulse)
		for sector_id: String in _flash_sectors:
			if not _layout.has(sector_id):
				continue
			var fd: Dictionary = _layout[sector_id] as Dictionary
			var fr: float = float(fd.get("r", 10)) * scale * 1.55
			var fcx := board.position.x + float(fd["x"]) * sx
			var fcy := board.position.y + float(fd["y"]) * sy
			draw_arc(Vector2(fcx, fcy), fr, 0.0, TAU, 36, fc, 3.5)

	for sector_id: String in _move_highlights:
		if not _layout.has(sector_id):
			continue
		var tile_rect := _sector_highlight_rect(board, sx, sy, scale, sector_id)
		if sector_id.begins_with("Space_"):
			draw_rect(tile_rect.grow(1.0), Color(_highlight_color.r, _highlight_color.g, _highlight_color.b, 0.2))
			draw_rect(tile_rect.grow(1.0), _highlight_color, false, 2.5)
		else:
			draw_rect(tile_rect.grow(1.0), Color(_highlight_color.r, _highlight_color.g, _highlight_color.b, 0.45))
			draw_rect(tile_rect.grow(1.0), _highlight_color, false, 2.5)

	if _state != null:
		var pending: Dictionary = _state.human_pending_move_targets()
		for sector_id: String in pending:
			if not _layout.has(sector_id):
				continue
			var ghost_rect := _sector_highlight_rect(board, sx, sy, scale, sector_id)
			draw_rect(ghost_rect, Color(0.35, 0.85, 0.45, 0.35))
			draw_rect(ghost_rect, Color(0.5, 1.0, 0.55, 0.85), false, 1.5)

	if _selected != "" and _layout.has(_selected):
		var d: Dictionary = _layout[_selected] as Dictionary
		var r: float = float(d.get("r", 10)) * scale * 1.35
		var cx := board.position.x + float(d["x"]) * sx
		var cy := board.position.y + float(d["y"]) * sy
		_draw_dashed_rect(Rect2(cx - r, cy - r, r * 2.0, r * 2.0), Color(1, 1, 1, 0.92), 5.0)

	for sector_id: String in _layout:
		var stack: Array[PieceInstance] = _state.pieces_on_sector(sector_id)
		if stack.is_empty():
			continue
		var sd: Dictionary = _layout[sector_id] as Dictionary
		var cx := board.position.x + float(sd["x"]) * sx
		var cy := board.position.y + float(sd["y"]) * sy
		var p: PieceInstance = stack[0]
		var col: Color = GameConstants.CAMP_COLORS[p.camp]
		_draw_piece_icon(Vector2(cx, cy), 11.0 * scale, p.type, col)
		if stack.size() > 1:
			var badge := str(stack.size())
			var font := ThemeDB.fallback_font
			draw_string(font, Vector2(cx + 6.0, cy - 6.0), badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.95))


func _sorted_sector_ids() -> Array:
	var ids: Array = []
	for sector_id in _layout:
		ids.append(sector_id)
	ids.sort_custom(func(a: String, b: String) -> bool:
		var la := _draw_layer(a)
		var lb := _draw_layer(b)
		if la != lb:
			return la < lb
		var da: Dictionary = _layout[a] as Dictionary
		var db: Dictionary = _layout[b] as Dictionary
		return float(da["y"]) < float(db["y"])
	)
	return ids


func _draw_layer(sector_id: String) -> int:
	if sector_id.begins_with("Space_"):
		return -1
	if sector_id.begins_with("Moon_") or sector_id == "Sun":
		return 2
	if sector_id.begins_with("HQ_"):
		return 3
	return 1


func _draw_tile_for_sector(sector_id: String) -> bool:
	return true


func _sector_center(board: Rect2, sx: float, sy: float, sector_id: String) -> Vector2:
	var d: Dictionary = _layout[sector_id] as Dictionary
	return Vector2(
		board.position.x + float(d["x"]) * sx,
		board.position.y + float(d["y"]) * sy,
	)


func _sector_tile_rect(board: Rect2, sx: float, sy: float, scale: float, sector_id: String) -> Rect2:
	var center := _sector_center(board, sx, sy, sector_id)
	var design := BoardAtlas.tile_design_size(sector_id) * scale
	return Rect2(center - design * 0.5, design)


## Surbrillance alignée sur les zones cliquables (layout), pas sur la taille atlas.
func _sector_highlight_rect(board: Rect2, sx: float, sy: float, scale: float, sector_id: String) -> Rect2:
	var d: Dictionary = _layout[sector_id] as Dictionary
	var center := _sector_center(board, sx, sy, sector_id)
	if sector_id.begins_with("Space_") or sector_id.begins_with("Moon_") or sector_id == "Sun":
		var r: float = float(d.get("r", 10)) * scale * (2.2 if sector_id.begins_with("Space_") else 1.6)
		return Rect2(center - Vector2(r, r), Vector2(r * 2.0, r * 2.0))
	if sector_id.begins_with("HQ_"):
		var hr: float = float(d.get("r", 14)) * scale * 1.15
		return Rect2(center - Vector2(hr, hr), Vector2(hr * 2.0, hr * 2.0))
	return _sector_tile_rect(board, sx, sy, scale, sector_id)


func _draw_sea_corridor_marker(
	board: Rect2,
	sx: float,
	sy: float,
	scale: float,
	sector_id: String,
	tint: Color,
) -> void:
	var tex: AtlasTexture = BoardAtlas.tile_texture(sector_id)
	if tex == null or tex.atlas == null:
		return
	var center := _sector_center(board, sx, sy, sector_id)
	var design := BoardAtlas.tile_design_size(sector_id) * scale
	var rect := Rect2(center - design * 0.5, design)
	draw_texture_rect(tex, rect, false, Color(tint.r, tint.g, tint.b, 0.55))


func _draw_tiles(board: Rect2, sx: float, sy: float, scale: float) -> void:
	for sector_id: String in _sorted_sector_ids():
		if not _draw_tile_for_sector(sector_id):
			continue
		var d: Dictionary = _layout[sector_id] as Dictionary
		var cx := board.position.x + float(d["x"]) * sx
		var cy := board.position.y + float(d["y"]) * sy
		var tex: AtlasTexture = BoardAtlas.tile_texture(sector_id)
		if tex == null or tex.atlas == null:
			continue
		var design := BoardAtlas.tile_design_size(sector_id) * scale
		var rect := Rect2(
			Vector2(cx - design.x * 0.5, cy - design.y * 0.5),
			design
		)
		var tint: Color = BoardAtlas.sector_tile_modulate(sector_id)
		if sector_id.begins_with("Space_"):
			tint = Color(0.5, 0.7, 0.92, 1.0)
		draw_texture_rect(tex, rect, false, tint)


func _draw_piece_icon(center: Vector2, icon_size: float, piece_type: GameConstants.PieceType, color: Color) -> void:
	var tex: AtlasTexture = BoardAtlas.piece_board_texture(piece_type)
	if tex == null or tex.atlas == null:
		return
	var tw: float = maxf(1.0, float(tex.get_width()))
	var th: float = maxf(1.0, float(tex.get_height()))
	var aspect := tw / th
	var h := icon_size
	var w := icon_size * aspect
	var rect := Rect2(center - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	draw_texture_rect(tex, rect, false, color)


func _draw_dashed_rect(rect: Rect2, color: Color, dash: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0),
		rect.position + rect.size,
		rect.position + Vector2(0, rect.size.y),
		rect.position,
	])
	for i in range(pts.size() - 1):
		_draw_dashed_line(pts[i], pts[i + 1], color, dash)


func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, dash: float) -> void:
	var dir := to - from
	var len := dir.length()
	if len < 1.0:
		return
	dir /= len
	var t := 0.0
	while t < len:
		var t2 := minf(t + dash, len)
		draw_line(from + dir * t, from + dir * t2, color, 2.0)
		t += dash * 2.0
