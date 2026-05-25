class_name BattleSidebar
extends Control
## Panneaux latéraux style original (Case Info, Reserve, Orders / timer).

signal unit_pressed(piece_type: GameConstants.PieceType)

@onready var _case_title: Label = %CaseTitle
@onready var _case_hq: Label = %CaseHq
@onready var _case_stats: Label = %CaseStats
@onready var _case_units: HBoxContainer = %CaseUnitsRow
@onready var _case_piece: Label = %CasePiece
@onready var _reserve_power: Label = %ReservePower
@onready var _reserve_outline: Label = %ReserveOutline
@onready var _reserve_counts: Label = %ReserveCounts
@onready var _orders_timer: Label = %OrdersTimer
@onready var _orders_queue: RichTextLabel = %OrdersQueue
@onready var _orders_log: RichTextLabel = %OrdersLog

var _unit_buttons: Array[Button] = []


func refresh(
	state: GameState,
	human_camp: GameConstants.Camp,
	selected_sector: String,
	planning_elapsed: int = 1,
	selected_piece: PieceInstance = null,
) -> void:
	_case_hq.visible = false
	_case_stats.visible = false
	_case_piece.text = ""
	_clear_unit_buttons()

	if selected_sector != "":
		var short := BoardCatalog.sector_short_label(selected_sector)
		_case_title.text = "Case Info — %s" % short
		if selected_sector.begins_with("HQ_"):
			_case_hq.visible = true
			_case_hq.text = "QG"

		var counts: Dictionary = {}
		for p: PieceInstance in state.pieces_on_sector(selected_sector):
			if p.camp != human_camp:
				continue
			var key: int = int(p.type)
			counts[key] = int(counts.get(key, 0)) + 1

		if selected_sector == BoardCatalog.hq_for_camp(human_camp):
			for p: PieceInstance in state.reserve_pieces(human_camp):
				if state.has_piece_moved(p.id):
					continue
				var rk: int = int(p.type)
				counts[rk] = int(counts.get(rk, 0)) + 1

		if counts.is_empty():
			_case_stats.visible = true
			_case_stats.text = "—"
		else:
			_build_unit_buttons(counts, selected_piece)

	if selected_piece != null:
		if selected_piece.in_reserve:
			_case_piece.text = "Réserve : %s — touchez le QG ou Déployer" % selected_piece.label()
		else:
			var domain := GameConstants.movement_domain_label(
				GameConstants.piece_movement_domain(selected_piece.type)
			)
			var hint := "cases surlignées = destinations"
			match GameConstants.piece_movement_domain(selected_piece.type):
				GameConstants.MovementDomain.LAND:
					hint = "cases dorées (portée %d)" % GameConstants.unity_land_nbmove(selected_piece.type)
				GameConstants.MovementDomain.SEA:
					hint = "couloirs bleus Sp + côte (1 case mer)"
				GameConstants.MovementDomain.AIR:
					hint = "cases jaunes (portée air)"
			_case_piece.text = "Active : %s [%s] — %s" % [
				selected_piece.label(),
				domain,
				hint,
			]

	var fusion_f: int = state.hbomb_fusion_force_available(human_camp, selected_sector)
	_reserve_power.text = "Power %d  |  fusion %d F" % [
		state.camp_power(human_camp),
		fusion_f,
	]
	var hbomb_board: bool = state.hbomb_on_board(human_camp) != null
	var res: Dictionary = {}
	for p: PieceInstance in state.reserve_pieces(human_camp):
		var k: String = _shape_label(p.type)
		res[k] = int(res.get(k, 0)) + 1
	var outline_row := _shape_row(["●", "■", "▲", "◆"], res, true)
	var count_row := _shape_row(["●", "■", "▲", "◆"], res, false)
	if hbomb_board:
		outline_row += "  ☢ en jeu"
		count_row += "  ☢"
	_reserve_outline.text = outline_row
	_reserve_counts.text = count_row

	_orders_timer.text = "Manche %d — timer %s" % [
		state.round_number,
		_format_timer(planning_elapsed),
	]
	_orders_queue.text = _format_orders_queue(state, human_camp)


func _clear_unit_buttons() -> void:
	for btn: Button in _unit_buttons:
		btn.queue_free()
	_unit_buttons.clear()


func _build_unit_buttons(counts: Dictionary, selected_piece: PieceInstance) -> void:
	var types: Array = counts.keys()
	types.sort()
	for key: Variant in types:
		var piece_type: GameConstants.PieceType = key as GameConstants.PieceType
		var n: int = int(counts[key])
		var btn := Button.new()
		btn.text = "%s %s %d" % [_shape_label(piece_type), _short_type(piece_type), n]
		btn.focus_mode = Control.FOCUS_NONE
		if selected_piece != null and selected_piece.type == piece_type:
			btn.modulate = Color(1.0, 0.95, 0.7)
		btn.pressed.connect(_on_unit_button_pressed.bind(piece_type))
		_case_units.add_child(btn)
		_unit_buttons.append(btn)


func _on_unit_button_pressed(piece_type: GameConstants.PieceType) -> void:
	unit_pressed.emit(piece_type)


static func _format_orders_queue(state: GameState, human_camp: GameConstants.Camp) -> String:
	var used: int = state.camp_orders_used(human_camp)
	var max_o: int = GameConstants.MAX_ORDERS_PER_ROUND
	var lines: PackedStringArray = PackedStringArray()
	for order: GameOrder in state.orders_for_camp(human_camp):
		lines.append("[color=#e8a060]%s[/color]" % order.pad_label())
	if lines.is_empty():
		lines.append("[color=#888]— aucun ordre —[/color]")
	lines.append("[color=#aaa](%d/%d)[/color]" % [used, max_o])
	return "\n".join(lines)


static func _format_timer(elapsed: int) -> String:
	var clamped: int = clampi(elapsed, 1, GameConstants.PLANNING_TIMER_SECONDS)
	var sec_left: int = 60 - (clamped % 60)
	if sec_left == 60:
		sec_left = 0
	var min_left: int = 59 - (clamped / 60)
	if sec_left == 0 and clamped % 60 == 0:
		min_left -= 1
	var ss: String = "%02d" % sec_left
	var mm: String = "%d" % maxi(0, min_left)
	return "%s:%s" % [mm, ss]


func _shape_row(symbols: PackedStringArray, counts: Dictionary, outline: bool) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for sym: String in symbols:
		var n: int = int(counts.get(sym, 0)) if not outline else 0
		parts.append("%s %d" % [sym, n])
	return "  ".join(parts)


static func _short_type(piece_type: GameConstants.PieceType) -> String:
	match piece_type:
		GameConstants.PieceType.SOLDIER:
			return "Sold."
		GameConstants.PieceType.RAIDER:
			return "Tank"
		GameConstants.PieceType.HUNTER:
			return "Chas."
		GameConstants.PieceType.CRUISER:
			return "Crois."
		GameConstants.PieceType.COMMANDO:
			return "Rég."
		GameConstants.PieceType.BOMBER:
			return "Bmb."
		GameConstants.PieceType.FIGHTER:
			return "Ch.l"
		GameConstants.PieceType.DESTROYER:
			return "Destr."
		_:
			return ""


static func _shape_label(piece_type: GameConstants.PieceType) -> String:
	match piece_type:
		GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO:
			return "●"
		GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER:
			return "■"
		GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER:
			return "▲"
		GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER:
			return "◆"
		GameConstants.PieceType.HBOMB:
			return "☢"
		_:
			return "·"
