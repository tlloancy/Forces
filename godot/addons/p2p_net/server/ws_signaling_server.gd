extends Node
## Serveur signaling local (protocole Godot webrtc_signaling). Lance sur desktop : port 8080.
## Usage : scène res://addons/p2p_net/server/signaling_server.tscn ou autoload temporaire.

enum Message {
	JOIN,
	ID,
	PEER_CONNECT,
	PEER_DISCONNECT,
	OFFER,
	ANSWER,
	CANDIDATE,
	SEAL,
}

const TIMEOUT_MS := 15000
const SEAL_TIME_MS := 3600000
const DEFAULT_MAX_PEERS := 8
const ALFNUM := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

var listen_port: int = 8080
var default_max_peers: int = DEFAULT_MAX_PEERS

var _rand := RandomNumberGenerator.new()
var _lobbies: Dictionary = {}
var _tcp_server := TCPServer.new()
var _peers: Dictionary = {}
var _alfnum: PackedByteArray = ALFNUM.to_ascii_buffer()
var _using_external_server: bool = false


class Peer extends RefCounted:
	var id: int = -1
	var lobby: String = ""
	var time: int = 0
	var ws := WebSocketPeer.new()

	func _init(peer_id: int, tcp: StreamPeer) -> void:
		id = peer_id
		time = Time.get_ticks_msec()
		ws.accept_stream(tcp)

	func is_open() -> bool:
		return ws.get_ready_state() == WebSocketPeer.STATE_OPEN

	func send(type: int, dest_id: int, data: String = "") -> void:
		ws.send_text(JSON.stringify({"type": type, "id": dest_id, "data": data}))


class Lobby extends RefCounted:
	var peers: Dictionary = {}
	var host: int = -1
	var sealed: bool = false
	var seal_time: int = 0
	var mesh: bool = true
	var max_peers: int = DEFAULT_MAX_PEERS
	var lobby_name: String = ""

	func _init(host_id: int, use_mesh: bool, p_max_peers: int) -> void:
		host = host_id
		mesh = use_mesh
		max_peers = maxi(2, p_max_peers)

	func join(peer: Peer) -> bool:
		if sealed or not peer.is_open():
			return false
		if peers.size() >= max_peers:
			return false
		peer.send(Message.ID, 1 if peer.id == host else peer.id, "true" if mesh else "")
		for p: Peer in peers.values():
			if not p.is_open():
				continue
			if not mesh and p.id != host:
				continue
			p.send(Message.PEER_CONNECT, peer.id)
			peer.send(Message.PEER_CONNECT, 1 if p.id == host else p.id)
		peers[peer.id] = peer
		return true

	func leave(peer: Peer) -> bool:
		if not peers.has(peer.id):
			return false
		peers.erase(peer.id)
		var close_lobby: bool = peer.id == host
		if sealed:
			return close_lobby
		for p: Peer in peers.values():
			if not p.is_open():
				continue
			if close_lobby:
				p.ws.close()
			else:
				p.send(Message.PEER_DISCONNECT, peer.id)
		return close_lobby

	func seal(peer_id: int) -> bool:
		if host != peer_id:
			return false
		sealed = true
		for p: Peer in peers.values():
			if p.is_open():
				p.send(Message.SEAL, 0)
		seal_time = Time.get_ticks_msec()
		var host_peer: Peer = peers.get(host) as Peer
		peers.clear()
		if host_peer != null and host_peer.is_open():
			peers[host] = host_peer
		return true

	func rejoin(peer: Peer) -> bool:
		if not sealed or not peer.is_open():
			return false
		if peers.size() >= max_peers:
			return false
		peer.send(Message.ID, peer.id, "true" if mesh else "")
		peers[peer.id] = peer
		if peers.has(host):
			var host_peer: Peer = peers[host] as Peer
			if host_peer.is_open():
				host_peer.send(Message.PEER_CONNECT, peer.id)
				peer.send(Message.PEER_CONNECT, host if not mesh else 1)
		for pid: int in peers.keys():
			if pid == peer.id or pid == host:
				continue
			var other: Peer = peers[pid] as Peer
			if other.is_open():
				other.send(Message.PEER_CONNECT, peer.id)
				peer.send(Message.PEER_CONNECT, pid)
		return true


func _ready() -> void:
	if not listen(listen_port):
		push_error("P2PNet local signaling could not start on port %d." % listen_port)


