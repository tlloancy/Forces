class_name LoadingScreen
extends CanvasLayer
## Full-screen load overlay — threaded scene load with progress.

@onready var _bar: ProgressBar = %ProgressBar
@onready var _hint: Label = %HintLabel


func _ready() -> void:
	layer = 100
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _bar:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.16, 0.22)
		sb.corner_radius_top_left = 3
		sb.corner_radius_top_right = 3
		sb.corner_radius_bottom_left = 3
		sb.corner_radius_bottom_right = 3
		_bar.add_theme_stylebox_override("background", sb)
		var fill := sb.duplicate() as StyleBoxFlat
		fill.bg_color = Color(0.82, 0.68, 0.22)
		_bar.add_theme_stylebox_override("fill", fill)


func show_and_load(scene_path: String, hint: String = "Loading…") -> void:
	visible = true
	_bar.value = 0.0
	_hint.text = hint
	ResourceLoader.load_threaded_request(scene_path)
	while true:
		var st: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_path)
		match st:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				var prog: Array = []
				ResourceLoader.load_threaded_get_status(scene_path, prog)
				if prog.size() > 0:
					_bar.value = float(prog[0]) * 100.0
			ResourceLoader.THREAD_LOAD_LOADED:
				_bar.value = 100.0
				break
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("LoadingScreen: failed to load %s" % scene_path)
				visible = false
				return
		await get_tree().process_frame
	var packed: PackedScene = ResourceLoader.load_threaded_get(scene_path) as PackedScene
	if packed == null:
		push_error("LoadingScreen: null scene %s" % scene_path)
		visible = false
		return
	get_tree().change_scene_to_packed(packed)
