extends Node
## API publique réseau — bytes bruts, sans règles de jeu.

enum Backend { WEBRTC_SIGNALING, JANUS }

signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)
signal message_received(from_peer_id: int, data: PackedByteArray)
signal room_ready(room_code: String)
signal room_sealed()
signal room_left()
signal connection_failed(reason: String)

const NetConfigScript = preload("res://addons/p2p_net/net_config.gd")
const WebRtcMeshTransportScript = preload("res://addons/p2p_net/transport/webrtc_mesh_transport.gd")
const JanusTransportScript = preload("res://addons/p2p_net/transport/janus_transport.gd")

var config  # P2PNetConfig
var _transport  # P2PTransportBackend
var _backend_kind: Backend = Backend.WEBRTC_SIGNALING


func _ready() -> void:
	config = NetConfigScript.defaults()
	use_backend(Backend.WEBRTC_SIGNALING)


func configure(p_config) -> void:
	config = p_config
	if _transport:
		_transport.configure(config)


func use_backend(kind: Backend) -> void:
	if _transport:
		_transport.queue_free()
		_transport = null
	_backend_kind = kind
	match kind:
		Backend.WEBRTC_SIGNALING:
			_transport = WebRtcMeshTransportScript.new()
		Backend.JANUS:
			_transport = JanusTransportScript.new()
		_:
			connection_failed.emit("Unknown backend.")
			return
	_transport.name = "Transport"
	_transport.configure(config)
	add_child(_transport)
	_wire_transport()


func _wire_transport() -> void:
	_transport.peer_joined.connect(func(id: int) -> void: peer_joined.emit(id))
	_transport.peer_left.connect(func(id: int) -> void: peer_left.emit(id))
	_transport.message_received.connect(
		func(id: int, data: PackedByteArray) -> void: message_received.emit(id, data)
	)
	_transport.room_ready.connect(func(code: String) -> void: room_ready.emit(code))
	_transport.room_sealed.connect(func() -> void: room_sealed.emit())
	_transport.room_left.connect(func() -> void: room_left.emit())
	_transport.connection_failed.connect(func(reason: String) -> void: connection_failed.emit(reason))


func host_room(max_peers: int = 4) -> void:
	if _transport:
		_transport.host_room(max_peers)


func join_room(room_code: String) -> void:
	if _transport:
		_transport.join_room(room_code)


func seal_lobby() -> Error:
	return _transport.seal_lobby() if _transport else ERR_UNAVAILABLE


func leave() -> void:
	if _transport:
		_transport.leave()


func is_host() -> bool:
	return _transport != null and _transport.is_host()


func is_in_room() -> bool:
	return _transport != null and _transport.is_in_room()


func room_code() -> String:
	return _transport.room_code() if _transport else ""


func my_peer_id() -> int:
	return _transport.my_peer_id() if _transport else 0


func peer_ids() -> PackedInt32Array:
	return _transport.peer_ids() if _transport else PackedInt32Array()


func send_to(peer_id: int, data: PackedByteArray, reliable: bool = true) -> Error:
	if _transport:
		return _transport.send_to(peer_id, data, reliable)
	return ERR_UNAVAILABLE


func broadcast(data: PackedByteArray, reliable: bool = true) -> Error:
	if _transport:
		return _transport.broadcast(data, reliable)
	return ERR_UNAVAILABLE


func ping_all() -> Error:
	return broadcast("ping".to_utf8_buffer())
