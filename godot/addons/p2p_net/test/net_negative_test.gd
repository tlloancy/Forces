extends Node
## Tests negatifs headless — env P2P_NET_TEST=invalid_room|room_full|seal

const TIMEOUT_SEC := 15.0

var _test: String = ""
var _mode: String = ""
var _room: String = ""
var _done: bool = false


func _ready() -> void:
	_test = OS.get_environment("P2P_NET_TEST") if OS.has_environment("P2P_NET_TEST") else ""
	_mode = OS.get_environment("P2P_NET_MODE") if OS.has_environment("P2P_NET_MODE") else "client"
	_room = OS.get_environment("P2P_NET_ROOM") if OS.has_environment("P2P_NET_ROOM") else ""
	get_tree().create_timer(TIMEOUT_SEC).timeout.connect(_on_timeout)
	if not ClassDB.class_exists("WebRTCMultiplayerPeer"):
		push_error("[P2PNet negative] WebRTC missing.")
		get_tree().quit(1)
		return
	if _test.is_empty():
		push_error("[P2PNet negative] P2P_NET_TEST required.")
		get_tree().quit(1)
		return
	var cfg = load("res://addons/p2p_net/net_config.gd").defaults()
	if OS.has_environment("P2P_NET_MAX_PEERS"):
		cfg.max_peers = int(OS.get_environment("P2P_NET_MAX_PEERS"))
	P2PNet.configure(cfg)
	P2PNet.room_ready.connect(_on_room_ready)
	P2PNet.room_sealed.connect(_on_room_sealed)
	P2PNet.connection_failed.connect(_on_connection_failed)
	match _test:
		"invalid_room":
			P2PNet.join_room("___INVALID_ROOM___")
		"room_full":
			if _room.is_empty():
				push_error("[P2PNet negative] room_full needs P2P_NET_ROOM")
				get_tree().quit(1)
				return
			P2PNet.join_room(_room)
		"seal":
			if _mode == "host":
				var max_peers := 4
				if OS.has_environment("P2P_NET_MAX_PEERS"):
					max_peers = int(OS.get_environment("P2P_NET_MAX_PEERS"))
				P2PNet.host_room(max_peers)
			else:
				if _room.is_empty():
					push_error("[P2PNet negative] seal join needs P2P_NET_ROOM")
					get_tree().quit(1)
					return
				P2PNet.join_room(_room)
		_:
			push_error("[P2PNet negative] unknown test: %s" % _test)
			get_tree().quit(1)


func _on_room_ready(code: String) -> void:
	if _test != "seal" or _mode != "host":
		return
	var room_file := (
		OS.get_environment("P2P_NET_ROOM_FILE") if OS.has_environment("P2P_NET_ROOM_FILE") else ""
	)
	if not room_file.is_empty():
		var f := FileAccess.open(room_file, FileAccess.WRITE)
		if f:
			f.store_string(code)
	await get_tree().create_timer(2.0).timeout
	if P2PNet.seal_lobby() != OK:
		push_error("[P2PNet negative] seal_lobby failed")
		get_tree().quit(1)
		return
	await get_tree().create_timer(1.0).timeout
	_finish_ok("host sealed")


func _on_room_sealed() -> void:
	if _test == "seal":
		_finish_ok("room_sealed received")


func _on_connection_failed(reason: String) -> void:
	if _done:
		return
	if _test in ["invalid_room", "room_full"]:
		_finish_ok("expected fail: %s" % reason)
		return
	push_error("[P2PNet negative] unexpected fail: %s" % reason)
	get_tree().quit(1)


func _on_timeout() -> void:
	if _done:
		return
	push_error("[P2PNet negative] TIMEOUT test=%s mode=%s" % [_test, _mode])
	get_tree().quit(1)


func _finish_ok(detail: String) -> void:
	if _done:
		return
	_done = true
	print("[P2PNet negative] OK (%s)" % detail)
	P2PNet.leave()
	get_tree().quit(0)
