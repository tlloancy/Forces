extends "res://addons/p2p_net/transport/transport_backend.gd"
## Backend Janus — stub. Brancher ici quand le serveur Janus est documenté.


func host_room(_max_peers: int) -> void:
	connection_failed.emit("Janus transport not implemented yet.")


func join_room(_room_code: String) -> void:
	connection_failed.emit("Janus transport not implemented yet.")


func seal_lobby() -> Error:
	return ERR_UNAVAILABLE
