extends Control
## Carte cliquable des 56 secteurs (positions depuis sector_layout.json).

signal sector_pressed(sector_id: String)

var _layout: Dictionary = {}
var _buttons: Dictionary = {}
var _selected: String = ""


func _ready() -> void:
	_load_layout()
	_build_map()
	resized.connect(_relayout)


func _load_layout() -> void:
	var path := "res://data/sector_layout.json"
	if not FileAccess.file_exists(path):
		push_error("Missing sector_layout.json")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) == TYPE_DICTIONARY:
		_layout = parsed as Dictionary


func _build_map() -> void:
	for child in get_children():
		child.queue_free()
	_buttons.clear()
	var ocean := ColorRect.new()
	ocean.name = "Ocean"
	ocean.color = MenuTheme.BG_MAP
	ocean.set_anchors_preset(Control.PRESET_FULL_RECT)
	ocean.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ocean)
	for sector_id: String in BoardCatalog.SECTOR_IDS:
		var entry: Variant = _layout.get(sector_id, null)
		if entry == null or typeof(entry) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = entry as Dictionary
		var btn := Button.new()
		btn.name = sector_id
		btn.text = _short_label(sector_id)
		btn.tooltip_text = sector_id
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_sector_pressed.bind(sector_id))
		add_child(btn)
		_buttons[sector_id] = btn
		_style_button(btn, sector_id, false)
	_relayout()


func _relayout() -> void:
	if _layout.is_empty():
		return
	var scale_x: float = size.x / 1000.0
	var scale_y: float = size.y / 700.0
	for sector_id: String in _buttons:
		var btn: Button = _buttons[sector_id]
		var entry: Dictionary = _layout[sector_id] as Dictionary
		var r: float = float(entry.get("r", 24)) * minf(scale_x, scale_y)
		var cx: float = float(entry.get("x", 0)) * scale_x
		var cy: float = float(entry.get("y", 0)) * scale_y
		btn.custom_minimum_size = Vector2(r * 2.0, r * 2.0)
		btn.position = Vector2(cx - r, cy - r)
		btn.size = Vector2(r * 2.0, r * 2.0)


func _short_label(sector_id: String) -> String:
	if sector_id.begins_with("HQ_"):
		return sector_id.substr(3, 1)
	if sector_id.begins_with("Space_"):
		return "S" + sector_id.substr(6)
	if sector_id.begins_with("Moon_"):
		return "M"
	if sector_id == "Sun":
		return "☀"
	var parts: PackedStringArray = sector_id.split("_")
	if parts.size() >= 2:
		return parts[1].substr(0, 1)
	return "?"


func _style_button(btn: Button, sector_id: String, selected: bool) -> void:
	var camp: GameConstants.Camp = BoardCatalog.camp_for_sector(sector_id)
	var base: Color = GameConstants.CAMP_COLORS[camp]
	if BoardCatalog.sector_kind(sector_id) == GameConstants.SectorKind.SEA:
		base = Color(0.15, 0.35, 0.55)
	elif BoardCatalog.is_neutral(sector_id):
		base = Color(0.45, 0.45, 0.5)
	if selected:
		base = base.lightened(0.35)
	var sb := StyleBoxFlat.new()
	sb.bg_color = base
	sb.corner_radius_top_left = 999
	sb.corner_radius_top_right = 999
	sb.corner_radius_bottom_left = 999
	sb.corner_radius_bottom_right = 999
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(1, 1, 1, 0.85 if selected else 0.25)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_font_size_override("font_size", 11)


func refresh(state: GameState) -> void:
	for sector_id: String in _buttons:
		var btn: Button = _buttons[sector_id]
		var stack: Array[PieceInstance] = state.pieces_on_sector(sector_id)
		var reserve_count: int = 0
		for p: PieceInstance in state.pieces:
			if p.in_reserve and p.sector_id == sector_id and p.camp == state.human_camp:
				reserve_count += 1
		var label: String = _short_label(sector_id)
		if not stack.is_empty():
			label += "(%d)" % stack.size()
		if reserve_count > 0:
			label += "+" + str(reserve_count)
		btn.text = label
		_style_button(btn, sector_id, sector_id == _selected)


func set_selected(sector_id: String) -> void:
	_selected = sector_id
	for sid: String in _buttons:
		_style_button(_buttons[sid], sid, sid == _selected)


func _on_sector_pressed(sector_id: String) -> void:
	set_selected(sector_id)
	sector_pressed.emit(sector_id)
