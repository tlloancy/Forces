extends Node
## Contrat transport — implémentations : WebRTC signaling, Janus (futur).

signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)
signal message_received(from_peer_id: int, data: PackedByteArray)
signal room_ready(room_code: String)
signal room_sealed()
signal room_left()
signal connection_failed(reason: String)

var config  # P2PNetConfig, set via configure()


func configure(p_config) -> void:
	config = p_config


func host_room(_max_peers: int) -> void:
	connection_failed.emit("Transport not configured.")


func join_room(_room_code: String) -> void:
	connection_failed.emit("Transport not configured.")


func seal_lobby() -> Error:
	return ERR_UNAVAILABLE


func leave() -> void:
	pass


func is_host() -> bool:
	return false


func is_in_room() -> bool:
	return false


func room_code() -> String:
	return ""


func my_peer_id() -> int:
	return 0


func peer_ids() -> PackedInt32Array:
	return PackedInt32Array()


func send_to(_peer_id: int, _data: PackedByteArray, _reliable: bool = true) -> Error:
	return ERR_UNAVAILABLE


func broadcast(_data: PackedByteArray, _reliable: bool = true) -> Error:
	return ERR_UNAVAILABLE
