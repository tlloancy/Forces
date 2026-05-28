extends Node
## Musique / SFX — placer FORCE7.mp3 et GoConquer.mp3 dans assets/audio/

const MUSIC_CROSSFADE_SEC: float = 0.55
const MIN_LINEAR: float = 0.001

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active_music: AudioStreamPlayer
var _sfx: AudioStreamPlayer
var _music_tween: Tween
var _loop_active: bool = true
var _ambient_after_intro: bool = false

const TRACK_MENU := "res://assets/audio/FORCE7.mp3"
const TRACK_BATTLE := "res://assets/audio/GoConquer.mp3"


func _ready() -> void:
	_music_a = AudioStreamPlayer.new()
	_music_a.name = "MusicA"
	_music_b = AudioStreamPlayer.new()
	_music_b.name = "MusicB"
	_sfx = AudioStreamPlayer.new()
	_sfx.name = "Sfx"
	add_child(_music_a)
	add_child(_music_b)
	add_child(_sfx)
	_active_music = _music_a
	_music_a.finished.connect(_on_music_finished.bind(_music_a))
	_music_b.finished.connect(_on_music_finished.bind(_music_b))
	_apply_volumes()
	play_menu_music()


func _apply_volumes() -> void:
	var music_db: float = _to_db(GameSession.music_volume)
	var sfx_db: float = _to_db(GameSession.sfx_volume)
	if _active_music:
		_active_music.volume_db = music_db
	if _music_a != null and _music_a != _active_music and _music_a.playing:
		_music_a.volume_db = _to_db(MIN_LINEAR)
	if _music_b != null and _music_b != _active_music and _music_b.playing:
		_music_b.volume_db = _to_db(MIN_LINEAR)
	_sfx.volume_db = sfx_db


func play_menu_music() -> void:
	# Thème menu = ambiance en boucle.
	_ambient_after_intro = false
	_play_music(TRACK_MENU, true)


func play_battle_music() -> void:
	# GoConquer = stinger d'entrée (une seule fois) ; ensuite ambiance bouclée.
	_ambient_after_intro = true
	_play_music(TRACK_BATTLE, false)


func _play_music(path: String, loop: bool) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	_loop_active = loop
	if _active_music != null and _active_music.stream == stream and _active_music.playing:
		return
	var next: AudioStreamPlayer = _music_b if _active_music == _music_a else _music_a
	next.stream = stream
	next.volume_db = _to_db(MIN_LINEAR)
	next.play()
	if _music_tween != null:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(next, "volume_db", _to_db(GameSession.music_volume), MUSIC_CROSSFADE_SEC)
	if _active_music != null and _active_music.playing:
		_music_tween.tween_property(_active_music, "volume_db", _to_db(MIN_LINEAR), MUSIC_CROSSFADE_SEC)
	await _music_tween.finished
	if _active_music != null and _active_music != next:
		_active_music.stop()
	_active_music = next


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


func _on_music_finished(player: AudioStreamPlayer) -> void:
	# Ignore les fins provoquées par un crossfade (la piste active a changé).
	if player != _active_music or player.stream == null:
		return
	if _loop_active:
		player.play()
	elif _ambient_after_intro:
		# Fin du stinger d'entrée → bascule sur l'ambiance bouclée.
		_ambient_after_intro = false
		_play_music(TRACK_MENU, true)


func _to_db(linear: float) -> float:
	return linear_to_db(maxf(linear, MIN_LINEAR))
