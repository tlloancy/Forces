extends RefCounted
## Configuration transport — aucune règle de jeu ici.

var signaling_url: String = "ws://127.0.0.1:8080"
var max_peers: int = 4
var use_mesh: bool = true
var ice_servers: Array = [
	{"urls": ["stun:stun.l.google.com:19302"]},
]
## Optionnel — laisser vide si pas de TURN.
var turn_url: String = ""
var turn_username: String = ""
var turn_password: String = ""


static func defaults():
	return load("res://addons/p2p_net/net_config.gd").new()


func build_ice_servers() -> Array:
	var servers: Array = ice_servers.duplicate(true)
	if not turn_url.is_empty():
		var turn_entry: Dictionary = {"urls": [turn_url]}
		if not turn_username.is_empty():
			turn_entry["username"] = turn_username
		if not turn_password.is_empty():
			turn_entry["credential"] = turn_password
		servers.append(turn_entry)
	return servers
