extends Node
## Forces game protocol on top of P2PNet (host-authoritative, 2–4 players).
## Disconnect / reconnect: grace period then auto-forfeit (chess.com-style).

signal match_start_received(config: Dictionary)
signal order_received(order: Dictionary)
signal state_received(snapshot: Dictionary)
signal peer_ready(peer_id: int)
signal opponent_disconnected(camp: int, seconds_left: int)
signal opponent_reconnected(camp: int)
signal opponent_forfeited(camp: int)
signal local_connection_lost()
signal resync_received(snapshot: Dictionary)
signal planning_ready_received(camp: int)

const MSG_START := "start"
const MSG_ORDER := "order"
const MSG_READY := "ready"
const MSG_END_ROUND := "end_round"
const MSG_STATE := "state"
const MSG_DISCONNECT := "disconnect"
const MSG_RECONNECT := "reconnect"
const MSG_FORFEIT := "forfeit"
const MSG_RESYNC := "resync"

var _match_active: bool = false
var _host_snapshot: Dictionary = {}
var _awaiting_reconnect_handshake: bool = false


func _ready() -> void:
	if not Engine.has_singleton("P2PNet") and not get_tree().root.has_node("P2PNet"):
		return
	P2PNet.message_received.connect(_on_message_received)
	P2PNet.peer_joined.connect(_on_peer_joined)
	P2PNet.peer_left.connect(_on_peer_left)
	P2PNet.connection_failed.connect(_on_connection_failed)


func _process(_delta: float) -> void:
	if not _match_active or not GameSession.network_is_host:
		return
	var now: int = int(Time.get_unix_time_from_system())
	for camp_key: Variant in GameSession.network_disconnected_camps.keys():
		var camp: GameConstants.Camp = int(camp_key) as GameConstants.Camp
		var deadline: int = GameSession.disconnected_camp_deadline(camp)
		if deadline > 0 and now >= deadline:
			_host_forfeit_camp(camp)


func is_available() -> bool:
	return ClassDB.class_exists("WebRTCMultiplayerPeer")


func host_lobby(player_count: int = 2) -> void:
	GameSession.reset_for_network_host(player_count)
	P2PNet.host_room(4)


func join_lobby(code: String) -> void:
	GameSession.reset_for_network_client()
	P2PNet.join_room(code)


func rejoin_match(code: String, camp: GameConstants.Camp) -> void:
	var cp: Dictionary = GameSession.peek_reconnect_checkpoint()
	GameSession.network_active = true
	GameSession.network_is_host = false
	GameSession.network_host_peer_id = 1
	GameSession.human_camp = camp
	GameSession.network_player_count = int(cp.get("player_count", 2))
	GameSession.network_room_code = code
	GameSession.network_match_in_progress = true
	_awaiting_reconnect_handshake = true
	_match_active = true
	P2PNet.rejoin_room(code)


func leave_lobby() -> void:
	_match_active = false
	_host_snapshot.clear()
	GameSession.clear_reconnect_checkpoint()
	P2PNet.leave()
	GameSession.clear_network()


func begin_network_match() -> void:
	_match_active = true
	GameSession.mark_network_match_started(P2PNet.room_code())


func set_host_snapshot(snapshot: Dictionary) -> void:
	_host_snapshot = snapshot


func send_match_start(config: Dictionary = {}) -> void:
	var payload: Dictionary = config if not config.is_empty() else GameSession.build_network_match_config()
	_send_to_all({MSG_START: payload})


func apply_match_start(config: Dictionary) -> void:
	GameSession.apply_network_match_config(config, P2PNet.my_peer_id())
	match_start_received.emit(config)


func send_order(order: Dictionary) -> void:
	if GameSession.network_is_host:
		_send_to_all({MSG_ORDER: order})
	else:
		_send_to_host({MSG_ORDER: order})


func send_planning_ready(camp: GameConstants.Camp) -> void:
	var payload: Dictionary = {MSG_READY: {"camp": int(camp)}}
	if GameSession.network_is_host:
		_send_to_all(payload)
		planning_ready_received.emit(int(camp))
	else:
		_send_to_host(payload)


func send_end_round() -> void:
	if not GameSession.network_is_host:
		return
	_send_to_all({MSG_END_ROUND: true})


func send_state(snapshot: Dictionary) -> void:
	if not GameSession.network_is_host:
		return
	_host_snapshot = snapshot
	_send_to_all({MSG_STATE: snapshot})


func send_resync_to_peer(peer_id: int, snapshot: Dictionary) -> void:
	if not GameSession.network_is_host:
		return
	P2PNet.send_to(peer_id, _pack({MSG_RESYNC: snapshot}))


func _send_to_host(payload: Dictionary) -> void:
	var host_id: int = GameSession.network_host_peer_id
	if host_id <= 0:
		return
	P2PNet.send_to(host_id, _pack(payload))


func _send_to_all(payload: Dictionary) -> void:
	P2PNet.broadcast(_pack(payload))


func _pack(payload: Dictionary) -> PackedByteArray:
	return JSON.stringify(payload).to_utf8_buffer()


