extends Control

@onready var _status: Label = %StatusLabel
@onready var _sector_list: ItemList = %SectorList
@onready var _dest_list: ItemList = %DestList
@onready var _piece_list: ItemList = %PieceList
@onready var _log: RichTextLabel = %OrdersLog
@onready var _end_round_btn: Button = %EndRoundButton
@onready var _board_map: Control = %BoardMap
@onready var _sidebar: Control = %Sidebar
@onready var _buy_soldier_btn: Button = %BuySoldierButton
@onready var _buy_raider_btn: Button = %BuyRaiderButton
@onready var _buy_hunter_btn: Button = %BuyHunterButton
@onready var _buy_cruiser_btn: Button = %BuyCruiserButton
@onready var _deploy_btn: Button = %DeployButton
@onready var _hbomb_fuse_btn: Button = %HbombFuseButton
@onready var _game_over_layer: CanvasLayer = $GameOverLayer
@onready var _game_over_label: Label = %GameOverLabel

var _state: GameState
var _selected_sector: String = ""
var _selected_piece_id: int = -1
var _sector_pick_index: int = 0
var _planning_elapsed: int = 1
var _timer_accum: float = 0.0


func _ready() -> void:
	_state = GameState.new()
	_state.human_camp = GameSession.human_camp
	_state.phase_changed.connect(_on_phase_changed)
	_state.round_advanced.connect(_on_round_advanced)
	_state.piece_moved.connect(_on_piece_moved)
	_state.power_changed.connect(_on_power_changed)
	_board_map.sector_pressed.connect(_on_map_sector_pressed)
	if _sidebar.has_signal("unit_pressed"):
		_sidebar.unit_pressed.connect(_on_sidebar_unit_pressed)
	_style_sidebar()
	if _game_over_layer:
		_game_over_layer.visible = false
	if _game_over_layer:
		var go_panel: PanelContainer = _game_over_layer.get_node("Center/Panel") as PanelContainer
		if go_panel:
			MenuTheme.style_panel(go_panel)
	AudioManager.play_battle_music()
	_populate_sector_list()
	_begin_match()
	_refresh_ui()
	if _board_map.has_method("set_selected"):
		_board_map.call("set_selected", _selected_sector)


func _process(delta: float) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_timer_accum += delta
	if _timer_accum >= 1.0:
		_timer_accum -= 1.0
		_planning_elapsed = mini(_planning_elapsed + 1, _state.planning_time_limit())
		if _planning_elapsed >= _state.planning_time_limit():
			var timeout_logs: Array[String] = []
			_state.apply_planning_timeout(timeout_logs)
			for line: String in timeout_logs:
				_log.append_text("[color=#ff8888]%s[/color]\n" % line)
			_check_game_over()
			_refresh_ui()
			return
		if _sidebar.has_method("refresh"):
			_sidebar.call(
				"refresh",
				_state,
				_state.human_camp,
				_selected_sector,
				_planning_elapsed,
				_selected_piece(),
			)


func _style_sidebar() -> void:
	for panel_name: String in ["CasePanel", "ReservePanel", "OrdersPanel"]:
		var panel: PanelContainer = _sidebar.get_node(panel_name) as PanelContainer
		if panel:
			MenuTheme.style_panel(panel)
	_sidebar.modulate = Color(1, 1, 1, 0.88)


func _begin_match() -> void:
	_state.reset_match()
	_selected_sector = BoardCatalog.hq_for_camp(_state.human_camp)
	_selected_piece_id = -1
	_planning_elapsed = 1
	_timer_accum = 0.0
	_log.clear()


func _populate_sector_list() -> void:
	_sector_list.clear()
	for sector_id: String in BoardCatalog.SECTOR_IDS:
		_sector_list.add_item(sector_id)


