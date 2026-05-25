extends Control
## « O » du titre FORCES — losange atlas (Unity General_Menu/O + O_Animate).

@export var rotate_speed: float = 120.0
@export var snap_interval_sec: float = 1.0
@export var icon_size: float = 44.0

var _angle: float = 0.0
var _tex: AtlasTexture


func _ready() -> void:
	custom_minimum_size = Vector2(icon_size, icon_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Losange réel = _16/_21 — pas _18 (lettre F du titre).
	_tex = BoardAtlas.icon_texture("diamond_filled")
	if _tex == null or _tex.atlas == null:
		_tex = BoardAtlas.icon_texture("diamond_outline")


func _process(delta: float) -> void:
	var direction: float = -1.0
	_angle += deg_to_rad(rotate_speed * direction) * delta
	var tick: int = int(Time.get_ticks_msec() / 1000.0 / snap_interval_sec)
	if tick % 2 > 0:
		_angle = 0.0
	queue_redraw()


func _draw() -> void:
	if _tex == null or _tex.atlas == null:
		return
	var center := size * 0.5
	draw_set_transform(center, _angle, Vector2.ONE)
	var sz := Vector2(icon_size * 1.12, icon_size * 1.12)
	draw_texture_rect(_tex, Rect2(-sz * 0.5, sz), false, Color(0.95, 0.96, 1.0, 0.98))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
