extends Control

const _LOBBY_CAMPS: Array[GameConstants.Camp] = [
	GameConstants.Camp.GREEN,
	GameConstants.Camp.BLUE,
	GameConstants.Camp.RED,
	GameConstants.Camp.YELLOW,
]

@onready var _status: Label = %StatusLabel
@onready var _room_code: LineEdit = %RoomCodeEdit
@onready var _player_count: OptionButton = %PlayerCountOption
@onready var _host_btn: Button = %HostButton
@onready var _join_btn: Button = %JoinButton
@onready var _copy_btn: Button = %CopyCodeButton
@onready var _rejoin_btn: Button = %RejoinButton
@onready var _start_btn: Button = %StartButton
@onready var _back_btn: Button = %BackButton
@onready var _panel: PanelContainer = %Panel
@onready var _player_slots: VBoxContainer = %PlayerSlots
@onready var _logo_f: Label = %LogoF
@onready var _logo_rest: Label = %LogoRest
@onready var _subtitle: Label = %Subtitle

var _all_remotes_ready: bool = false
var _slot_rows: Dictionary = {}
var _in_room: bool = false


func _ready() -> void:
	MenuTheme.style_panel(_panel)
	MenuTheme.style_title(_logo_f, 40)
	MenuTheme.style_title(_logo_rest, 40)
	_logo_rest.add_theme_color_override("font_color", Color(0.25, 0.45, 0.85))
	MenuTheme.style_body(_subtitle)
	MenuTheme.style_primary_button(_start_btn)
	MenuTheme.style_deploy_button(_start_btn)
	MenuTheme.style_primary_button(_rejoin_btn)
	MenuTheme.style_primary_button(_back_btn)
	MenuTheme.style_compact_button(_host_btn, true)
	MenuTheme.style_compact_button(_join_btn, true)
	MenuTheme.style_compact_button(_copy_btn)
	for camp: GameConstants.Camp in _LOBBY_CAMPS:
		_slot_rows[camp] = _make_slot_row(camp)
	_player_count.clear()
	_player_count.add_item("2 players", 2)
	_player_count.add_item("3 players", 3)
	_player_count.add_item("4 players", 4)
	_player_count.item_selected.connect(func(_idx: int) -> void: _refresh_player_slots())
	_start_btn.disabled = true
	_copy_btn.disabled = true
	_update_rejoin_button()
	_refresh_player_slots()
	if not ForcesNet.is_available():
		_set_status("WebRTC unavailable — run tools/setup_webrtc.ps1 then --import.")
		_disable_network_controls()
		return
	if P2PNet.ensure_local_signaling():
		_set_status("Create a room or join with a friend's code.")
	else:
		_set_status("Signaling port 8080 busy — close other apps or restart.")
		_host_btn.disabled = true
	P2PNet.room_ready.connect(_on_room_ready)
	P2PNet.connection_failed.connect(_on_connection_failed)
	P2PNet.room_left.connect(_on_room_left)
	P2PNet.peer_joined.connect(_on_peer_joined)
	P2PNet.peer_left.connect(_on_peer_left)
	ForcesNet.peer_ready.connect(_on_forces_peer_ready)
	ForcesNet.match_start_received.connect(_on_match_start_received)
	ForcesNet.resync_received.connect(_on_rejoin_resync)


func _exit_tree() -> void:
	if P2PNet.is_in_room():
		ForcesNet.leave_lobby()


func _disable_network_controls() -> void:
	_host_btn.disabled = true
	_join_btn.disabled = true
	_rejoin_btn.disabled = true
	_player_count.disabled = true


func _make_slot_row(camp: GameConstants.Camp) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(14, 14)
	dot.color = GameConstants.CAMP_COLORS[camp]
	var dot_wrap := CenterContainer.new()
	dot_wrap.custom_minimum_size = Vector2(22, 22)
	dot_wrap.add_child(dot)
	row.add_child(dot_wrap)
	var name_lbl := Label.new()
	name_lbl.text = GameConstants.camp_to_string(camp)
	name_lbl.custom_minimum_size = Vector2(72, 0)
	name_lbl.add_theme_color_override("font_color", GameConstants.CAMP_COLORS[camp])
	name_lbl.add_theme_font_size_override("font_size", 15)
	row.add_child(name_lbl)
	var status_lbl := Label.new()
	status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_lbl.add_theme_color_override("font_color", MenuTheme.MUTED)
	status_lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(status_lbl)
	row.set_meta("status_label", status_lbl)
	row.set_meta("dot", dot)
	var sep := HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.12)
	_player_slots.add_child(row)
	_player_slots.add_child(sep)
	return row


func _set_status(text: String) -> void:
	if _status:
		_status.text = text


func _selected_player_count() -> int:
	return clampi(_player_count.get_selected_id(), 2, 4)


func _camp_is_online_slot(camp: GameConstants.Camp, player_count: int) -> bool:
	if camp == GameConstants.Camp.GREEN:
		return true
	var idx: int = _LOBBY_CAMPS.find(camp)
	return idx >= 0 and idx < player_count


func _camp_has_peer(camp: GameConstants.Camp) -> bool:
	for peer_id: Variant in GameSession.network_peer_camps.keys():
		if int(GameSession.network_peer_camps[peer_id]) == int(camp):
			return true
	return false


