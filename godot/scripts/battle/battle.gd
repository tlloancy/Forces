extends Control

const RoundResolverScript = preload("res://scripts/core/round_resolver.gd")
const PowerToastScript = preload("res://scripts/battle/power_toast.gd")

@onready var _status: Label = %StatusLabel
@onready var _sector_list: ItemList = %SectorList
@onready var _dest_list: ItemList = %DestList
@onready var _piece_list: ItemList = %PieceList
@onready var _feed: BattleFeed = %FeedPanel
@onready var _end_round_btn: Button = %EndRoundButton
@onready var _undo_order_btn: Button = %UndoOrderButton
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
@onready var _pause_layer: CanvasLayer = $PauseLayer

var _state: GameState
var _selected_sector: String = ""
var _selected_piece_id: int = -1
var _sector_pick_index: int = 0
var _planning_elapsed: int = 1
var _timer_accum: float = 0.0
var _power_toast: PowerToast
func _ready() -> void:
	_state = GameState.new()
	_state.human_camp = GameSession.human_camp
	_state.phase_changed.connect(_on_phase_changed)
	_state.round_advanced.connect(_on_round_advanced)
	_state.piece_moved.connect(_on_piece_moved)
	_state.power_changed.connect(_on_power_changed)
	_board_map.sector_pressed.connect(_on_map_sector_pressed)
	_power_toast = PowerToastScript.new()
	add_child(_power_toast)
	if _sidebar.has_signal("unit_pressed"):
		_sidebar.unit_pressed.connect(_on_sidebar_unit_pressed)
	if _sidebar.has_signal("reserve_unit_pressed"):
		_sidebar.reserve_unit_pressed.connect(_on_reserve_unit_pressed)
	if _undo_order_btn:
		_undo_order_btn.pressed.connect(_on_undo_order_pressed)
	_style_sidebar()
	if _game_over_layer:
		_game_over_layer.visible = false
	if _pause_layer:
		_pause_layer.visible = false
		var pause_panel: PanelContainer = _pause_layer.get_node_or_null("Center/Panel") as PanelContainer
		if pause_panel:
			MenuTheme.style_panel(pause_panel)
		for btn_name: String in ["Center/Panel/VBox/ResumeButton", "Center/Panel/VBox/MenuButtonPause"]:
			var pb: Button = _pause_layer.get_node_or_null(btn_name) as Button
			if pb:
				MenuTheme.style_primary_button(pb)
	if _game_over_layer:
		var go_panel: PanelContainer = _game_over_layer.get_node("Center/Panel") as PanelContainer
		if go_panel:
			MenuTheme.style_panel(go_panel)
	AudioManager.play_battle_music()
	_populate_sector_list()
	var saved: Dictionary = GameSession.take_saved_battle()
	if saved.is_empty():
		_begin_match()
	else:
		_restore_battle_snapshot(saved)
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
				if _feed:
					_feed.push_error(line)
			_check_game_over()
			_refresh_ui()
			return
		_update_feed_hud()


