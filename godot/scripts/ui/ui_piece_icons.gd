class_name UiPieceIcons
extends RefCounted
## Boutons / labels UI avec textures atlas (plus de ● ■ ▲ ◆ en dur).

const BASIC_TYPES: Array[GameConstants.PieceType] = [
	GameConstants.PieceType.SOLDIER,
	GameConstants.PieceType.RAIDER,
	GameConstants.PieceType.HUNTER,
	GameConstants.PieceType.CRUISER,
]

const EXCHANGE_RESULTS: Array[GameConstants.PieceType] = [
	GameConstants.PieceType.COMMANDO,
	GameConstants.PieceType.BOMBER,
	GameConstants.PieceType.FIGHTER,
	GameConstants.PieceType.DESTROYER,
]


static func texture_for_piece(piece_type: GameConstants.PieceType, filled: bool = true) -> Texture2D:
	var key: String = BoardAtlas.piece_shape_key(piece_type, filled)
	var atlas_tex: AtlasTexture = BoardAtlas.icon_texture(key)
	if atlas_tex != null:
		return atlas_tex
	return null


static func texture_hbomb() -> Texture2D:
	return BoardAtlas.icon_texture("hbomb")


static func apply_button_icon(btn: Button, tex: Texture2D, caption: String = "") -> void:
	if tex != null:
		btn.icon = tex
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn.text = caption


static func setup_buy_button(btn: Button, piece_type: GameConstants.PieceType, power_cost: int) -> void:
	apply_button_icon(btn, texture_for_piece(piece_type, true), str(power_cost))


static func setup_exchange_button(
	btn: Button,
	from_type: GameConstants.PieceType,
	to_type: GameConstants.PieceType,
) -> void:
	for child: Node in btn.get_children():
		child.queue_free()
	btn.text = ""
	btn.custom_minimum_size = Vector2(40, 32)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 2)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for _i in 3:
		row.add_child(_make_icon_rect(texture_for_piece(from_type, true), 14))
	row.add_child(_make_icon_rect(texture_for_piece(to_type, true), 16))
	btn.add_child(row)


static func _make_icon_rect(tex: Texture2D, size_px: float) -> TextureRect:
	var tr := TextureRect.new()
	tr.custom_minimum_size = Vector2(size_px, size_px)
	tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tex != null:
		tr.texture = tex
	return tr


static func make_unit_button(piece_type: GameConstants.PieceType, count: int) -> Button:
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(44, 36)
	apply_button_icon(btn, texture_for_piece(piece_type, true), str(count))
	btn.add_theme_font_size_override("font_size", 13)
	return btn
