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

var _state: GameState
var _selected_sector: String = ""
var _selected_piece_id: int = -1


func _ready() -> void:
	_state = GameState.new()
	_state.human_camp = GameSession.human_camp
	_state.phase_changed.connect(_on_phase_changed)
	_state.round_advanced.connect(_on_round_advanced)
	_state.piece_moved.connect(_on_piece_moved)
	_pieces_label.text = "Vos pièces (%s)" % GameConstants.camp_to_string(_state.human_camp).to_lower()
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
	_end_round_btn.disabled = _state.phase != GameConstants.GamePhase.PLANNING

func _phase_name(phase: GameConstants.GamePhase) -> String:
	match phase:
		GameConstants.GamePhase.MENU: return "Menu"
		GameConstants.GamePhase.PLANNING: return "Planification"
		GameConstants.GamePhase.RESOLUTION: return "Résolution"
		GameConstants.GamePhase.GAME_OVER: return "Fin de partie"
		_: return "?"


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_sector_selected(index: int) -> void:
	if _state.phase != GameConstants.GamePhase.PLANNING:
		return
	_selected_sector = BoardCatalog.SECTOR_IDS[index]
	_selected_piece_id = -1
	_update_sector_panel()


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
	if _selected_piece_id >= 0:
		var piece: PieceInstance = _state.find_piece(_selected_piece_id)
		if piece != null:
			var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece.type, null)
			if stats_variant == null or typeof(stats_variant) != TYPE_DICTIONARY:
				return
			var stats: Dictionary = stats_variant as Dictionary
			var max_move: int = int(stats.get("max_move", 1))
			var dests: PackedStringArray = BoardGraph.land_destinations(piece.sector_id, max_move)
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
		var max_move: int = 1
		var stats_variant: Variant = GameConstants.PIECE_STATS.get(piece.type, null)
		if stats_variant != null and typeof(stats_variant) == TYPE_DICTIONARY:
			var stats: Dictionary = stats_variant as Dictionary
			max_move = int(stats.get("max_move", 1))
			_log.append_text("Pièce : %s — portée terre %d\n" % [piece.label(), max_move])
		_log.append_text("  → %s\n" % BoardGraph.format_destinations(piece.sector_id, max_move))


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
		_selected_sector = to_sector
		_selected_piece_id = -1
		_update_sector_panel()
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
	_log.append_text("—— Manche %d ——\n" % round_number)


func _on_piece_moved(piece_id: int, from_sector: String, to_sector: String) -> void:
	_status.text = "Déplacé %d : %s → %s" % [piece_id, from_sector, to_sector]
	_refresh_ui()
