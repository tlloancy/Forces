extends Node
## Musique / SFX — placer FORCE7.mp3 et GoConquer.mp3 dans assets/audio/

var _music: AudioStreamPlayer
var _sfx: AudioStreamPlayer

const TRACK_MENU := "res://assets/audio/FORCE7.mp3"
const TRACK_BATTLE := "res://assets/audio/GoConquer.mp3"


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	_sfx = AudioStreamPlayer.new()
	_sfx.name = "Sfx"
	add_child(_music)
	add_child(_sfx)
	_apply_volumes()
	play_menu_music()


func _apply_volumes() -> void:
	_music.volume_db = linear_to_db(GameSession.music_volume)
	_sfx.volume_db = linear_to_db(GameSession.sfx_volume)


func play_menu_music() -> void:
	_play_music(TRACK_MENU)


func play_battle_music() -> void:
	_play_music(TRACK_BATTLE)


func _play_music(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	if _music.stream == stream and _music.playing:
		return
	_music.stream = stream
	_music.play()


func play_sfx(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	_sfx.stream = stream
	_sfx.play()


func refresh_volumes() -> void:
	_apply_volumes()
