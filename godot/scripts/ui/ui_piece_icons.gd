class_name UiPieceIcons
extends RefCounted
## Icônes UI — formes atlas (jamais les portraits unité type « H » bombe).

const BASIC_TYPES: Array[GameConstants.PieceType] = [
	GameConstants.PieceType.SOLDIER,
	GameConstants.PieceType.RAIDER,
	GameConstants.PieceType.HUNTER,
	GameConstants.PieceType.CRUISER,
]


static func texture_shape(shape_key: String) -> Texture2D:
	return BoardAtlas.icon_texture(shape_key)


## Portrait de l'unité (illustration réelle dans l'atlas) — utilisé dans les boutons achat/count.
static func texture_portrait(piece_type: GameConstants.PieceType) -> Texture2D:
	match piece_type:
		GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO:
			return BoardAtlas.icon_texture("soldier")
		GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER:
			return BoardAtlas.icon_texture("raider")
		GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER:
			return BoardAtlas.icon_texture("hunter")
		GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER:
			return BoardAtlas.icon_texture("cruiser")
		GameConstants.PieceType.HBOMB:
			return BoardAtlas.icon_texture("hbomb")
		_:
			return BoardAtlas.icon_texture("soldier")


static func texture_for_piece(piece_type: GameConstants.PieceType, filled: bool = true) -> Texture2D:
	match piece_type:
		GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO:
			return texture_shape("circle_filled" if filled else "circle_outline")
		GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER:
			return texture_shape("square_filled" if filled else "square_outline")
		GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER:
			return texture_shape("triangle_filled" if filled else "triangle_outline")
		GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER:
			return texture_shape("diamond_filled" if filled else "diamond_outline")
		GameConstants.PieceType.HBOMB:
			return texture_shape("hbomb_h")
		_:
			return texture_shape("circle_filled")


static func texture_hbomb() -> Texture2D:
	return texture_shape("hbomb_h")


static func setup_hbomb_button(btn: Button) -> void:
	for child: Node in btn.get_children():
		child.queue_free()
	btn.icon = null
	btn.text = ""
	btn.custom_minimum_size = Vector2(56, 32)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 3)
	row.add_child(_make_icon_rect(texture_hbomb(), 16))
	var cap := Label.new()
	cap.text = "100"
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.add_theme_font_size_override("font_size", 12)
	row.add_child(cap)
	btn.add_child(row)


static func apply_button_icon(btn: Button, _tex: Texture2D, caption: String = "") -> void:
	btn.icon = null
	btn.text = caption


## Bouton achat : forme outline + coût "P2" doré.
static func setup_buy_button(btn: Button, piece_type: GameConstants.PieceType, power_cost: int) -> void:
	for child: Node in btn.get_children():
		child.queue_free()
	btn.text = ""
	btn.custom_minimum_size = Vector2(44, 36)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 1)
	col.add_child(_make_icon_rect(texture_for_piece(piece_type, false), 18))
	var cost := Label.new()
	cost.text = "P%d" % power_cost
	cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost.add_theme_font_size_override("font_size", 10)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.add_theme_color_override("font_color", Color(0.95, 0.82, 0.38))
	col.add_child(cost)
	btn.add_child(col)


static func setup_exchange_button(
	btn: Button,
	from_type: GameConstants.PieceType,
	to_type: GameConstants.PieceType,
) -> void:
	for child: Node in btn.get_children():
		child.queue_free()
	btn.text = ""
	btn.custom_minimum_size = Vector2(52, 30)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 2)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(_make_icon_rect(texture_for_piece(from_type, true), 14))
	var mid := Label.new()
	mid.text = "×3›"
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mid.add_theme_font_size_override("font_size", 11)
	row.add_child(mid)
	row.add_child(_make_icon_rect(texture_for_piece(to_type, true), 14))
	btn.add_child(row)


static func _make_icon_rect(tex: Texture2D, size_px: float) -> TextureRect:
	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(size_px, size_px)
	icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tex != null:
		icon_rect.texture = tex
	return icon_rect


## Bouton unité sur la case : outline basique / filled élite, teinté par camp.
static func make_unit_button(
	piece_type: GameConstants.PieceType,
	count: int,
	camp_color: Color = Color.WHITE,
) -> Button:
	var filled: bool = piece_type not in BASIC_TYPES
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = ""
	btn.custom_minimum_size = Vector2(36, 36)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 1)
	var icon_rect := _make_icon_rect(texture_for_piece(piece_type, filled), 18)
	icon_rect.modulate = camp_color
	col.add_child(icon_rect)
	var lbl := Label.new()
	lbl.text = "×%d" % count
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", camp_color)
	col.add_child(lbl)
	btn.add_child(col)
	return btn