func _refresh_ui() -> void:
	var planning: bool = _state.phase == GameConstants.GamePhase.PLANNING
	var game_over: bool = _state.phase == GameConstants.GamePhase.GAME_OVER
	_end_round_btn.disabled = not planning
	if _game_over_layer:
		_game_over_layer.visible = game_over
	_buy_soldier_btn.disabled = not planning
	_buy_raider_btn.disabled = not planning
	_buy_hunter_btn.disabled = not planning
	_buy_cruiser_btn.disabled = not planning
	var sel: PieceInstance = _selected_piece()
	var can_deploy: bool = sel != null and sel.in_reserve and not _state.has_piece_moved(sel.id)
	_deploy_btn.disabled = not planning or not can_deploy
	var fusion_ok: bool = (
		not _selected_sector.is_empty()
		and _state.hbomb_fusion_force_available(_state.human_camp, _selected_sector)
		>= GameConstants.HBOMB_FUSION_FORCE
	)
	_hbomb_fuse_btn.disabled = (
		not planning
		or _selected_sector.is_empty()
		or _state.hbomb_on_board(_state.human_camp) != null
		or not fusion_ok
	)
	if _board_map.has_method("refresh"):
		_board_map.call("refresh", _state)
	_update_move_highlights()
	if _sidebar.has_method("refresh"):
		_sidebar.call(
			"refresh",
			_state,
			_state.human_camp,
			_selected_sector,
			_planning_elapsed,
			_selected_piece(),
		)
	if _status:
		_status.text = "%s | %s | ordres %d/%d" % [
			GameConstants.camp_to_string(_state.human_camp),
			_phase_name(_state.phase),
			_state.camp_orders_used(_state.human_camp),
			GameConstants.MAX_ORDERS_PER_ROUND,
		]


func _selected_piece() -> PieceInstance:
	if _selected_piece_id < 0:
		return null
	return _state.find_piece(_selected_piece_id)


func _movable_human_on_sector(sector_id: String) -> Array[PieceInstance]:
	var result: Array[PieceInstance] = []
	for p: PieceInstance in _state.human_pieces_on_sector(sector_id):
		if not _state.has_piece_moved(p.id):
			result.append(p)
	var hq: String = BoardCatalog.hq_for_camp(_state.human_camp)
	if sector_id == hq:
		for p: PieceInstance in _state.reserve_pieces(_state.human_camp):
			if not _state.has_piece_moved(p.id):
				result.append(p)
	result.sort_custom(func(a: PieceInstance, b: PieceInstance) -> bool:
		if a.in_reserve != b.in_reserve:
			return not a.in_reserve
		return int(a.type) < int(b.type)
	)
	return result


func _update_move_highlights() -> void:
	if not _board_map.has_method("set_move_highlights"):
		return
	if _selected_piece_id < 0:
		_board_map.call("set_move_highlights", PackedStringArray())
		if _board_map.has_method("set_highlight_color"):
			_board_map.call("set_highlight_color", Color(0.95, 0.85, 0.35, 0.55))
		return
	var piece: PieceInstance = _selected_piece()
	if piece == null or piece.in_reserve:
		_board_map.call("set_move_highlights", PackedStringArray())
		return
	if _board_map.has_method("set_highlight_color"):
		_board_map.call("set_highlight_color", _highlight_color_for_piece(piece))
	_board_map.call("set_move_highlights", _state.destinations_for(piece))


func _highlight_color_for_piece(piece: PieceInstance) -> Color:
	if piece.type == GameConstants.PieceType.HBOMB:
		return Color(1.0, 0.35, 0.35, 0.75)
	match GameConstants.piece_movement_domain(piece.type):
		GameConstants.MovementDomain.SEA:
			return Color(0.72, 0.76, 0.82, 0.9)
		GameConstants.MovementDomain.AIR:
			return Color(0.85, 0.9, 0.45, 0.65)
		_:
			return Color(0.95, 0.85, 0.35, 0.55)


func _log_last_order() -> void:
	var orders: Array[GameOrder] = _state.orders_for_camp(_state.human_camp)
	if orders.is_empty():
		return
	var last: GameOrder = orders[orders.size() - 1]
	_log.append_text(last.bbcode_label() + "\n")


func _phase_name(phase: GameConstants.GamePhase) -> String:
	match phase:
		GameConstants.GamePhase.PLANNING: return "Planification"
		GameConstants.GamePhase.RESOLUTION: return "Résolution"
		GameConstants.GamePhase.GAME_OVER: return "Fin"
		_: return "?"


func _select_sector(sector_id: String) -> void:
	if _selected_piece_id >= 0:
		var active: PieceInstance = _selected_piece()
		if active != null and active.in_reserve:
			var hq: String = BoardCatalog.hq_for_camp(_state.human_camp)
			if sector_id == hq:
				_on_deploy_pressed()
				return
		if active != null and not active.in_reserve and sector_id != active.sector_id:
			var dests := _state.destinations_for(active)
			if sector_id in dests:
				_try_move_to(sector_id)
				return

	_selected_sector = sector_id
	_sector_pick_index = 0
	_selected_piece_id = -1

	if _board_map.has_method("set_selected"):
		_board_map.call("set_selected", sector_id)
	_update_sector_panel()
	_refresh_ui()


