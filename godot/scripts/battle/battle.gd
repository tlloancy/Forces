extends Control

const AiPlanner = preload("res://scripts/ai/ai_planner.gd")

@onready var _title: Label = %TitleLabel
@onready var _status: Label = %StatusLabel
@onready var _sector_list: ItemList = %SectorList
@onready var _dest_list: ItemList = %DestList
@onready var _piece_list: ItemList = %PieceList
@onready var _log: RichTextLabel = %LogLabel
@onready var _end_round_btn: Button = %EndRoundButton
@onready var _pieces_label: Label = %PiecesLabel
@onready var _board_map: Control = %BoardMap
@onready var _power_label: Label = %PowerLabel
@onready var _buy_soldier_btn: Button = %BuySoldierButton
@onready var _buy_raider_btn: Button = %BuyRaiderButton
@onready var _buy_hunter_btn: Button = %BuyHunterButton
@onready var _buy_cruiser_btn: Button = %BuyCruiserButton
@onready var _deploy_btn: Button = %DeployButton

var _state: GameState
var _selected_sector: String = ""
var _selected_piece_id: int = -1


func _ready() -> void:
	_state = GameState.new()
	_state.human_camp = GameSession.human_camp
	_state.phase_changed.connect(_on_phase_changed)
	_state.round_advanced.connect(_on_round_advanced)
	_state.piece_moved.connect(_on_piece_moved)
	_state.power_changed.connect(_on_power_changed)
	_pieces_label.text = "Vos pièces (%s)" % GameConstants.camp_to_string(_state.human_camp).to_lower()
	_board_map.sector_pressed.connect(_on_map_sector_pressed)
	_sector_list.visible = false
	AudioManager.play_battle_music()
	_populate_sector_list()
	_begin_match()
	_refresh_ui()


func _begin_match() -> void:
	_state.reset_match()
	_selected_sector = ""
	_selected_piece_id = -1
	_log.append_text("[i]Forces — bataille[/i]\n")
	for line: String in GameSession.setup_summary_lines():
		_log.append_text("  · %s\n" % line)
	_log.append_text("\n[color=green]Manche 1[/color] — planifiez vos ordres (max %d).\n" % GameConstants.MAX_ORDERS_PER_ROUND)
	_log.append_text("[color=yellow]Power[/color] : recrutez ou fusionnez en réserve, puis déployez sur votre QG.\n")


func _populate_sector_list() -> void:
	_sector_list.clear()
	for sector_id: String in BoardCatalog.SECTOR_IDS:
		var idx: int = _sector_list.get_item_count()
		_sector_list.add_item(sector_id)
		var camp: GameConstants.Camp = BoardCatalog.camp_for_sector(sector_id)
		_sector_list.set_item_custom_fg_color(idx, GameConstants.CAMP_COLORS[camp])


func _refresh_ui() -> void:
	_title.text = "Forces — Bataille"
	var alive_count: int = 0
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if _state.is_alive(camp):
			alive_count += 1
	_status.text = "Phase: %s | Manche %d | Vos ordres %d/%d | Camps %d" % [
		_phase_name(_state.phase),
		_state.round_number,
		_state.camp_orders_used(_state.human_camp),
		GameConstants.MAX_ORDERS_PER_ROUND,
		alive_count,
	]
	_power_label.text = "Power : %d  |  Réserve : %d" % [
		_state.camp_power(_state.human_camp),
		_state.reserve_pieces(_state.human_camp).size(),
	]
	var planning: bool = _state.phase == GameConstants.GamePhase.PLANNING
	_end_round_btn.disabled = not planning
	_buy_soldier_btn.disabled = not planning
	_buy_raider_btn.disabled = not planning
	_buy_hunter_btn.disabled = not planning
	_buy_cruiser_btn.disabled = not planning
	_deploy_btn.disabled = not planning or _selected_piece_id < 0
	if _board_map.has_method("refresh"):
		_board_map.call("refresh", _state)


func _phase_name(phase: GameConstants.GamePhase) -> String:
	match phase:
		GameConstants.GamePhase.MENU: return "Menu"
		GameConstants.GamePhase.PLANNING: return "Planification"
		GameConstants.GamePhase.RESOLUTION: return "Résolution"
		GameConstants.GamePhase.GAME_OVER: return "Fin de partie"
		_: return "?"


func _select_sector(sector_id: String) -> void:
	_selected_sector = sector_id
	_selected_piece_id = -1
	var idx: int = BoardCatalog.SECTOR_IDS.find(sector_id)
	if idx >= 0:
		_sector_list.select(idx)
	if _board_map.has_method("set_selected"):
		_board_map.call("set_selected", sector_id)
	_update_sector_panel()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_map_sector_pressed(sector_id: String) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_select_sector(sector_id)


func _on_sector_selected(index: int) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_select_sector(BoardCatalog.SECTOR_IDS[index])


