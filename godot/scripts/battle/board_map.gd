extends Control
## Plateau Forces — texture composée (tuiles Unity) + zones cliquables sector_layout.json.

signal sector_pressed(sector_id: String)

const DESIGN := Vector2(280.0, 280.0)
const SIDEBAR_MARGIN := 218.0
const BOARD_TEXTURE := "res://assets/textures/board_composed.png"

var _layout: Dictionary = {}
var _layout_meta: Dictionary = {}
var _board_tex: Texture2D
var _hits: Dictionary = {}
var _selected: String = ""
var _move_highlights: PackedStringArray = PackedStringArray()
var _highlight_color: Color = Color(0.72, 0.76, 0.82, 0.9)
var _state: GameState
var _flash_sectors: PackedStringArray = PackedStringArray()
var _flash_color: Color = Color(1.0, 0.45, 0.35, 0.7)
var _flash_time_left: float = 0.0


func _ready() -> void:
	if ResourceLoader.exists(BOARD_TEXTURE):
		_board_tex = load(BOARD_TEXTURE) as Texture2D
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
	return Vector2(
		float(_layout_meta.get("design_width", DESIGN.x)),
		float(_layout_meta.get("design_height", DESIGN.y)),
	)


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


func _scale(board: Rect2) -> Vector2:
	var design := _design_size()
	return Vector2(board.size.x / design.x, board.size.y / design.y)


func _board_scale(board: Rect2) -> float:
	var s := _scale(board)
	return minf(s.x, s.y)


func _relayout_hits() -> void:
	if _hits.is_empty():
		return
	var board := _board_rect()
	var s := _scale(board)
	var sc := _board_scale(board)
	for sector_id: String in _hits:
		var hit: Control = _hits[sector_id]
		var rect := _hit_rect(board, s.x, s.y, sc, sector_id)
		hit.position = rect.position
		hit.size = rect.size


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


func _sector_center(board: Rect2, sx: float, sy: float, sector_id: String) -> Vector2:
	var d: Dictionary = _layout[sector_id] as Dictionary
	return Vector2(
		board.position.x + float(d["x"]) * sx,
		board.position.y + float(d["y"]) * sy,
	)


func _hit_rect(board: Rect2, sx: float, sy: float, _sc: float, sector_id: String) -> Rect2:
	var center := _sector_center(board, sx, sy, sector_id)
	var design := BoardAtlas.highlight_design_size(sector_id)
	var w: float = design.x * sx
	var h: float = design.y * sy
	return Rect2(center - Vector2(w, h) * 0.5, Vector2(w, h))


func _draw() -> void:
	var board := _board_rect()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.09, 0.11, 0.17))
	if _board_tex != null:
		draw_texture_rect(_board_tex, board, false)
	else:
		draw_rect(board, Color(0.22, 0.24, 0.32))
		push_warning("board_composed.png manquant — lancer tools/compose_board_from_tiles.py")

	if _state == null:
		return

	var sx := _scale(board).x
	var sy := _scale(board).y
	var sc := _board_scale(board)

	if _flash_time_left > 0.0:
		var pulse: float = 0.45 + 0.55 * sin(_flash_time_left * 14.0)
		var fc := Color(_flash_color.r, _flash_color.g, _flash_color.b, _flash_color.a * pulse)
		for sector_id: String in _flash_sectors:
			if _layout.has(sector_id):
				draw_rect(_hit_rect(board, sx, sy, sc, sector_id).grow(2.0), fc, false, 3.0)

	for sector_id: String in _move_highlights:
		if _layout.has(sector_id):
			_draw_move_highlight(_hit_rect(board, sx, sy, sc, sector_id), sector_id)

	for sector_id: String in _state.human_pending_move_targets():
		if _layout.has(sector_id):
			var r := _hit_rect(board, sx, sy, sc, sector_id)
			draw_rect(r, Color(0.35, 0.85, 0.45, 0.35))
			draw_rect(r, Color(0.5, 1.0, 0.55, 0.85), false, 1.5)

	if _selected != "" and _layout.has(_selected):
		_draw_dashed_rect(_hit_rect(board, sx, sy, sc, _selected).grow(2.0), Color(1, 1, 1, 0.92), 5.0)

	for sector_id: String in _layout:
		var stack: Array[PieceInstance] = _state.pieces_on_sector(sector_id)
		if stack.is_empty():
			continue
		var c := _sector_center(board, sx, sy, sector_id)
		var p: PieceInstance = stack[0]
		_draw_piece_icon(c, 11.0 * sc, p.type, GameConstants.CAMP_COLORS[p.camp])
		if stack.size() > 1:
			draw_string(
				ThemeDB.fallback_font,
				c + Vector2(6.0, -6.0),
				str(stack.size()),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				10,
				Color(1, 1, 1, 0.95),
			)


func _draw_move_highlight(rect: Rect2, sector_id: String) -> void:
	var sea: bool = sector_id.begins_with("Space_") or BoardCatalog.is_neutral(sector_id)
	if sea:
		draw_rect(rect.grow(1.0), _highlight_color, false, 2.5)
	else:
		draw_rect(rect.grow(1.0), Color(_highlight_color.r, _highlight_color.g, _highlight_color.b, 0.35))
		draw_rect(rect.grow(1.0), _highlight_color, false, 2.5)


func _draw_piece_icon(center: Vector2, icon_size: float, piece_type: GameConstants.PieceType, color: Color) -> void:
	var tex: AtlasTexture = BoardAtlas.piece_board_texture(piece_type)
	if tex == null or tex.atlas == null:
		return
	var tw: float = maxf(1.0, float(tex.get_width()))
	var th: float = maxf(1.0, float(tex.get_height()))
	var h := icon_size
	var w := icon_size * (tw / th)
	draw_texture_rect(tex, Rect2(center - Vector2(w * 0.5, h * 0.5), Vector2(w, h)), false, color)


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
