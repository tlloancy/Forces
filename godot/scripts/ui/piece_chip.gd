class_name PieceChip
extends Control
## Unité cliquable — même rendu que les pièces sur le plateau (disque camp + portrait atlas).

signal chip_pressed

const CHIP_SM := 44.0
const CHIP_MD := 52.0
const CHIP_LG := 64.0

var piece_type: GameConstants.PieceType = GameConstants.PieceType.SOLDIER
var camp_color: Color = Color.WHITE
var stack_count: int = 1
var chip_size: float = CHIP_MD
var highlighted: bool = false
var show_badge: bool = true
var power_cost: int = -1


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE


func configure(
	p_type: GameConstants.PieceType,
	p_camp: Color,
	count: int = 1,
	size_px: float = CHIP_MD,
	p_highlight: bool = false,
	p_cost: int = -1,
) -> PieceChip:
	piece_type = p_type
	camp_color = p_camp
	stack_count = count
	chip_size = size_px
	highlighted = p_highlight
	power_cost = p_cost
	custom_minimum_size = Vector2(chip_size, chip_size)
	size = custom_minimum_size
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	tooltip_text = GameConstants.piece_type_label(p_type)
	if count > 1:
		tooltip_text += " ×%d" % count
	if p_cost >= 0:
		tooltip_text += " — cost %d" % p_cost
	queue_redraw()
	return self


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		var row := get_parent()
		if row != null and row.has_method("queue_sort"):
			row.call("queue_sort")


func _draw() -> void:
	var center := size * 0.5
	var icon_size := chip_size * 0.42
	_draw_backing(center, icon_size, camp_color)
	_draw_portrait(center, icon_size, piece_type, camp_color)
	if show_badge and stack_count > 1:
		_draw_badge(center, icon_size, stack_count)
	if power_cost >= 0:
		_draw_cost_badge(center, icon_size, power_cost)
	if highlighted:
		_draw_highlight(center, icon_size)


func _draw_backing(center: Vector2, icon_size: float, color: Color) -> void:
	var r := icon_size * 1.08
	draw_circle(center, r + 2.0, Color(0.02, 0.03, 0.06, 0.72))
	draw_circle(center, r, Color(color.r, color.g, color.b, 0.48))
	_draw_ring(center, r, Color(color.r, color.g, color.b, 0.98), 2.0)


func _draw_portrait(center: Vector2, icon_size: float, p_type: GameConstants.PieceType, color: Color) -> void:
	var tex: AtlasTexture = BoardAtlas.piece_board_texture(p_type)
	if tex == null or tex.atlas == null:
		return
	var tw: float = maxf(1.0, float(tex.get_width()))
	var th: float = maxf(1.0, float(tex.get_height()))
	var h := icon_size * 1.15
	var w := h * (tw / th)
	draw_texture_rect(tex, Rect2(center - Vector2(w * 0.5, h * 0.5), Vector2(w, h)), false, color)


func _draw_badge(center: Vector2, icon_size: float, count: int) -> void:
	var pos := center + Vector2(icon_size * 0.72, -icon_size * 0.72)
	var r := maxf(8.0, icon_size * 0.38)
	draw_circle(pos, r, Color(0.04, 0.05, 0.09, 0.94))
	_draw_ring(pos, r, Color(1, 1, 1, 0.85), 1.0)
	var font := ThemeDB.fallback_font
	var fsize := int(maxf(10.0, r * 1.05))
	var txt := str(count)
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, fsize).x
	draw_string(font, pos + Vector2(-tw * 0.5, fsize * 0.34), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color(1, 1, 1, 0.98))


func _draw_cost_badge(center: Vector2, icon_size: float, cost: int) -> void:
	var pos := center + Vector2(0, icon_size * 0.92)
	var txt := str(cost)
	var font := ThemeDB.fallback_font
	var fsize := int(maxf(9.0, icon_size * 0.32))
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, fsize).x
	var pad := Vector2(tw * 0.5 + 4.0, fsize * 0.55)
	draw_rect(Rect2(pos - pad, pad * 2.0), Color(0.05, 0.06, 0.1, 0.88), true)
	draw_rect(Rect2(pos - pad, pad * 2.0), Color(0.95, 0.82, 0.38, 0.75), false, 1.0)
	draw_string(font, pos + Vector2(-tw * 0.5, fsize * 0.32), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color(0.98, 0.88, 0.45))


func _draw_highlight(center: Vector2, icon_size: float) -> void:
	var r := icon_size * 1.22
	_draw_ring(center, r, Color(1.0, 0.92, 0.45, 0.95), 2.5)


func _draw_ring(center: Vector2, radius: float, color: Color, width: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var steps := 24
	for i in range(steps + 1):
		var a := TAU * float(i) / float(steps)
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	draw_polyline(pts, color, width, true)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			chip_pressed.emit()
			accept_event()