func _cycle_movable_piece(sector_id: String) -> void:
	var movable := _movable_human_on_sector(sector_id)
	if movable.size() <= 1:
		return
	_sector_pick_index = (_sector_pick_index + 1) % movable.size()
	_selected_piece_id = movable[_sector_pick_index].id


func _select_movable_piece_by_index(sector_id: String, index: int) -> void:
	var movable := _movable_human_on_sector(sector_id)
	if movable.is_empty():
		_selected_piece_id = -1
		return
	_sector_pick_index = index % movable.size()
	_selected_piece_id = movable[_sector_pick_index].id


func _try_move_to(to_sector: String) -> void:
	var piece: PieceInstance = _state.find_piece(_selected_piece_id)
	if piece == null:
		return
	var err: String = _state.try_move_human_piece(piece, to_sector)
	if err.is_empty():
		_log_last_order()
		_selected_sector = to_sector
		_selected_piece_id = -1
		_update_sector_panel()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)
	_refresh_ui()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_map_sector_pressed(sector_id: String) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_select_sector(sector_id)


func _on_sector_selected(index: int) -> void:
	_select_sector(BoardCatalog.SECTOR_IDS[index])


func _update_sector_panel() -> void:
	_piece_list.clear()
	_dest_list.clear()
	if _selected_sector.is_empty():
		return
	for p: PieceInstance in _state.human_pieces_on_sector(_selected_sector):
		var idx: int = _piece_list.get_item_count()
		_piece_list.add_item("%s (id %d)" % [p.label(), p.id])
		_piece_list.set_item_metadata(idx, p.id)
	for p: PieceInstance in _state.reserve_pieces(_state.human_camp):
		if p.sector_id != BoardCatalog.hq_for_camp(_state.human_camp):
			continue
		var idx: int = _piece_list.get_item_count()
		_piece_list.add_item("[réserve] %s (id %d)" % [p.label(), p.id])
		_piece_list.set_item_metadata(idx, p.id)
	if _selected_piece_id >= 0:
		var piece: PieceInstance = _state.find_piece(_selected_piece_id)
		if piece != null and not piece.in_reserve:
			for dest: String in _state.destinations_for(piece):
				var di: int = _dest_list.get_item_count()
				_dest_list.add_item(dest)
				_dest_list.set_item_metadata(di, dest)


func _on_piece_selected(index: int) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_selected_piece_id = int(_piece_list.get_item_metadata(index))
	_update_sector_panel()
	_refresh_ui()


func _on_dest_selected(index: int) -> void:
	_try_move_to(str(_dest_list.get_item_metadata(index)))


func _on_buy_pressed(piece_type: GameConstants.PieceType) -> void:
	var err: String = _state.try_buy_human(piece_type)
	if err.is_empty():
		_log_last_order()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)
	_refresh_ui()


func _on_buy_soldier_pressed() -> void:
	_on_buy_pressed(GameConstants.PieceType.SOLDIER)


func _on_buy_raider_pressed() -> void:
	_on_buy_pressed(GameConstants.PieceType.RAIDER)


func _on_buy_hunter_pressed() -> void:
	_on_buy_pressed(GameConstants.PieceType.HUNTER)


func _on_buy_cruiser_pressed() -> void:
	_on_buy_pressed(GameConstants.PieceType.CRUISER)


func _on_exchange_pressed(result_type: GameConstants.PieceType) -> void:
	var err: String = _state.try_exchange_human(result_type)
	if err.is_empty():
		_log_last_order()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)
	_refresh_ui()


func _on_exchange_commando_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.COMMANDO)


func _on_exchange_bomber_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.BOMBER)


func _on_exchange_fighter_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.FIGHTER)


func _on_exchange_destroyer_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.DESTROYER)


func _on_hbomb_fuse_pressed() -> void:
	if _selected_sector.is_empty():
		return
	var err: String = _state.try_place_hbomb_human(_selected_sector)
	if err.is_empty():
		_log.append_text("[color=#ff6666]Bombe H posée sur %s[/color]\n" % _selected_sector)
		_select_movable_piece_by_index(_selected_sector, 0)
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)
	_refresh_ui()