func _update_sector_panel() -> void:
	_piece_list.clear()
	_dest_list.clear()
	if _selected_sector.is_empty():
		return
	var stack: Array[PieceInstance] = _state.pieces_on_sector(_selected_sector)
	if stack.is_empty():
		_log.append_text("Case vide : [b]%s[/b]\n" % _selected_sector)
	else:
		_log.append_text("Case [b]%s[/b] — " % _selected_sector)
		for p: PieceInstance in stack:
			_log.append_text("%s/%s (F%d) " % [
				GameConstants.camp_to_string(p.camp),
				p.label(),
				p.combat_force(),
			])
		_log.append_text("\n")
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
			var dests: PackedStringArray = _state.destinations_for(piece)
			for dest: String in dests:
				var di: int = _dest_list.get_item_count()
				_dest_list.add_item(dest)
				_dest_list.set_item_metadata(di, dest)


func _on_piece_selected(index: int) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_selected_piece_id = int(_piece_list.get_item_metadata(index))
	_update_sector_panel()
	var piece: PieceInstance = _state.find_piece(_selected_piece_id)
	if piece != null:
		if piece.in_reserve:
			_log.append_text("Réserve : %s — déployez sur votre QG\n" % piece.label())
		else:
			_log.append_text("Pièce : %s\n" % piece.label())
			_log.append_text("  → %s\n" % BoardGraph.format_destinations(piece.type, piece.sector_id, int(GameConstants.PIECE_STATS[piece.type]["max_move"])))


func _on_dest_selected(index: int) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING or _selected_piece_id < 0:
		return
	var to_sector: String = str(_dest_list.get_item_metadata(index))
	var piece: PieceInstance = _state.find_piece(_selected_piece_id)
	if piece == null:
		return
	var err: String = _state.try_move_human_piece(piece, to_sector)
	if err.is_empty():
		_log.append_text("[color=cyan]Déplacement OK[/color] → %s\n" % to_sector)
		AudioManager.play_sfx("res://assets/audio/GoConquer.mp3")
		_selected_sector = to_sector
		_selected_piece_id = -1
		_update_sector_panel()
		_refresh_ui()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)


func _on_buy_pressed(piece_type: GameConstants.PieceType) -> void:
	var err: String = _state.try_buy_human(piece_type)
	if err.is_empty():
		_log.append_text("[color=gold]Recruté[/color] : %s → réserve\n" % GameConstants.piece_type_label(piece_type))
		_refresh_ui()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)


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
		_log.append_text("[color=gold]Fusion[/color] : %s → réserve\n" % GameConstants.piece_type_label(result_type))
		_refresh_ui()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)


func _on_exchange_commando_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.COMMANDO)


func _on_exchange_bomber_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.BOMBER)


func _on_exchange_fighter_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.FIGHTER)


func _on_exchange_destroyer_pressed() -> void:
	_on_exchange_pressed(GameConstants.PieceType.DESTROYER)


func _on_deploy_pressed() -> void:
	if _selected_piece_id < 0:
		return
	var piece: PieceInstance = _state.find_piece(_selected_piece_id)
	if piece == null:
		return
	var hq: String = BoardCatalog.hq_for_camp(_state.human_camp)
	var err: String = _state.try_deploy_human(piece, hq)
	if err.is_empty():
		_log.append_text("[color=cyan]Déploiement[/color] %s → %s\n" % [piece.label(), hq])
		_selected_sector = hq
		_selected_piece_id = -1
		_update_sector_panel()
		_refresh_ui()
	else:
		_log.append_text("[color=orange]%s[/color]\n" % err)


func _on_end_round_pressed() -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_log.append_text("\n[b]Fin de manche %d[/b]\n" % _state.round_number)
	for line: String in AiPlanner.run_all_ai(_state):
		_log.append_text(line + "\n")
	for line: String in _state.end_planning_round():
		_log.append_text(line + "\n")
	_check_game_over()
	_refresh_ui()


func _check_game_over() -> void:
	var alive: int = 0
	var winner: GameConstants.Camp = GameConstants.Camp.GREEN
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		if _state.is_alive(camp):
			alive += 1
			winner = camp
	if alive <= 1 and _state.round_number > 1:
		_state.set_phase(GameConstants.GamePhase.GAME_OVER)
		_log.append_text("\n[color=yellow][b]Victoire : %s[/b][/color]\n" % GameConstants.camp_to_string(winner))


func _on_phase_changed(phase: GameConstants.GamePhase) -> void:
	_log.append_text("→ Phase [b]%s[/b]\n" % _phase_name(phase))
	_refresh_ui()


func _on_round_advanced(round_number: int) -> void:
	_log.append_text("—— Manche %d —— (+ %d Power/camp)\n" % [round_number, GameConstants.POWER_PER_ROUND])


func _on_piece_moved(_piece_id: int, _from_sector: String, _to_sector: String) -> void:
	_refresh_ui()


func _on_power_changed(_camp: GameConstants.Camp, _amount: int) -> void:
	_refresh_ui()
