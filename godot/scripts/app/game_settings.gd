extends Node
## Persistance locale (volumes, etc.) — user://forces_settings.cfg

const CFG_PATH := "user://forces_settings.cfg"


func _ready() -> void:
	load_into_session()


func load_into_session() -> void:
	var file := ConfigFile.new()
	if file.load(CFG_PATH) != OK:
		return
	GameSession.music_volume = clampf(float(file.get_value("audio", "music", 0.8)), 0.0, 1.0)
	GameSession.sfx_volume = clampf(float(file.get_value("audio", "sfx", 0.8)), 0.0, 1.0)


func save_from_session() -> void:
	var file := ConfigFile.new()
	file.set_value("audio", "music", GameSession.music_volume)
	file.set_value("audio", "sfx", GameSession.sfx_volume)
	file.save(CFG_PATH)
