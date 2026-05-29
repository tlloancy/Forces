extends Control

@onready var _status: Label = %StatusLabel
@onready var _room_code: LineEdit = %RoomCodeEdit
@onready var _host_btn: Button = %HostButton
@onready var _join_btn: Button = %JoinButton
@onready var _start_btn: Button = %StartButton
@onready var _back_btn: Button = %BackButton
@onready var _panel: PanelContainer = %Panel

var _guest_joined: bool = false


func _ready() -> void:
	MenuTheme.style_panel(_panel)
	for btn: Button in [_host_btn, _join_btn, _start_btn, _back_btn]:
		MenuTheme.style_primary_button(btn)
	_set_status("Host a room or join with a code. Start signaling: addons/p2p_net/server/signaling_server.tscn")
	_start_btn.disabled = true
	if not ForcesNet.is_available():
		_set_status("WebRTC unavailable — install webrtc-native in res://webrtc/ and run --import.")
		_host_btn.disabled = true
		_join_btn.disabled = true
		return
	P2PNet.room_ready.connect(_on_room_ready)
	P2PNet.peer_joined.connect(_on_peer_joined)
	P2PNet.connection_failed.connect(_on_connection_failed)
	P2PNet.room_left.connect(_on_room_left)
	ForcesNet.peer_ready.connect(_on_forces_peer_ready)
	if not GameSession.network_is_host:
		ForcesNet.match_start_received.connect(_on_match_start_received)


func _exit_tree() -> void:
	if P2PNet.is_in_room():
		ForcesNet.leave_lobby()


func _set_status(text: String) -> void:
	if _status:
		_status.text = text


func _on_host_pressed() -> void:
	_guest_joined = false
	_start_btn.disabled = true
	_set_status("Creating room…")
	ForcesNet.host_lobby(4)


func _on_join_pressed() -> void:
	var code: String = _room_code.text.strip_edges()
	if code.is_empty():
		_set_status("Enter a room code.")
		return
	_start_btn.disabled = true
	_set_status("Joining…")
	ForcesNet.join_lobby(code)


func _on_room_ready(code: String) -> void:
	_room_code.text = code
	if GameSession.network_is_host:
		_set_status("Room: %s — waiting for opponent…" % code)
	else:
		_set_status("Joined room %s — waiting for host…" % code)


func _on_peer_joined(_peer_id: int) -> void:
	pass


func _on_forces_peer_ready(peer_id: int) -> void:
	if not GameSession.network_is_host:
		return
	if peer_id == P2PNet.my_peer_id():
		return
	GameSession.register_network_guest(peer_id)
	_guest_joined = true
	_start_btn.disabled = false
	_set_status("Opponent connected. Press Start match.")


func _on_connection_failed(reason: String) -> void:
	_set_status("Error: %s" % reason)
	_start_btn.disabled = true


func _on_room_left() -> void:
	_guest_joined = false
	_start_btn.disabled = true


func _on_start_pressed() -> void:
	if not GameSession.network_is_host or not _guest_joined:
		return
	P2PNet.seal_lobby()
	var config: Dictionary = {
		"human_camp_host": int(GameConstants.Camp.GREEN),
		"human_camp_guest": int(GameConstants.Camp.BLUE),
		"guest_peer": GameSession.network_guest_peer_id,
	}
	ForcesNet.send_match_start(config)
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_match_start_received(_config: Dictionary) -> void:
	if GameSession.network_is_host:
		return
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_back_pressed() -> void:
	ForcesNet.leave_lobby()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