func _style_sidebar() -> void:
	for panel_name: String in ["HudBar", "ReservePanel", "CasePanel", "OrdersPanel"]:
		var panel: PanelContainer = _sidebar.get_node_or_null(panel_name) as PanelContainer
		if panel:
			MenuTheme.style_dock_panel(panel)
	var feed_panel: PanelContainer = get_node_or_null("FeedRail/FeedPanel") as PanelContainer
	if feed_panel:
		MenuTheme.style_dock_panel(feed_panel)
	var deploy_btn: Button = _sidebar.get_node_or_null("ReservePanel/DockVBox/DeployButton") as Button
	if deploy_btn:
		MenuTheme.style_deploy_button(deploy_btn)
	for btn_name: String in [
		"ReservePanel/DockVBox/ReserveActions/BuySoldierButton",
		"ReservePanel/DockVBox/ReserveActions/BuyRaiderButton",
		"ReservePanel/DockVBox/ReserveActions/BuyHunterButton",
		"ReservePanel/DockVBox/ReserveActions/BuyCruiserButton",
		"ReservePanel/DockVBox/HbombFuseButton",
		"ReservePanel/DockVBox/ExchangeRow/ExchangeCommandoButton",
		"ReservePanel/DockVBox/ExchangeRow/ExchangeBomberButton",
		"ReservePanel/DockVBox/ExchangeRow/ExchangeFighterButton",
		"ReservePanel/DockVBox/ExchangeRow/ExchangeDestroyerButton",
	]:
		var chip_btn: Button = _sidebar.get_node_or_null(btn_name) as Button
		if chip_btn:
			MenuTheme.style_chip_button(chip_btn)
	for btn_name: String in ["MenuRow/MenuButton", "MenuRow/UndoOrderButton"]:
		var compact_btn: Button = _sidebar.get_node_or_null(btn_name) as Button
		if compact_btn:
			MenuTheme.style_compact_button(compact_btn)
	var end_round: Button = _sidebar.get_node_or_null("MenuRow/EndRoundButton") as Button
	if end_round:
		MenuTheme.style_compact_button(end_round, true)
	var replay_btn: Button = _game_over_layer.get_node_or_null("Center/Panel/VBox/Buttons/ReplayButton") as Button
	if replay_btn:
		MenuTheme.style_primary_button(replay_btn)
	var menu_go_btn: Button = _game_over_layer.get_node_or_null("Center/Panel/VBox/Buttons/MenuButtonGO") as Button
	if menu_go_btn:
		MenuTheme.style_primary_button(menu_go_btn)


func _begin_match() -> void:
	GameSession.clear_saved_battle()
	_state.reset_match()
	_selected_sector = ""   # aucun secteur présélectionné au démarrage
	_selected_piece_id = -1
	_planning_elapsed = 1
	_timer_accum = 0.0
	if _feed:
		_feed.clear()
		_feed.push_system(GameOrder.feed_round_marker(1), true, 0)
		_feed.push_system(GameOrder.feed_planning_hint(GameConstants.MAX_ORDERS_PER_ROUND), true, 1)


func _populate_sector_list() -> void:
	_sector_list.clear()
	for sector_id: String in BoardCatalog.SECTOR_IDS:
		_sector_list.add_item(sector_id)


