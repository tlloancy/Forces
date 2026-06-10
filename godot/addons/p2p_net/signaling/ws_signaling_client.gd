extends Node
## Client WebSocket signaling (protocole Godot webrtc_signaling).

const ProtocolScript = preload("res://addons/p2p_net/signaling/signaling_protocol.gd")

signal lobby_joined(lobby: String)
signal connected(id: int, use_mesh: bool)
signal disconnected(code: int, reason: String)
signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal offer_received(id: int, offer: String)
signal answer_received(id: int, answer: String)
signal candidate_received(id: int, mid: String, index: int, sdp: String)
signal lobby_sealed()

var autojoin: bool = true
var rejoin_mode: bool = false
var lobby: String = ""
var mesh: bool = true
var max_peers: int = 8

var _ws := WebSocketPeer.new()
var _old_state := WebSocketPeer.STATE_CLOSED


func connect_to_url(url: String) -> void:
	close()
	_ws.connect_to_url(url)


func close() -> void:
	_ws.close()


func join_lobby(room: String) -> Error:
	var join_id: int = 0 if mesh else 1
	if room.is_empty():
		join_id = (maxi(2, max_peers) << 1) | (0 if mesh else 1)
	return _send_msg(ProtocolScript.Message.JOIN, join_id, room)


func seal_lobby() -> Error:
	return _send_msg(ProtocolScript.Message.SEAL, 0)


func send_candidate(id: int, mid: String, index: int, sdp: String) -> Error:
	return _send_msg(
		ProtocolScript.Message.CANDIDATE,
		id,
		"\n%s\n%d\n%s" % [mid, index, sdp],
	)


func send_offer(id: int, offer: String) -> Error:
	return _send_msg(ProtocolScript.Message.OFFER, id, offer)


func send_answer(id: int, answer: String) -> Error:
	return _send_msg(ProtocolScript.Message.ANSWER, id, answer)


func _process(_delta: float) -> void:
	_ws.poll()
	var state := _ws.get_ready_state()
	if state != _old_state and state == WebSocketPeer.STATE_OPEN and autojoin:
		join_lobby(lobby)
	while state == WebSocketPeer.STATE_OPEN and _ws.get_available_packet_count() > 0:
		if not _parse_msg():
			push_warning("P2PNet: invalid signaling message.")
	if state != _old_state and state == WebSocketPeer.STATE_CLOSED:
		disconnected.emit(_ws.get_close_code(), _ws.get_close_reason())
	_old_state = state


func _parse_msg() -> bool:
	var parsed: Variant = JSON.parse_string(_ws.get_packet().get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var msg: Dictionary = parsed as Dictionary
	if not msg.has("type") or not msg.has("id") or typeof(msg.get("data")) != TYPE_STRING:
		return false

	var type: int = int(msg.type)
	var src_id: int = int(msg.id)

	match type:
		ProtocolScript.Message.ID:
			connected.emit(src_id, msg.data == "true")
		ProtocolScript.Message.JOIN:
			lobby_joined.emit(msg.data)
		ProtocolScript.Message.SEAL:
			lobby_sealed.emit()
		ProtocolScript.Message.PEER_CONNECT:
			peer_connected.emit(src_id)
		ProtocolScript.Message.PEER_DISCONNECT:
			peer_disconnected.emit(src_id)
		ProtocolScript.Message.OFFER:
			offer_received.emit(src_id, msg.data)
		ProtocolScript.Message.ANSWER:
			answer_received.emit(src_id, msg.data)
		ProtocolScript.Message.CANDIDATE:
			var candidate: PackedStringArray = msg.data.split("\n", false)
			if candidate.size() != 3 or not candidate[1].is_valid_int():
				return false
			candidate_received.emit(src_id, candidate[0], int(candidate[1]), candidate[2])
		_:
			return false
	return true


func _send_msg(type: int, id: int, data: String = "") -> Error:
	return _ws.send_text(JSON.stringify({"type": type, "id": id, "data": data}))
