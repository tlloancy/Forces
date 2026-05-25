extends Control
## « O » de FORCES — losange atlas, rotation mécanique (pas lisse).

@export var step_degrees: float = 45.0
@export var step_interval: float = 0.13
@export var icon_size: float = 44.0
@export var wobble_degrees: float = 4.0

var _angle: float = 0.0
var _step: int = 0
var _wobble: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(icon_size, icon_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var timer := Timer.new()
	timer.name = "StepTimer"
	timer.wait_time = step_interval
	timer.autostart = true
	timer.timeout.connect(_on_step)
	add_child(timer)


func _on_step() -> void:
	_step += 1
	_angle = deg_to_rad(_step * step_degrees)
	_wobble = deg_to_rad(randf_range(-wobble_degrees, wobble_degrees))
	queue_redraw()


func _draw() -> void:
	var tex: AtlasTexture = BoardAtlas.icon_texture("diamond_filled")
	if tex == null or tex.atlas == null:
		tex = BoardAtlas.icon_texture("diamond_outline")
	if tex == null or tex.atlas == null:
		return
	var center := size * 0.5
	draw_set_transform(center, _angle + _wobble, Vector2.ONE)
	var sz := Vector2(icon_size, icon_size)
	draw_texture_rect(tex, Rect2(-sz * 0.5, sz), false, Color(0.95, 0.96, 1.0, 0.98))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