func _unpack(packet: PackedByteArray) -> Dictionary:
	var text: String = packet.get_string_from_utf8().strip_edges()
	if text.is_empty() or text[0] != "{":
		return {}
	var json := JSON.new()
	if json.parse(text) != OK:
		return {}
	var parsed: Variant = json.get_data()
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _on_peer_joined(peer_id: int) -> void:
	peer_ready.emit(peer_id)
	if not _match_active:
		return
	if _awaiting_reconnect_handshake and not GameSession.network_is_host:
		_send_to_host({MSG_RECONNECT: {"camp": int(GameSession.human_camp)}})
		_awaiting_reconnect_handshake = false


func _on_peer_left(peer_id: int) -> void:
	if not _match_active:
		return
	if GameSession.network_is_host:
		var camp: GameConstants.Camp = GameSession.camp_for_peer(peer_id)
		if camp == GameConstants.Camp.GREEN:
			return
		if GameSession.slot_kind(camp) != GameSession.SlotKind.NETWORK:
			return
		_host_mark_disconnected(camp)
	elif peer_id == GameSession.network_host_peer_id:
		GameSession.save_reconnect_checkpoint()
		local_connection_lost.emit()


func _on_connection_failed(_reason: String) -> void:
	if not _match_active:
		return
	if not GameSession.network_is_host:
		GameSession.save_reconnect_checkpoint()
		local_connection_lost.emit()


func _host_mark_disconnected(camp: GameConstants.Camp) -> void:
	GameSession.mark_camp_disconnected(camp)
	var deadline: int = GameSession.disconnected_camp_deadline(camp)
	_send_to_all({
		MSG_DISCONNECT: {
			"camp": int(camp),
			"deadline": deadline,
		},
	})
	opponent_disconnected.emit(int(camp), GameSession.DISCONNECT_GRACE_SEC)


func _host_forfeit_camp(camp: GameConstants.Camp) -> void:
	if not GameSession.is_camp_disconnected(camp):
		return
	GameSession.network_disconnected_camps.erase(int(camp))
	_send_to_all({MSG_FORFEIT: {"camp": int(camp)}})
	opponent_forfeited.emit(int(camp))


func _host_complete_reconnect(peer_id: int, camp: GameConstants.Camp) -> void:
	GameSession.assign_peer_to_camp(peer_id, camp)
	var snap: Dictionary = _host_snapshot
	if snap.is_empty():
		snap = {"state": {}}
	send_resync_to_peer(peer_id, snap)
	_send_to_all({MSG_RECONNECT: {"camp": int(camp), "peer_id": peer_id}})
	opponent_reconnected.emit(int(camp))


func _on_message_received(from_peer_id: int, packet: PackedByteArray) -> void:
	var msg: Dictionary = _unpack(packet)
	if msg.is_empty():
		return
	if msg.has(MSG_START):
		apply_match_start(msg[MSG_START] as Dictionary)
	elif msg.has(MSG_ORDER):
		order_received.emit(msg[MSG_ORDER] as Dictionary)
	elif msg.has(MSG_READY):
		var ready_data: Dictionary = msg[MSG_READY] as Dictionary
		var camp: int = int(ready_data.get("camp", -1))
		if GameSession.network_is_host and from_peer_id != P2PNet.my_peer_id():
			var expected: GameConstants.Camp = GameSession.camp_for_peer(from_peer_id)
			if int(expected) != camp:
				return
			_send_to_all({MSG_READY: ready_data})
		planning_ready_received.emit(camp)
	elif msg.has(MSG_STATE):
		state_received.emit(msg[MSG_STATE] as Dictionary)
	elif msg.has(MSG_DISCONNECT):
		var data: Dictionary = msg[MSG_DISCONNECT] as Dictionary
		var camp: int = int(data.get("camp", -1))
		var deadline: int = int(data.get("deadline", 0))
		GameSession.network_disconnected_camps[camp] = deadline - GameSession.DISCONNECT_GRACE_SEC
		var left: int = maxi(0, deadline - int(Time.get_unix_time_from_system()))
		opponent_disconnected.emit(camp, left)
	elif msg.has(MSG_FORFEIT):
		var camp: int = int((msg[MSG_FORFEIT] as Dictionary).get("camp", -1))
		GameSession.network_disconnected_camps.erase(camp)
		opponent_forfeited.emit(camp)
	elif msg.has(MSG_RESYNC):
		var snap: Dictionary = msg[MSG_RESYNC] as Dictionary
		resync_received.emit(snap)
		state_received.emit(snap)
	elif msg.has(MSG_RECONNECT):
		var data: Dictionary = msg[MSG_RECONNECT] as Dictionary
		if data.has("peer_id"):
			opponent_reconnected.emit(int(data.get("camp", -1)))
		elif GameSession.network_is_host:
			var req_camp: int = int(data.get("camp", -1))
			if GameSession.is_camp_disconnected(req_camp as GameConstants.Camp):
				_host_complete_reconnect(from_peer_id, req_camp as GameConstants.Camp)
