extends Node
## E2E headless: lobby ForcesNet 2–4p — match_start, remote order, state sync.
## Env: FORCES_NET_E2E=host|join, FORCES_NET_PLAYERS=2|3|4, FORCES_NET_ROOM, FORCES_NET_ROOM_FILE

const TIMEOUT_SEC := 45.0

var _mode: String = "host"
var _players: int = 2
var _room: String = ""
var _done: bool = false
var _host_state: GameState
var _client_state: GameState
var _host_ready_camps: Dictionary = {}


func _ready() -> void:
	_mode = OS.get_environment("FORCES_NET_E2E") if OS.has_environment("FORCES_NET_E2E") else "host"
	_players = int(OS.get_environment("FORCES_NET_PLAYERS")) if OS.has_environment("FORCES_NET_PLAYERS") else 2
	_room = OS.get_environment("FORCES_NET_ROOM") if OS.has_environment("FORCES_NET_ROOM") else ""
	get_tree().create_timer(TIMEOUT_SEC).timeout.connect(_on_timeout)
	if not ClassDB.class_exists("WebRTCMultiplayerPeer"):
		_fail("WebRTC missing")
		return
	ForcesNet.match_start_received.connect(_on_match_start)
	ForcesNet.order_received.connect(_on_order_received)
	ForcesNet.planning_ready_received.connect(_on_planning_ready)
	ForcesNet.state_received.connect(_on_state_received)
	ForcesNet.peer_ready.connect(_on_peer_ready)
	P2PNet.connection_failed.connect(_on_connection_failed)
	P2PNet.room_ready.connect(_on_room_ready)
	if _mode == "join":
		if _room.is_empty():
			_fail("join needs FORCES_NET_ROOM")
			return
		ForcesNet.join_lobby(_room)
	else:
		ForcesNet.host_lobby(_players)


func _fail(msg: String) -> void:
	if _done:
		return
	push_error("[ForcesNet e2e] " + msg)
	get_tree().quit(1)


func _ok(msg: String = "OK") -> void:
	if _done:
		return
	_done = true
	print("[ForcesNet e2e] %s mode=%s players=%d" % [msg, _mode, _players])
	P2PNet.leave()
	get_tree().quit(0)


func _on_timeout() -> void:
	_fail("TIMEOUT mode=%s" % _mode)


func _on_connection_failed(reason: String) -> void:
	_fail(reason)


func _on_room_ready(code: String) -> void:
	var room_file: String = (
		OS.get_environment("FORCES_NET_ROOM_FILE") if OS.has_environment("FORCES_NET_ROOM_FILE") else ""
	)
	if not room_file.is_empty() and _mode == "host":
		var f := FileAccess.open(room_file, FileAccess.WRITE)
		if f:
			f.store_string(code)


func _on_peer_ready(peer_id: int) -> void:
	if _mode != "host" or peer_id == P2PNet.my_peer_id():
		return
	GameSession.register_network_peer(peer_id)
	if GameSession.network_remote_peers_connected() < GameSession.network_remotes_needed():
		return
	await get_tree().create_timer(0.5).timeout
	_host_state = GameState.new()
	_host_state.human_camp = GameConstants.Camp.GREEN
	_host_state.reset_match()
	ForcesNet.send_match_start()


func _on_match_start(config: Dictionary) -> void:
	if _mode == "host":
		return
	_client_state = GameState.new()
	_client_state.human_camp = GameSession.human_camp
	_client_state.reset_match()
	var order: Dictionary = _build_move_order(_client_state)
	if order.is_empty():
		_fail("no move for camp %s" % GameConstants.camp_to_string(GameSession.human_camp))
		return
	ForcesNet.send_order(order)
	ForcesNet.send_planning_ready(GameSession.human_camp)


func _on_planning_ready(camp: int) -> void:
	if _mode != "host" or _host_state == null:
		return
	_host_ready_camps[camp] = true
	_try_host_resolve()


func _try_host_resolve() -> void:
	for camp: GameConstants.Camp in GameSession.network_online_camps():
		if not _host_ready_camps.has(int(camp)):
			return
	_host_state.end_planning_round()
	var snap: Dictionary = {"state": _host_state.to_snapshot(), "planning_elapsed": 1}
	ForcesNet.send_state(snap)
	await get_tree().create_timer(0.5).timeout
	if _host_state.round_number >= 2:
		_ok("host round=%d orders=%d" % [_host_state.round_number, _host_state.pending_orders.size()])
	else:
		_fail("host round still %d" % _host_state.round_number)


func _on_order_received(data: Dictionary) -> void:
	if _mode != "host" or _host_state == null:
		return
	var err: String = _host_state.try_apply_network_order(data)
	if not err.is_empty():
		_fail("order rejected: %s" % err)
		return
	# Host (Green) confirms as soon as a remote order arrives in headless e2e.
	ForcesNet.send_planning_ready(GameConstants.Camp.GREEN)


func _on_state_received(wrap: Dictionary) -> void:
	if _mode == "host":
		return
	var state_data: Dictionary = wrap.get("state", {}) as Dictionary
	if state_data.is_empty():
		_fail("empty state")
		return
	_client_state.restore_from_snapshot(state_data)
	_client_state.human_camp = GameSession.human_camp
	if _client_state.round_number >= 2:
		_ok("client round=%d camp=%s" % [
			_client_state.round_number,
			GameConstants.camp_to_string(GameSession.human_camp),
		])
	else:
		_fail("client round still %d" % _client_state.round_number)


func _build_move_order(state: GameState) -> Dictionary:
	var camp: GameConstants.Camp = state.human_camp
	var hq: String = BoardCatalog.hq_for_camp(camp)
	for p: PieceInstance in state.pieces:
		if p.camp != camp or p.in_reserve or p.sector_id != hq:
			continue
		if p.type != GameConstants.PieceType.SOLDIER:
			continue
		var dests: PackedStringArray = state.destinations_for(p)
		if dests.is_empty():
			continue
		var err: String = state.try_move_piece(p, dests[0])
		if not err.is_empty():
			continue
		var orders: Array = state.orders_for_camp(camp)
		if orders.is_empty():
			continue
		return GameState._order_to_dict(orders[orders.size() - 1])
	return {}