func _on_deploy_pressed() -> void:
	if _selected_piece_id < 0 and _piece_list.get_item_count() > 0:
		_selected_piece_id = int(_piece_list.get_item_metadata(0))
	var piece: PieceInstance = _state.find_piece(_selected_piece_id)
	if piece == null:
		return
	var hq: String = BoardCatalog.hq_for_camp(_state.human_camp)
	var err: String = _state.try_deploy_human(piece, hq)
	if err.is_empty():
		_log_last_order()
		_selected_sector = hq
		_selected_piece_id = -1
		_update_sector_panel()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)
	_refresh_ui()


func _on_end_round_pressed() -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_log.append_text("[color=#555577]── R%d ──[/color]\n" % _state.round_number)
	for line: String in AiPlanner.run_all_ai(_state):
		_log.append_text(line + "\n")
	var conflict_sectors := _conflict_sectors()
	_state.set_phase(GameConstants.GamePhase.RESOLUTION)
	_refresh_ui()
	if _board_map.has_method("flash_sectors") and not conflict_sectors.is_empty():
		_board_map.call(
			"flash_sectors",
			PackedStringArray(conflict_sectors),
			Color(1.0, 0.55, 0.35, 0.8),
			0.9,
		)
	for line: String in _state.end_planning_round():
		_log.append_text(line + "\n")
	_check_game_over()
	_planning_elapsed = 1
	_timer_accum = 0.0
	_refresh_ui()


func _conflict_sectors() -> Array[String]:
	var result: Array[String] = []
	var seen: Dictionary = {}
	for p: PieceInstance in _state.pieces:
		if p.in_reserve or seen.has(p.sector_id):
			continue
		var camps: Dictionary = {}
		for s: PieceInstance in _state.pieces_on_sector(p.sector_id):
			if s.type == GameConstants.PieceType.HBOMB:
				continue
			camps[s.camp] = true
		if camps.size() > 1:
			result.append(p.sector_id)
		seen[p.sector_id] = true
	return result


func _check_game_over() -> void:
	var alive: int = 0
	var winner: GameConstants.Camp = GameConstants.Camp.GREEN
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if _state.is_alive(camp):
			alive += 1
			winner = camp
	if alive <= 1 and _state.round_number > 1:
		_state.set_phase(GameConstants.GamePhase.GAME_OVER)
		var msg: String = "Victoire : %s" % GameConstants.camp_to_string(winner)
		_log.append_text("\n[color=yellow]%s[/color]\n" % msg)
		if _game_over_label:
			_game_over_label.text = msg


func _on_replay_pressed() -> void:
	if _game_over_layer:
		_game_over_layer.visible = false
	_begin_match()
	_select_sector(BoardCatalog.hq_for_camp(_state.human_camp))
	_refresh_ui()


func _on_phase_changed(_phase: GameConstants.GamePhase) -> void:
	_refresh_ui()


func _on_round_advanced(round_number: int) -> void:
	_log.append_text("—— Manche %d ——\n" % round_number)
	_planning_elapsed = 1
	_timer_accum = 0.0


func _on_sidebar_unit_pressed(piece_type: GameConstants.PieceType) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING or _selected_sector.is_empty():
		return
	_select_piece_type_on_sector(_selected_sector, piece_type)
	_refresh_ui()


func _select_piece_type_on_sector(sector_id: String, piece_type: GameConstants.PieceType) -> void:
	for p: PieceInstance in _state.human_pieces_on_sector(sector_id):
		if p.type == piece_type and not _state.has_piece_moved(p.id):
			_selected_piece_id = p.id
			return
	var hq: String = BoardCatalog.hq_for_camp(_state.human_camp)
	if sector_id == hq:
		for p: PieceInstance in _state.reserve_pieces(_state.human_camp):
			if p.type == piece_type and not _state.has_piece_moved(p.id):
				_selected_piece_id = p.id
				return
	_selected_piece_id = -1


func _on_piece_moved(_piece_id: int, _from_sector: String, _to_sector: String) -> void:
	_selected_piece_id = -1
	_refresh_ui()


func _on_power_changed(_camp: GameConstants.Camp, _amount: int) -> void:
	_refresh_ui()