func _refresh_player_slots() -> void:
	var player_count: int = _selected_player_count()
	if _in_room and GameSession.network_player_count > 0:
		player_count = GameSession.network_player_count
	for camp: GameConstants.Camp in _LOBBY_CAMPS:
		var row: HBoxContainer = _slot_rows.get(camp) as HBoxContainer
		if row == null:
			continue
		var status_lbl: Label = row.get_meta("status_label") as Label
		var dot: ColorRect = row.get_meta("dot") as ColorRect
		if not _camp_is_online_slot(camp, player_count):
			status_lbl.text = "AI"
			status_lbl.add_theme_color_override("font_color", Color(MenuTheme.MUTED, 0.55))
			dot.modulate = Color(1, 1, 1, 0.35)
			continue
		dot.modulate = Color.WHITE
		var is_you: bool = _in_room and int(GameSession.human_camp) == int(camp)
		if camp == GameConstants.Camp.GREEN and GameSession.network_is_host:
			is_you = true
		if _camp_has_peer(camp):
			status_lbl.text = "You · connected" if is_you else "Connected"
			status_lbl.add_theme_color_override("font_color", Color(0.45, 0.92, 0.55))
		elif _in_room and camp == GameConstants.Camp.GREEN:
			status_lbl.text = "Host · connected"
			status_lbl.add_theme_color_override("font_color", Color(0.45, 0.92, 0.55))
		elif _in_room and not GameSession.network_is_host and is_you:
			status_lbl.text = "You · connected"
			status_lbl.add_theme_color_override("font_color", Color(0.45, 0.92, 0.55))
		else:
			status_lbl.text = "Waiting…"
			status_lbl.add_theme_color_override("font_color", MenuTheme.MUTED)


func _update_rejoin_button() -> void:
	if _rejoin_btn == null:
		return
	var can: bool = GameSession.has_reconnect_checkpoint()
	_rejoin_btn.visible = can
	if can:
		var cp: Dictionary = GameSession.peek_reconnect_checkpoint()
		_room_code.text = str(cp.get("room_code", ""))
		_copy_btn.disabled = _room_code.text.is_empty()
		_set_status("Previous match found — rejoin or start a new room.")


func _on_host_pressed() -> void:
	GameSession.clear_reconnect_checkpoint()
	_all_remotes_ready = false
	_start_btn.disabled = true
	_player_count.disabled = true
	_update_rejoin_button()
	_set_status("Creating room…")
	ForcesNet.host_lobby(_selected_player_count())


func _on_join_pressed() -> void:
	var code: String = _room_code.text.strip_edges()
	if code.is_empty():
		_set_status("Enter a room code to join.")
		return
	GameSession.clear_reconnect_checkpoint()
	_start_btn.disabled = true
	_player_count.disabled = true
	_update_rejoin_button()
	_set_status("Joining room…")
	ForcesNet.join_lobby(code)


func _on_rejoin_pressed() -> void:
	var cp: Dictionary = GameSession.take_reconnect_checkpoint()
	if cp.is_empty():
		_update_rejoin_button()
		return
	var code: String = str(cp.get("room_code", ""))
	var camp: GameConstants.Camp = int(cp.get("camp", GameConstants.Camp.BLUE)) as GameConstants.Camp
	_start_btn.disabled = true
	_player_count.disabled = true
	_set_status("Reconnecting as %s…" % GameConstants.camp_to_string(camp))
	ForcesNet.rejoin_match(code, camp)


func _on_copy_code_pressed() -> void:
	var code: String = _room_code.text.strip_edges()
	if code.is_empty():
		return
	DisplayServer.clipboard_set(code)
	_set_status("Room code copied — share it with friends!")


func _on_room_ready(code: String) -> void:
	_in_room = true
	_room_code.text = code
	_copy_btn.disabled = false
	_refresh_player_slots()
	if GameSession.network_is_host:
		var need: int = GameSession.network_remotes_needed()
		_set_status("Room %s — share the code, waiting for %d player(s)." % [code, need])
	else:
		_set_status("Joined %s — waiting for host to start." % code)


func _on_peer_joined(_peer_id: int) -> void:
	_refresh_player_slots()


func _on_peer_left(_peer_id: int) -> void:
	_refresh_player_slots()


func _on_forces_peer_ready(peer_id: int) -> void:
	if peer_id == P2PNet.my_peer_id():
		return
	if GameSession.network_is_host:
		GameSession.register_network_peer(peer_id)
		var connected: int = GameSession.network_remote_peers_connected()
		var need: int = GameSession.network_remotes_needed()
		_refresh_player_slots()
		if connected >= need:
			_all_remotes_ready = true
			_start_btn.disabled = false
			_set_status("Everyone is in! Press Start match when ready.")
		else:
			_set_status("Room %s — %d/%d players connected." % [
				P2PNet.room_code(), connected, need,
			])
	else:
		_refresh_player_slots()
		_set_status("Connected — waiting for host to start the match.")


func _on_connection_failed(reason: String) -> void:
	_in_room = false
	_set_status("Connection failed: %s" % reason)
	_start_btn.disabled = true
	_player_count.disabled = false
	_copy_btn.disabled = _room_code.text.strip_edges().is_empty()
	_refresh_player_slots()


func _on_room_left() -> void:
	_in_room = false
	_all_remotes_ready = false
	_start_btn.disabled = true
	_player_count.disabled = false
	_refresh_player_slots()


func _on_start_pressed() -> void:
	if not GameSession.network_is_host or not _all_remotes_ready:
		return
	GameSession.clear_reconnect_checkpoint()
	P2PNet.seal_lobby()
	ForcesNet.send_match_start()
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_match_start_received(_config: Dictionary) -> void:
	if GameSession.network_is_host:
		return
	GameSession.clear_reconnect_checkpoint()
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_rejoin_resync(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	GameSession.save_battle(snapshot)
	GameSession.clear_reconnect_checkpoint()
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_back_pressed() -> void:
	ForcesNet.leave_lobby()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