func _process(_delta: float) -> void:
	poll()


func is_listening() -> bool:
	return _tcp_server.is_listening() or _using_external_server


func listen(port: int) -> bool:
	if OS.has_feature("web"):
		push_warning("P2PNet signaling server cannot run in HTML5 export.")
		return false
	stop()
	_using_external_server = false
	_rand.seed = int(Time.get_unix_time_from_system())
	listen_port = port
	var err: Error = _tcp_server.listen(port)
	if err == OK:
		print("P2PNet signaling listening on ws://127.0.0.1:%d" % port)
		return true
	if err == ERR_ALREADY_IN_USE:
		_using_external_server = true
		print("P2PNet signaling port %d already in use — using existing server." % port)
		return true
	push_error("P2PNet signaling listen failed: %s" % error_string(err))
	return false


func stop() -> void:
	_tcp_server.stop()
	_peers.clear()
	_lobbies.clear()


func poll() -> void:
	if not is_listening() or _using_external_server:
		return
	if _tcp_server.is_connection_available():
		var id: int = _rand.randi() % (1 << 31)
		_peers[id] = Peer.new(id, _tcp_server.take_connection())

	var to_remove: Array[int] = []
	for p: Peer in _peers.values():
		if p.lobby.is_empty() and Time.get_ticks_msec() - p.time > TIMEOUT_MS:
			p.ws.close()
		p.ws.poll()
		while p.is_open() and p.ws.get_available_packet_count() > 0:
			if not _parse_msg(p):
				to_remove.append(p.id)
				p.ws.close()
				break
		if p.ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			if _lobbies.has(p.lobby) and _lobbies[p.lobby].leave(p):
				_lobbies.erase(p.lobby)
			to_remove.append(p.id)

	for lobby_key: String in _lobbies.keys():
		var lobby: Lobby = _lobbies[lobby_key]
		if lobby.sealed and lobby.seal_time + SEAL_TIME_MS < Time.get_ticks_msec():
			for p: Peer in lobby.peers.values():
				to_remove.append(p.id)
				p.ws.close()

	for id: int in to_remove:
		_peers.erase(id)


func _join_lobby(peer: Peer, lobby_name: String, join_id: int) -> bool:
	var mesh: bool = (join_id & 1) == 0
	var max_for_lobby: int = join_id >> 1
	if max_for_lobby < 2:
		max_for_lobby = default_max_peers

	var lobby: String = lobby_name
	if lobby.is_empty():
		for _i in 32:
			lobby += char(_alfnum[_rand.randi_range(0, ALFNUM.length() - 1)])
		var new_lobby := Lobby.new(peer.id, mesh, max_for_lobby)
		new_lobby.lobby_name = lobby
		_lobbies[lobby] = new_lobby
	elif not _lobbies.has(lobby):
		return false
	else:
		var existing: Lobby = _lobbies[lobby] as Lobby
		if existing.sealed:
			if not existing.rejoin(peer):
				return false
			peer.lobby = lobby
			peer.send(Message.JOIN, 0, lobby)
			return true
	if not _lobbies[lobby].join(peer):
		return false
	peer.lobby = lobby
	peer.send(Message.JOIN, 0, lobby)
	return true


func _parse_msg(peer: Peer) -> bool:
	var parsed: Variant = JSON.parse_string(peer.ws.get_packet().get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var msg: Dictionary = parsed as Dictionary
	if not msg.has("type") or not msg.has("id") or typeof(msg.get("data")) != TYPE_STRING:
		return false

	var type: int = int(msg.type)
	var dest_id: int = int(msg.id)
	var data: String = msg.data

	if type == Message.JOIN:
		if not peer.lobby.is_empty():
			return false
		return _join_lobby(peer, data, dest_id)

	if not _lobbies.has(peer.lobby):
		return false
	var lobby: Lobby = _lobbies[peer.lobby]

	if type == Message.SEAL:
		return lobby.seal(peer.id)

	if dest_id == MultiplayerPeer.TARGET_PEER_SERVER:
		dest_id = lobby.host
	if not _peers.has(dest_id) or _peers[dest_id].lobby != peer.lobby:
		return false

	if type in [Message.OFFER, Message.ANSWER, Message.CANDIDATE]:
		var source: int = MultiplayerPeer.TARGET_PEER_SERVER if peer.id == lobby.host else peer.id
		_peers[dest_id].send(type, source, data)
		return true
	return false
