class_name UiPieceIcons
extends RefCounted
## Icônes UI — puces plateau (PieceChip) + atlas.

const PieceChipScript = preload("res://scripts/ui/piece_chip.gd")
const CHIP_BUY := PieceChipScript.CHIP_MD
const CHIP_ACTION := PieceChipScript.CHIP_SM

const BASIC_TYPES: Array[GameConstants.PieceType] = [
	GameConstants.PieceType.SOLDIER,
	GameConstants.PieceType.RAIDER,
	GameConstants.PieceType.HUNTER,
	GameConstants.PieceType.CRUISER,
]


static func texture_shape(shape_key: String) -> Texture2D:
	return BoardAtlas.icon_texture(shape_key)


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


static func texture_for_piece(piece_type: GameConstants.PieceType, _filled: bool = true) -> Texture2D:
	return BoardAtlas.piece_board_texture(piece_type)


static func texture_hbomb() -> Texture2D:
	return texture_shape("hbomb_h")


static func _clear_btn(btn: Button, min_size: Vector2) -> void:
	for child: Node in btn.get_children():
		child.queue_free()
	btn.icon = null
	btn.text = ""
	btn.custom_minimum_size = min_size
	btn.expand_icon = false


static func _attach_chip(btn: Button, chip: Control) -> void:
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.set_anchors_preset(Control.PRESET_CENTER)
	btn.add_child(chip)


static func setup_hbomb_button(btn: Button) -> void:
	_clear_btn(btn, Vector2(CHIP_BUY + 12.0, CHIP_BUY + 8.0))
	var chip: PieceChip = PieceChipScript.new().configure(
		GameConstants.PieceType.HBOMB,
		Color(0.95, 0.45, 0.35),
		1,
		CHIP_BUY - 4.0,
		false,
		-1,
	)
	chip.show_badge = false
	_attach_chip(btn, chip)


static func setup_buy_button(btn: Button, piece_type: GameConstants.PieceType, power_cost: int) -> void:
	_clear_btn(btn, Vector2(CHIP_BUY + 4.0, CHIP_BUY + 18.0))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 2)
	var chip: PieceChip = PieceChipScript.new().configure(
		piece_type,
		Color(0.82, 0.86, 0.92),
		1,
		CHIP_BUY - 2.0,
		false,
		-1,
	)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(chip)
	var cost_lbl := Label.new()
	cost_lbl.text = "−%d" % power_cost
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 12)
	cost_lbl.add_theme_color_override("font_color", Color(0.98, 0.88, 0.45))
	cost_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(cost_lbl)
	btn.add_child(col)
	btn.tooltip_text = "%s → reserve (−%d ⚡)" % [
		GameConstants.piece_type_label(piece_type),
		power_cost,
	]


static func setup_deploy_button(btn: Button) -> void:
	_clear_btn(btn, Vector2(CHIP_BUY, CHIP_BUY))
	var chip: PieceChip = PieceChipScript.new().configure(
		GameConstants.PieceType.SOLDIER,
		Color(0.45, 0.92, 0.55),
		1,
		CHIP_BUY - 4.0,
		false,
	)
	chip.show_badge = false
	_attach_chip(btn, chip)


static func setup_exchange_button(
	btn: Button,
	from_type: GameConstants.PieceType,
	to_type: GameConstants.PieceType,
) -> void:
	_clear_btn(btn, Vector2(CHIP_BUY + 28.0, CHIP_BUY))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 0)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var from_chip: PieceChip = PieceChipScript.new().configure(from_type, Color(0.75, 0.78, 0.85), 3, CHIP_ACTION, false)
	from_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	from_chip.show_badge = true
	row.add_child(from_chip)
	var arrow := Label.new()
	arrow.text = "›"
	arrow.add_theme_font_size_override("font_size", 16)
	arrow.add_theme_color_override("font_color", Color(0.95, 0.82, 0.38))
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(arrow)
	var to_chip: PieceChip = PieceChipScript.new().configure(to_type, Color(0.95, 0.82, 0.45), 1, CHIP_ACTION, false)
	to_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	to_chip.show_badge = false
	row.add_child(to_chip)
	btn.add_child(row)


static func apply_button_icon(btn: Button, _tex: Texture2D, caption: String = "") -> void:
	btn.icon = null
	btn.text = caption


static func make_unit_button(
	piece_type: GameConstants.PieceType,
	count: int,
	camp_color: Color = Color.WHITE,
) -> Button:
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(CHIP_BUY, CHIP_BUY)
	var chip: PieceChip = PieceChipScript.new().configure(piece_type, camp_color, count, CHIP_BUY, false)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_attach_chip(btn, chip)
	return btn
