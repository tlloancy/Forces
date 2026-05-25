extends Control
## Losange du « O » dans FORCES — rotation lente (comme l’UI Unity).

const BoardAtlas = preload("res://scripts/core/board_atlas.gd")

@export var rotation_speed: float = 0.55
@export var icon_size: float = 44.0

var _angle: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(icon_size, icon_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_angle += rotation_speed * delta
	queue_redraw()


func _draw() -> void:
	var tex: AtlasTexture = BoardAtlas.icon_texture("diamond_outline")
	if tex == null or tex.atlas == null:
		return
	var sz := Vector2(icon_size, icon_size)
	var rect := Rect2(-sz * 0.5, sz)
	draw_set_transform(size * 0.5, _angle, Vector2.ONE)
	draw_texture_rect(tex, rect, false, Color(0.92, 0.93, 0.96, 0.95))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
