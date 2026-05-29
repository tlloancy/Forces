extends Node
## Smoke mesh N joueurs — host attend (max_peers-1) peers WebRTC puis broadcast.
## Env : P2P_NET_MODE=host|join, P2P_NET_ROOM, P2P_NET_MAX_PEERS (def 4), P2P_NET_ROOM_FILE (host)

@export var max_peers: int = 4

const TIMEOUT_SEC := 45.0

var _mode: String = "host"
var _room: String = ""
var _target_peers: int = 3
var _joined: int = 0
var _got_ok: bool = false


func _ready() -> void:
	_mode = OS.get_environment("P2P_NET_MODE") if OS.has_environment("P2P_NET_MODE") else "host"
	_room = OS.get_environment("P2P_NET_ROOM") if OS.has_environment("P2P_NET_ROOM") else ""
	_target_peers = (
		int(OS.get_environment("P2P_NET_MAX_PEERS")) - 1
		if OS.has_environment("P2P_NET_MAX_PEERS")
		else max_peers - 1
	)
	get_tree().create_timer(TIMEOUT_SEC).timeout.connect(_on_timeout)
	if not ClassDB.class_exists("WebRTCMultiplayerPeer"):
		push_error("[P2PNet mesh] WebRTC missing.")
		get_tree().quit(1)
		return
	var cfg = load("res://addons/p2p_net/net_config.gd").defaults()
	cfg.max_peers = _target_peers + 1
	P2PNet.configure(cfg)
	P2PNet.room_ready.connect(_on_room_ready)
	P2PNet.peer_joined.connect(_on_peer_joined)
	P2PNet.message_received.connect(_on_message)
	P2PNet.connection_failed.connect(_on_connection_failed)
	if _mode == "join":
		if _room.is_empty():
			push_error("[P2PNet mesh] join needs P2P_NET_ROOM")
			get_tree().quit(1)
			return
		P2PNet.join_room(_room)
	else:
		P2PNet.host_room(_target_peers + 1)


func _on_connection_failed(reason: String) -> void:
	if _got_ok:
		return
	push_error("[P2PNet mesh] " + reason)
	get_tree().quit(1)


func _on_timeout() -> void:
	if _got_ok:
		return
	push_error("[P2PNet mesh] TIMEOUT mode=%s joined=%d/%d" % [_mode, _joined, _target_peers])
	get_tree().quit(1)


func _on_room_ready(code: String) -> void:
	print("[P2PNet mesh] room=%s peer=%d host=%s" % [code, P2PNet.my_peer_id(), P2PNet.is_host()])
	var room_file := (
		OS.get_environment("P2P_NET_ROOM_FILE") if OS.has_environment("P2P_NET_ROOM_FILE") else ""
	)
	if not room_file.is_empty() and P2PNet.is_host():
		var f := FileAccess.open(room_file, FileAccess.WRITE)
		if f:
			f.store_string(code)


func _on_peer_joined(_peer_id: int) -> void:
	if not P2PNet.is_host():
		P2PNet.send_to(1, "here".to_utf8_buffer())
		return
	_joined += 1
	if _joined >= _target_peers:
		P2PNet.broadcast("mesh_ok".to_utf8_buffer())
		await get_tree().create_timer(1.0).timeout
		_finish_ok()


func _on_message(_from_id: int, data: PackedByteArray) -> void:
	if not P2PNet.is_host() and data.get_string_from_utf8() == "mesh_ok":
		_finish_ok()


func _finish_ok() -> void:
	if _got_ok:
		return
	_got_ok = true
	print("[P2PNet mesh] OK peers=%s" % str(P2PNet.peer_ids()))
	P2PNet.leave()
	get_tree().quit(0)