func _refresh_ui() -> void:
	var planning: bool = _state.phase == GameConstants.GamePhase.PLANNING
	var game_over: bool = _state.phase == GameConstants.GamePhase.GAME_OVER
	_end_round_btn.disabled = not planning
	if _undo_order_btn:
		_undo_order_btn.disabled = not planning or _state.camp_orders_used(_state.human_camp) <= 0
	if _game_over_layer:
		_game_over_layer.visible = game_over
	_buy_soldier_btn.disabled = not planning
	_buy_raider_btn.disabled = not planning
	_buy_hunter_btn.disabled = not planning
	_buy_cruiser_btn.disabled = not planning
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
	_update_feed_hud()
	if _status and planning:
		_status.modulate = Color.WHITE
	if _status:
		_status.text = "%s | %s | orders %d/%d" % [
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


func _update_feed_hud() -> void:
	if _feed == null:
		return
	var max_o: int = GameConstants.MAX_ORDERS_PER_ROUND
	var used: int = _state.camp_orders_used(_state.human_camp)
	_feed.set_hud(
		BattleSidebar._format_timer(_planning_elapsed),
		_state.round_number,
		_state.camp_power(_state.human_camp),
		used,
		max_o,
	)
	_feed.set_planned_orders(_state.orders_for_camp(_state.human_camp), max_o)


func _notify_human_order() -> void:
	# Live queue is rendered by set_planned_orders() via _update_feed_hud().
	pass


func _show_planning_error(msg: String) -> void:
	if _feed:
		_feed.push_error(msg)
	if _status:
		_status.text = msg
		_status.modulate = Color(1.0, 0.55, 0.35)


func _phase_name(phase: GameConstants.GamePhase) -> String:
	match phase:
		GameConstants.GamePhase.PLANNING: return "Planning"
		GameConstants.GamePhase.RESOLUTION: return "Resolution"
		GameConstants.GamePhase.GAME_OVER: return "Game over"
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
		_selected_sector = to_sector
		_selected_piece_id = -1
		_update_sector_panel()
		_notify_human_order()
	else:
		_show_planning_error(err)
	_refresh_ui()


func _on_menu_pressed() -> void:
	_on_save_and_menu()


func _on_pause_pressed() -> void:
	if _pause_layer:
		_pause_layer.visible = true


func _on_pause_resume_pressed() -> void:
	if _pause_layer:
		_pause_layer.visible = false


func _on_save_and_menu() -> void:
	if _state.phase != GameConstants.GamePhase.GAME_OVER:
		GameSession.save_battle(_battle_snapshot())
	else:
		GameSession.clear_saved_battle()
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _battle_snapshot() -> Dictionary:
	return {
		"state": _state.to_snapshot(),
		"planning_elapsed": _planning_elapsed,
		"selected_sector": _selected_sector,
		"selected_piece_id": _selected_piece_id,
		"sector_pick_index": _sector_pick_index,
		"timer_accum": _timer_accum,
	}


func _restore_battle_snapshot(snapshot: Dictionary) -> void:
	_state.restore_from_snapshot(snapshot.get("state", {}) as Dictionary)
	_planning_elapsed = int(snapshot.get("planning_elapsed", 1))
	_selected_sector = str(snapshot.get("selected_sector", ""))
	_selected_piece_id = int(snapshot.get("selected_piece_id", -1))
	_sector_pick_index = int(snapshot.get("sector_pick_index", 0))
	_timer_accum = float(snapshot.get("timer_accum", 0.0))
	if _board_map.has_method("set_selected"):
		_board_map.call("set_selected", _selected_sector)


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
		_piece_list.add_item("[reserve] %s (id %d)" % [p.label(), p.id])
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


func _on_undo_order_pressed() -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	var human_orders: Array[GameOrder] = _state.orders_for_camp(_state.human_camp)
	if human_orders.is_empty():
		return
	var cancelled: GameOrder = human_orders[human_orders.size() - 1]
	var err: String = _state.try_cancel_last_human_order()
	if not err.is_empty():
		_show_planning_error(err)
	else:
		if _feed:
			_feed.push_bbcode(BattleFeed.LineKind.PLAYER, "⊘ " + cancelled.bbcode_label(), 1)
		_selected_piece_id = -1
	_refresh_ui()


func _on_buy_pressed(piece_type: GameConstants.PieceType) -> void:
	var err: String = _state.try_buy_human(piece_type)
	if err.is_empty():
		if _power_toast:
			_power_toast.show_recruit(piece_type, _state.camp_power(_state.human_camp))
	else:
		_show_planning_error(err)
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
		_notify_human_order()
	else:
		_show_planning_error(err)
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
		_notify_human_order()
		_select_movable_piece_by_index(_selected_sector, 0)
	else:
		_show_planning_error(err)
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
		_selected_sector = hq
		_selected_piece_id = -1
		_update_sector_panel()
		_notify_human_order()
	else:
		_show_planning_error(err)
	_refresh_ui()


func _on_end_round_pressed() -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_play_round_resolution()


func _play_round_resolution() -> void:
	if _feed:
		_feed.push_system(GameOrder.feed_resolution_marker(_state.round_number), true)
		_feed.push_ai_block(AiPlanner.run_all_ai(_state), _state.human_camp)
		await _await_feed_typing()

	_state.set_phase(GameConstants.GamePhase.RESOLUTION)
	_end_round_btn.disabled = true
	var phase_logs: Array[String] = []
	_state.capture_round_board_snapshot()

	await _resolve_moves_animated(phase_logs)
	_state.commit_movement_phase()
	_refresh_ui()
	await get_tree().create_timer(0.25).timeout

	phase_logs.clear()
	await _resolve_combats_animated(phase_logs)
	_refresh_ui()
	await get_tree().create_timer(0.2).timeout

	phase_logs.clear()
	_state.resolve_round_flags(phase_logs)
	await _feed_lines(phase_logs)

	phase_logs.clear()
	var power_before_harvest: int = _state.camp_power(_state.human_camp)
	var harvest: Dictionary = _state.resolve_round_harvest(phase_logs)
	var harvest_gain: int = _state.camp_power(_state.human_camp) - power_before_harvest
	if harvest_gain > 0 and _power_toast:
		_power_toast.show_gain(harvest_gain, "Enemy islands occupied", _state.camp_power(_state.human_camp))
	await _feed_lines(phase_logs)
	var human_sectors: Variant = harvest.get(_state.human_camp, PackedStringArray())
	if (
		_board_map.has_method("flash_sectors")
		and human_sectors is PackedStringArray
		and not (human_sectors as PackedStringArray).is_empty()
	):
		_board_map.call(
			"flash_sectors",
			human_sectors,
			Color(0.45, 0.92, 0.55, 0.8),
			0.75,
		)
	_refresh_ui()
	await get_tree().create_timer(0.2).timeout

	_state.finish_round_after_resolution()
	_check_game_over()
	_planning_elapsed = 1
	_timer_accum = 0.0
	if _feed and _state.phase == GameConstants.GamePhase.PLANNING:
		_feed.push_system(GameOrder.feed_planning_hint(GameConstants.MAX_ORDERS_PER_ROUND), false, 1)
	_refresh_ui()


func _feed_lines(lines: Array[String]) -> void:
	if _feed == null:
		return
	for line: String in lines:
		_feed.push_engine_line(line, _state.human_camp)
		await _await_feed_typing()


func _resolve_moves_animated(logs: Array[String]) -> void:
	var phase_line := GameOrder.feed_phase_header(
		RoundResolverScript.PHASE_LABELS[RoundResolverScript.Phase.MOVES],
	)
	logs.append(phase_line)
	await _feed_lines([phase_line])
	for order: GameOrder in _state.pending_orders:
		match order.kind:
			GameOrder.Kind.MOVE, GameOrder.Kind.DEPLOY_FROM_RESERVE:
				if _board_map.has_method("animate_order"):
					await _board_map.call("animate_order", _state, order)
		var chunk: Array[String] = []
		_state.apply_single_order(order, chunk)
		if not chunk.is_empty():
			await _feed_lines(chunk)
		_refresh_ui()


func _resolve_combats_animated(logs: Array[String]) -> void:
	var phase_line := GameOrder.feed_phase_header(
		RoundResolverScript.PHASE_LABELS[RoundResolverScript.Phase.COMBATS],
	)
	logs.append(phase_line)
	await _feed_lines([phase_line])
	var safety: int = 48
	while safety > 0:
		safety -= 1
		var conflicts: PackedStringArray = BattleResolver.conflict_sectors(_state)
		if conflicts.is_empty():
			break
		if _board_map.has_method("flash_sectors"):
			_board_map.call(
				"flash_sectors",
				conflicts,
				Color(1.0, 0.55, 0.35, 0.85),
				0.9,
			)
		await get_tree().create_timer(0.45).timeout
		var retreats: Array[Dictionary] = []
		var chunk: Array[String] = []
		var progressed: bool = false
		var human_captures: Array[GameConstants.PieceType] = []
		for sector_id: String in conflicts:
			var before: Array[PieceInstance] = _state.pieces_on_sector(sector_id).duplicate()
			var outcome: Dictionary = BattleResolver.resolve_sector_result(_state, sector_id)
			var msg: String = str(outcome.get("log", ""))
			if msg.is_empty():
				continue
			chunk.append(msg)
			var is_tie: bool = bool(outcome.get("tie", false))
			if not is_tie:
				progressed = true
			var winner_i: int = int(outcome.get("winner", -1))
			for p: PieceInstance in before:
				var now: PieceInstance = _state.find_piece(p.id)
				if now == null:
					continue
				if now.sector_id == sector_id and now.in_reserve == p.in_reserve:
					continue
				if is_tie:
					retreats.append({
						"mode": "rebound",
						"piece_id": now.id,
						"type": now.type,
						"camp": now.camp,
						"from": sector_id,
						"to": now.sector_id,
					})
				elif now.in_reserve and winner_i >= 0:
					if winner_i == _state.human_camp and p.camp != _state.human_camp:
						human_captures.append(now.type)
					retreats.append({
						"mode": "capture",
						"piece_id": now.id,
						"type": now.type,
						"camp": now.camp,
						"winner_camp": winner_i as GameConstants.Camp,
						"from": sector_id,
						"to": BoardCatalog.hq_for_camp(winner_i as GameConstants.Camp),
					})
		if chunk.is_empty():
			break
		for r: Dictionary in retreats:
			if _board_map.has_method("animate_combat_outcome"):
				await _board_map.call("animate_combat_outcome", _state, r)
			elif _board_map.has_method("animate_retreat"):
				await _board_map.call("animate_retreat", _state, r)
		await _feed_lines(chunk)
		for pt: GameConstants.PieceType in human_captures:
			if _power_toast:
				_power_toast.show_capture(pt, _state.camp_power(_state.human_camp))
		_refresh_ui()
		if not progressed:
			break


func _await_feed_typing() -> void:
	if _feed == null:
		return
	while _feed.is_typing():
		await get_tree().process_frame
	await get_tree().create_timer(0.06).timeout


func _check_game_over() -> void:
	var alive: int = 0
	var winner: GameConstants.Camp = GameConstants.Camp.GREEN
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if _state.is_alive(camp):
			alive += 1
			winner = camp
	if alive <= 1 and _state.round_number > 1:
		_state.set_phase(GameConstants.GamePhase.GAME_OVER)
		var msg: String = GameOrder.feed_victory(winner)
		if _feed:
			_feed.push_bbcode(BattleFeed.LineKind.WIN, msg, 0)
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
	if _feed:
		_feed.push_system(GameOrder.feed_round_marker(round_number), true, 0)
	_planning_elapsed = 1
	_timer_accum = 0.0


func _on_sidebar_unit_pressed(piece_type: GameConstants.PieceType) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING or _selected_sector.is_empty():
		return
	_select_piece_type_on_sector(_selected_sector, piece_type)
	call_deferred("_refresh_ui")


func _on_reserve_unit_pressed(piece_type: GameConstants.PieceType) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	var hq: String = BoardCatalog.hq_for_camp(_state.human_camp)
	_selected_sector = hq
	if _board_map.has_method("set_selected"):
		_board_map.call("set_selected", hq)
	for p: PieceInstance in _state.reserve_pieces(_state.human_camp):
		if p.type == piece_type and not _state.has_piece_moved(p.id):
			_selected_piece_id = p.id
			break
	_update_sector_panel()
	call_deferred("_refresh_ui")


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


func _on_power_changed(camp: GameConstants.Camp, amount: int) -> void:
	if camp != _state.human_camp:
		return
	if _sidebar.has_method("refresh_power_only"):
		_sidebar.call("refresh_power_only", amount)
	var power_lbl: Label = _sidebar.get_node_or_null("%PowerAmount") as Label
	var power_bolt: Label = _sidebar.get_node_or_null("%PowerBolt") as Label
	if power_lbl:
		power_lbl.modulate = Color(1.4, 1.35, 0.7)
	if power_bolt:
		power_bolt.modulate = Color(1.5, 1.45, 0.85)
	await get_tree().create_timer(0.6).timeout
	if power_lbl:
		power_lbl.modulate = Color.WHITE
	if power_bolt:
		power_bolt.modulate = Color.WHITE
	var planning: bool = _state.phase == GameConstants.GamePhase.PLANNING
	_buy_soldier_btn.disabled = not planning
	_buy_raider_btn.disabled = not planning
	_buy_hunter_btn.disabled = not planning
	_buy_cruiser_btn.disabled = not planning
	_update_feed_hud()
