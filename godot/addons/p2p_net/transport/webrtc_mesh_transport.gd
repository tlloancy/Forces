extends "res://addons/p2p_net/transport/transport_backend.gd"
## WebRTC mesh via signaling WebSocket (protocole demo Godot webrtc_signaling).
## Desktop : installer https://github.com/godotengine/webrtc-native

const SignalingClientScript = preload("res://addons/p2p_net/signaling/ws_signaling_client.gd")

var _signaling  # P2PSignalingClient
var _rtc_mp: WebRTCMultiplayerPeer
var _room_code: String = ""
var _sealed: bool = false
var _ready_emitted: bool = false
var _intentional_disconnect: bool = false
var _peer_join_retries: Dictionary = {}


func _ready() -> void:
	if ClassDB.class_exists("WebRTCLibPeerConnection"):
		WebRTCPeerConnection.set_default_extension("WebRTCLibPeerConnection")
	if not _webrtc_available():
		connection_failed.emit(
			"WebRTC unavailable — install webrtc-native GDExtension for desktop."
		)
		return
	_signaling = SignalingClientScript.new()
	add_child(_signaling)
	_signaling.connected.connect(_on_signaling_connected)
	_signaling.disconnected.connect(_on_signaling_disconnected)
	_signaling.lobby_joined.connect(_on_lobby_joined)
	_signaling.lobby_sealed.connect(_on_lobby_sealed)
	_signaling.peer_connected.connect(_on_peer_connected_signaling)
	_signaling.peer_disconnected.connect(_on_peer_disconnected_signaling)
	_signaling.offer_received.connect(_on_offer_received)
	_signaling.answer_received.connect(_on_answer_received)
	_signaling.candidate_received.connect(_on_candidate_received)
	_mp().peer_packet.connect(_on_peer_packet)
	_mp().peer_connected.connect(_on_mp_peer_connected)
	_mp().peer_disconnected.connect(_on_mp_peer_disconnected)


func _mp() -> SceneMultiplayer:
	return get_tree().get_multiplayer()


static func _webrtc_available() -> bool:
	return ClassDB.class_exists("WebRTCMultiplayerPeer") and ClassDB.class_exists("WebRTCPeerConnection")


func host_room(max_peers: int) -> void:
	if not _webrtc_available():
		connection_failed.emit("WebRTC unavailable.")
		return
	_sealed = false
	_ready_emitted = false
	_room_code = ""
	config.max_peers = maxi(2, max_peers)
	_start_signaling("")


func join_room(room_code: String) -> void:
	if not _webrtc_available():
		connection_failed.emit("WebRTC unavailable.")
		return
	if room_code.is_empty():
		connection_failed.emit("Room code is empty.")
		return
	_sealed = false
	_ready_emitted = false
	_room_code = room_code.strip_edges()
	_start_signaling(_room_code)


func seal_lobby() -> Error:
	if not is_host():
		return ERR_UNAUTHORIZED
	if _room_code.is_empty() or _signaling == null:
		return ERR_UNCONFIGURED
	return _signaling.seal_lobby()


func leave() -> void:
	if _rtc_mp == null and _signaling == null and _room_code.is_empty():
		return
	_intentional_disconnect = true
	_mp().multiplayer_peer = null
	if _rtc_mp:
		_rtc_mp.close()
		_rtc_mp = null
	if _signaling:
		_signaling.close()
	_room_code = ""
	_sealed = false
	_ready_emitted = false
	_peer_join_retries.clear()
	_intentional_disconnect = false
	room_left.emit()
	_intentional_disconnect = false
	room_left.emit()


func is_host() -> bool:
	if my_peer_id() <= 0:
		return false
	return my_peer_id() == 1


func is_in_room() -> bool:
	return not _room_code.is_empty() and _rtc_mp != null


func room_code() -> String:
	return _room_code


func my_peer_id() -> int:
	if _mp().multiplayer_peer == null:
		return 0
	return _mp().get_unique_id()


func peer_ids() -> PackedInt32Array:
	var ids := PackedInt32Array()
	if _mp().multiplayer_peer == null:
		return ids
	for peer_id: int in _mp().get_peers():
		ids.append(peer_id)
	var self_id: int = my_peer_id()
	if self_id > 0 and ids.find(self_id) < 0:
		ids.append(self_id)
	return ids


func send_to(peer_id: int, data: PackedByteArray, reliable: bool = true) -> Error:
	if _mp().multiplayer_peer == null:
		return ERR_UNCONFIGURED
	if not _is_rtc_peer_connected(peer_id):
		return ERR_DOES_NOT_EXIST
	var mode: int = (
		MultiplayerPeer.TRANSFER_MODE_RELIABLE
		if reliable
		else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE
	)
	return _mp().send_bytes(data, peer_id, mode)


