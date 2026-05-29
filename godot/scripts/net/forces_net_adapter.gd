extends Node
## Forces game protocol on top of P2PNet (host-authoritative, 2 players MVP).

signal match_start_received(config: Dictionary)
signal order_received(order: Dictionary)
signal state_received(snapshot: Dictionary)
signal peer_ready(peer_id: int)

const MSG_START := "start"
const MSG_ORDER := "order"
const MSG_END_ROUND := "end_round"
const MSG_STATE := "state"


func _ready() -> void:
	if not Engine.has_singleton("P2PNet") and not get_tree().root.has_node("P2PNet"):
		return
	P2PNet.message_received.connect(_on_message_received)
	P2PNet.peer_joined.connect(_on_peer_joined)


func is_available() -> bool:
	return ClassDB.class_exists("WebRTCMultiplayerPeer")


func host_lobby(max_peers: int = 4) -> void:
	GameSession.reset_for_network_host()
	P2PNet.host_room(max_peers)


func join_lobby(code: String) -> void:
	GameSession.reset_for_network_client()
	P2PNet.join_room(code)


func leave_lobby() -> void:
	P2PNet.leave()
	GameSession.clear_network()


func send_match_start(config: Dictionary) -> void:
	_send_to_all({MSG_START: config})


func send_order(order: Dictionary) -> void:
	if GameSession.network_is_host:
		_send_to_all({MSG_ORDER: order})
	else:
		_send_to_host({MSG_ORDER: order})


func send_end_round() -> void:
	if not GameSession.network_is_host:
		return
	_send_to_all({MSG_END_ROUND: true})


func send_state(snapshot: Dictionary) -> void:
	if not GameSession.network_is_host:
		return
	_send_to_all({MSG_STATE: snapshot})


func _send_to_host(payload: Dictionary) -> void:
	var host_id: int = GameSession.network_host_peer_id()
	if host_id <= 0:
		return
	P2PNet.send_to(host_id, _pack(payload))


func _send_to_all(payload: Dictionary) -> void:
	P2PNet.broadcast(_pack(payload))


func _pack(payload: Dictionary) -> PackedByteArray:
	return JSON.stringify(payload).to_utf8_buffer()


func _unpack(packet: PackedByteArray) -> Dictionary:
	var parsed: Variant = JSON.parse_string(packet.get_string_from_utf8())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _on_peer_joined(peer_id: int) -> void:
	peer_ready.emit(peer_id)


func _on_message_received(from_peer_id: int, packet: PackedByteArray) -> void:
	var msg: Dictionary = _unpack(packet)
	if msg.is_empty():
		return
	if msg.has(MSG_START):
		match_start_received.emit(msg[MSG_START] as Dictionary)
	elif msg.has(MSG_ORDER):
		order_received.emit(msg[MSG_ORDER] as Dictionary)
	elif msg.has(MSG_STATE):
		state_received.emit(msg[MSG_STATE] as Dictionary)
