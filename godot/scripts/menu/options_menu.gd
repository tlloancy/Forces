extends Control

@onready var _music: HSlider = %MusicSlider
@onready var _sfx: HSlider = %SfxSlider


func _ready() -> void:
	_music.value = GameSession.music_volume * 100.0
	_sfx.value = GameSession.sfx_volume * 100.0


func _on_music_changed(value: float) -> void:
	GameSession.music_volume = value / 100.0
	AudioManager.refresh_volumes()


func _on_sfx_changed(value: float) -> void:
	GameSession.sfx_volume = value / 100.0
	AudioManager.refresh_volumes()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
