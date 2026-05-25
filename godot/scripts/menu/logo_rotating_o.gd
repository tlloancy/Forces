extends Control
## Losange du « O » dans FORCES — rotation lente.

const BoardAtlas = preload("res://scripts/core/board_atlas.gd")

@export var rotation_speed: float = 0.55
@export var icon_size: float = 44.0
## Losange plat (menu) ; désactivé = texture atlas (peut contenir un motif interne).
@export var plain_rhombus: bool = true

var _angle: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(icon_size, icon_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_angle += rotation_speed * delta
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_set_transform(center, _angle, Vector2.ONE)
	if plain_rhombus:
		var h := icon_size * 0.42
		var w := icon_size * 0.36
		var pts := PackedVector2Array([
			Vector2(0, -h),
			Vector2(w, 0),
			Vector2(0, h),
			Vector2(-w, 0),
		])
		draw_colored_polygon(pts, Color(0.92, 0.93, 0.96, 0.95))
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0.82, 0.68, 0.22, 0.9), 2.0)
	else:
		var tex: AtlasTexture = BoardAtlas.icon_texture("diamond_outline")
		if tex != null and tex.atlas != null:
			var sz := Vector2(icon_size, icon_size)
			draw_texture_rect(tex, Rect2(-sz * 0.5, sz), false, Color(0.92, 0.93, 0.96, 0.95))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