func broadcast(data: PackedByteArray, reliable: bool = true) -> Error:
	if _mp().multiplayer_peer == null:
		return ERR_UNCONFIGURED
	if not _has_any_rtc_peer_connected():
		return ERR_DOES_NOT_EXIST
	var mode: int = (
		MultiplayerPeer.TRANSFER_MODE_RELIABLE
		if reliable
		else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE
	)
	return _mp().send_bytes(data, 0, mode)


func _start_signaling(lobby: String) -> void:
	_reset_session()
	_rtc_mp = WebRTCMultiplayerPeer.new()
	_signaling.mesh = config.use_mesh
	_signaling.max_peers = config.max_peers
	_signaling.lobby = lobby
	_signaling.connect_to_url(config.signaling_url)


func _reset_session() -> void:
	if _rtc_mp == null and _signaling == null and _room_code.is_empty():
		return
	_intentional_disconnect = true
	_mp().multiplayer_peer = null
	if _rtc_mp:
		_rtc_mp.close()
		_rtc_mp = null
	if _signaling:
		_signaling.close()
	_room_code = ""
	_sealed = false
	_ready_emitted = false
	_peer_join_retries.clear()
	_intentional_disconnect = false


func _is_rtc_peer_connected(peer_id: int) -> bool:
	if _rtc_mp == null or not _rtc_mp.has_peer(peer_id):
		return false
	return _rtc_mp.get_peer(peer_id).connected


func _has_any_rtc_peer_connected() -> bool:
	if _rtc_mp == null:
		return false
	for peer_id: int in _rtc_mp.get_peers():
		if _rtc_mp.get_peer(peer_id).connected:
			return true
	return false


func _create_peer(id: int) -> void:
	var peer := WebRTCPeerConnection.new()
	peer.initialize({"iceServers": config.build_ice_servers()})
	peer.session_description_created.connect(_on_session_description_created.bind(id))
	peer.ice_candidate_created.connect(_on_ice_candidate_created.bind(id))
	_rtc_mp.add_peer(peer, id)
	if id < _rtc_mp.get_unique_id():
		peer.create_offer()


func _on_signaling_connected(id: int, use_mesh: bool) -> void:
	if use_mesh:
		_rtc_mp.create_mesh(id)
	elif id == 1:
		_rtc_mp.create_server()
	else:
		_rtc_mp.create_client(id)
	_mp().multiplayer_peer = _rtc_mp


func _on_lobby_joined(lobby: String) -> void:
	_room_code = lobby
	if not _ready_emitted:
		_ready_emitted = true
		room_ready.emit(_room_code)


func _on_lobby_sealed() -> void:
	_sealed = true
	room_sealed.emit()


func _on_signaling_disconnected(_code: int, _reason: String) -> void:
	if _intentional_disconnect or _sealed:
		return
	connection_failed.emit("Signaling disconnected.")
	_reset_session()
	room_left.emit()


func _on_peer_connected_signaling(id: int) -> void:
	_create_peer(id)


func _on_peer_disconnected_signaling(id: int) -> void:
	if _rtc_mp and _rtc_mp.has_peer(id):
		_rtc_mp.remove_peer(id)


func _on_mp_peer_connected(id: int) -> void:
	call_deferred("_emit_peer_joined", id)


func _emit_peer_joined(id: int) -> void:
	if not is_inside_tree() or _rtc_mp == null:
		return
	var retries: int = int(_peer_join_retries.get(id, 0))
	if retries > 120:
		return
	_peer_join_retries[id] = retries + 1
	if not _is_rtc_peer_connected(id):
		call_deferred("_emit_peer_joined", id)
		return
	for connected_id: int in _mp().get_peers():
		if connected_id == id:
			_peer_join_retries.erase(id)
			peer_joined.emit(id)
			return
	call_deferred("_emit_peer_joined", id)


func _on_mp_peer_disconnected(id: int) -> void:
	peer_left.emit(id)


func _on_session_description_created(type: String, data: String, id: int) -> void:
	if not _rtc_mp.has_peer(id):
		return
	_rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer":
		_signaling.send_offer(id, data)
	else:
		_signaling.send_answer(id, data)


func _on_ice_candidate_created(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	_signaling.send_candidate(id, mid_name, index_name, sdp_name)


func _on_offer_received(id: int, offer: String) -> void:
	if _rtc_mp.has_peer(id):
		_rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)


func _on_answer_received(id: int, answer: String) -> void:
	if _rtc_mp.has_peer(id):
		_rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


func _on_candidate_received(id: int, mid: String, index: int, sdp: String) -> void:
	if _rtc_mp.has_peer(id):
		_rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)


func _on_peer_packet(id: int, packet: PackedByteArray) -> void:
	message_received.emit(id, packet)
