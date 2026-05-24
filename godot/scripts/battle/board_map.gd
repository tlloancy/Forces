extends Control
## Plateau fidèle — atlas FORCE-AD-13a + positions sector_layout.json.

const BoardAtlas = preload("res://scripts/core/board_atlas.gd")

signal sector_pressed(sector_id: String)

const DESIGN_SIZE := Vector2(1000.0, 700.0)

var _layout: Dictionary = {}
var _sectors: Dictionary = {}
var _selected: String = ""
var _state: GameState
var _board_bg: TextureRect
var _sector_layer: Control
var _piece_layer: Control


func _ready() -> void:
	_load_layout()
	_build_board()
	resized.connect(_relayout)


func _load_layout() -> void:
	var path := "res://data/sector_layout.json"
	if not FileAccess.file_exists(path):
		push_error("Missing sector_layout.json")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) == TYPE_DICTIONARY:
		_layout = parsed as Dictionary


func _build_board() -> void:
	for child in get_children():
		child.queue_free()
	_sectors.clear()

	var ocean := ColorRect.new()
	ocean.name = "Ocean"
	ocean.color = Color(0.04, 0.07, 0.11)
	ocean.set_anchors_preset(Control.PRESET_FULL_RECT)
	ocean.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ocean)

	_board_bg = TextureRect.new()
	_board_bg.name = "BoardReference"
	_board_bg.texture = BoardAtlas.make_atlas(BoardAtlas.board_reference_id())
	_board_bg.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_board_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_board_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_board_bg)

	_sector_layer = Control.new()
	_sector_layer.name = "Sectors"
	_sector_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sector_layer)

	_piece_layer = Control.new()
	_piece_layer.name = "Pieces"
	_piece_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_piece_layer)

	for sector_id: String in BoardCatalog.SECTOR_IDS:
		if not _layout.has(sector_id):
			continue
		var node := _make_sector_node(sector_id)
		_sector_layer.add_child(node)
		_sectors[sector_id] = node

	_relayout()


func _make_sector_node(sector_id: String) -> Control:
	var root := Control.new()
	root.name = sector_id
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.gui_input.connect(_on_sector_gui_input.bind(sector_id))

	var tile := TextureRect.new()
	tile.name = "Tile"
	tile.texture = BoardAtlas.make_atlas(BoardAtlas.tile_sprite_id(sector_id))
	tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tile.modulate = BoardAtlas.sector_tint(sector_id)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tile)

	var ring := ColorRect.new()
	ring.name = "Ring"
	ring.color = Color(1, 1, 1, 0)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(ring)

	var badge := Label.new()
	badge.name = "Badge"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 10)
	badge.add_theme_color_override("font_color", Color(1, 1, 1))
	badge.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	badge.add_theme_constant_override("outline_size", 2)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(badge)

	return root


func _content_rect() -> Rect2:
	var pad: float = 8.0
	var avail := Rect2(pad, pad, maxf(1.0, size.x - pad * 2.0), maxf(1.0, size.y - pad * 2.0))
	var ref: Rect2 = BoardAtlas.board_reference_rect()
	if ref.size.x <= 1.0:
		return avail
	var aspect: float = ref.size.x / ref.size.y
	var w: float = avail.size.x
	var h: float = w / aspect
	if h > avail.size.y:
		h = avail.size.y
		w = h * aspect
	var ox: float = avail.position.x + (avail.size.x - w) * 0.5
	var oy: float = avail.position.y + (avail.size.y - h) * 0.5
	return Rect2(ox, oy, w, h)


func _relayout() -> void:
	if _layout.is_empty():
		return
	var content := _content_rect()
	_board_bg.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_board_bg.position = content.position
	_board_bg.size = content.size

	var sx: float = content.size.x / DESIGN_SIZE.x
	var sy: float = content.size.y / DESIGN_SIZE.y
	var scale: float = minf(sx, sy)

	for sector_id: String in _sectors:
		var node: Control = _sectors[sector_id]
		var entry: Dictionary = _layout[sector_id] as Dictionary
		var r: float = float(entry.get("r", 24)) * scale
		var cx: float = content.position.x + float(entry.get("x", 0)) * sx
		var cy: float = content.position.y + float(entry.get("y", 0)) * sy
		node.position = Vector2(cx - r, cy - r)
		node.size = Vector2(r * 2.0, r * 2.0)
		var tile: TextureRect = node.get_node("Tile") as TextureRect
		tile.set_anchors_preset(Control.PRESET_FULL_RECT)
		tile.offset_left = 2
		tile.offset_top = 2
		tile.offset_right = -2
		tile.offset_bottom = -2
		var ring: ColorRect = node.get_node("Ring") as ColorRect
		ring.set_anchors_preset(Control.PRESET_FULL_RECT)
		var badge: Label = node.get_node("Badge") as Label
		badge.set_anchors_preset(Control.PRESET_FULL_RECT)
		_style_ring(ring, sector_id == _selected)

	_piece_layer.position = Vector2.ZERO
	_piece_layer.size = size


func _style_ring(ring: ColorRect, selected: bool) -> void:
	if selected:
		ring.color = Color(1, 0.9, 0.35, 0.35)
	else:
		ring.color = Color(1, 1, 1, 0)


func refresh(state: GameState) -> void:
	_state = state
	for sector_id: String in _sectors:
		var node: Control = _sectors[sector_id]
		var stack: Array[PieceInstance] = state.pieces_on_sector(sector_id)
		var badge: Label = node.get_node("Badge") as Label
		if stack.is_empty():
			badge.text = ""
		else:
			var parts: PackedStringArray = PackedStringArray()
			var counts: Dictionary = {}
			for p: PieceInstance in stack:
				var key: String = GameConstants.camp_to_string(p.camp)[0]
				counts[key] = int(counts.get(key, 0)) + 1
			for key: String in counts:
				parts.append("%s×%d" % [key, int(counts[key])])
			badge.text = " ".join(parts)
		_style_ring(node.get_node("Ring") as ColorRect, sector_id == _selected)
	queue_redraw()


func set_selected(sector_id: String) -> void:
	_selected = sector_id
	for sid: String in _sectors:
		var ring: ColorRect = _sectors[sid].get_node("Ring") as ColorRect
		_style_ring(ring, sid == _selected)


func _on_sector_gui_input(event: InputEvent, sector_id: String) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			set_selected(sector_id)
			sector_pressed.emit(sector_id)


func _draw() -> void:
	if _state == null or _layout.is_empty():
		return
	var content := _content_rect()
	var sx: float = content.size.x / DESIGN_SIZE.x
	var sy: float = content.size.y / DESIGN_SIZE.y
	for sector_id: String in _layout:
		var stack: Array[PieceInstance] = _state.pieces_on_sector(sector_id)
		if stack.is_empty():
			continue
		var entry: Dictionary = _layout[sector_id] as Dictionary
		var cx: float = content.position.x + float(entry.get("x", 0)) * sx
		var cy: float = content.position.y + float(entry.get("y", 0)) * sy
		var n: int = mini(stack.size(), 6)
		for i in range(n):
			var p: PieceInstance = stack[i]
			var off := Vector2(float((i % 3) * 7 - 7), float((i / 3) * 7 - 3))
			draw_circle(Vector2(cx, cy) + off, 5.0 * minf(sx, sy), GameConstants.CAMP_COLORS[p.camp])
