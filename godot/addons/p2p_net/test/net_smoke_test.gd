extends Node
## Smoke test headless : host crée une salle, join reçoit ping/pong.
## Env : P2P_NET_MODE=host|join, P2P_NET_ROOM=code, P2P_NET_ROOM_FILE=path (host écrit le code)

@export var mode: String = "host"
@export var room_code: String = ""

const TIMEOUT_SEC := 25.0

var _got_ok: bool = false
var _mode: String = "host"
var _room: String = ""


func _ready() -> void:
	_mode = OS.get_environment("P2P_NET_MODE") if OS.has_environment("P2P_NET_MODE") else mode
	_room = OS.get_environment("P2P_NET_ROOM") if OS.has_environment("P2P_NET_ROOM") else room_code
	get_tree().create_timer(TIMEOUT_SEC).timeout.connect(_on_timeout)
	if not ClassDB.class_exists("WebRTCMultiplayerPeer"):
		push_error("[P2PNet smoke] WebRTC missing — install webrtc-native (Windows DLL in webrtc/lib/).")
		get_tree().quit(1)
		return
	P2PNet.configure(load("res://addons/p2p_net/net_config.gd").defaults())
	P2PNet.room_ready.connect(_on_room_ready)
	P2PNet.peer_joined.connect(_on_peer_joined)
	P2PNet.message_received.connect(_on_message)
	P2PNet.connection_failed.connect(_on_connection_failed)
	if _mode == "join":
		if _room.is_empty():
			push_error("[P2PNet smoke] join mode needs P2P_NET_ROOM")
			get_tree().quit(1)
			return
		P2PNet.join_room(_room)
	else:
		var max_peers := 4
		if OS.has_environment("P2P_NET_MAX_PEERS"):
			max_peers = int(OS.get_environment("P2P_NET_MAX_PEERS"))
		P2PNet.host_room(max_peers)


func _on_connection_failed(reason: String) -> void:
	if _got_ok:
		return
	push_error("[P2PNet smoke] " + reason)
	get_tree().quit(1)


func _on_timeout() -> void:
	if _got_ok:
		return
	push_error("[P2PNet smoke] TIMEOUT after %ss (mode=%s)" % [TIMEOUT_SEC, _mode])
	get_tree().quit(1)


func _on_room_ready(code: String) -> void:
	print("[P2PNet smoke] room=%s peer=%d host=%s" % [code, P2PNet.my_peer_id(), P2PNet.is_host()])
	var room_file: String = (
		OS.get_environment("P2P_NET_ROOM_FILE") if OS.has_environment("P2P_NET_ROOM_FILE") else ""
	)
	if not room_file.is_empty() and _mode == "host":
		var f := FileAccess.open(room_file, FileAccess.WRITE)
		if f:
			f.store_string(code)


func _on_peer_joined(peer_id: int) -> void:
	if P2PNet.is_host():
		P2PNet.broadcast("ping".to_utf8_buffer())
	elif peer_id == 1:
		P2PNet.send_to(1, "hello".to_utf8_buffer())


func _on_message(from_id: int, data: PackedByteArray) -> void:
	var text: String = data.get_string_from_utf8()
	print("[P2PNet smoke] msg from %d: %s" % [from_id, text])
	if text == "ping" and not P2PNet.is_host():
		_finish_ok()
	elif text == "hello" and P2PNet.is_host():
		await get_tree().create_timer(1.0).timeout
		_finish_ok()


func _finish_ok() -> void:
	if _got_ok:
		return
	_got_ok = true
	print("[P2PNet smoke] OK")
	P2PNet.leave()
	get_tree().quit(0)
