class_name PowerToast
extends CanvasLayer
## Popup centre écran — gains Power, dépenses, recrutement.

var _panel: PanelContainer
var _headline: Label
var _detail: Label
var _balance: Label
var _hide_tween: Tween


func _ready() -> void:
	layer = 8
	_build_ui()
	visible = false
	_panel.modulate.a = 0.0


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(320, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_panel)

	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.04, 0.06, 0.12, 0.94)
	box.border_color = Color(1.0, 0.88, 0.35, 0.85)
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 16
	box.content_margin_bottom = 16
	_panel.add_theme_stylebox_override("panel", box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	_headline = Label.new()
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.add_theme_font_size_override("font_size", 28)
	vbox.add_child(_headline)

	_detail = Label.new()
	_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_theme_font_size_override("font_size", 15)
	_detail.add_theme_color_override("font_color", Color(0.75, 0.8, 0.88))
	vbox.add_child(_detail)

	_balance = Label.new()
	_balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_balance.add_theme_font_size_override("font_size", 18)
	_balance.add_theme_color_override("font_color", Color(1.0, 0.92, 0.38))
	vbox.add_child(_balance)


func show_gain(amount: int, subtitle: String, balance: int) -> void:
	_popup("⚡ +%d" % amount, subtitle, "Balance: ⚡ %d" % balance, Color(1.0, 0.92, 0.35))


func show_spend(amount: int, subtitle: String, balance: int) -> void:
	_popup("⚡ −%d" % amount, subtitle, "Balance: ⚡ %d" % balance, Color(1.0, 0.55, 0.42))


func show_recruit(piece_type: GameConstants.PieceType, balance: int) -> void:
	var label: String = GameConstants.piece_type_label(piece_type)
	_popup("+%s" % label, "Recruited — added to RESERVE", "Balance: ⚡ %d" % balance, Color(0.55, 0.92, 0.65))


func show_capture(piece_type: GameConstants.PieceType, balance: int) -> void:
	var label: String = GameConstants.piece_type_label(piece_type)
	_popup("+%s" % label, "Captured — added to RESERVE", "Balance: ⚡ %d" % balance, Color(0.55, 0.92, 0.65))


func _popup(headline: String, detail: String, balance_line: String, color: Color) -> void:
	if _hide_tween != null and _hide_tween.is_valid():
		_hide_tween.kill()

	_headline.text = headline
	_headline.add_theme_color_override("font_color", color)
	_detail.text = detail
	_balance.text = balance_line

	visible = true
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.82, 0.82)
	call_deferred("_center_popup_pivot")

	var in_tween := create_tween()
	in_tween.set_parallel(true)
	in_tween.set_ease(Tween.EASE_OUT)
	in_tween.set_trans(Tween.TRANS_BACK)
	in_tween.tween_property(_panel, "modulate:a", 1.0, 0.28)
	in_tween.tween_property(_panel, "scale", Vector2.ONE, 0.32)

	_hide_tween = create_tween()
	_hide_tween.tween_interval(2.4)
	_hide_tween.tween_property(_panel, "modulate:a", 0.0, 0.45)
	_hide_tween.tween_callback(func() -> void: visible = false)


func _center_popup_pivot() -> void:
	if _panel:
		_panel.pivot_offset = _panel.size * 0.5
