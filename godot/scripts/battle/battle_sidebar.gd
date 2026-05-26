class_name BattleSidebar
extends Control
## Panneaux latéraux — icônes atlas, pas de doublons texte/symboles.

const PieceIcons = preload("res://scripts/ui/ui_piece_icons.gd")

signal unit_pressed(piece_type: GameConstants.PieceType)
signal reserve_unit_pressed(piece_type: GameConstants.PieceType)

@onready var _case_title: Label = %CaseTitle
@onready var _hq_label: Label = %HQLabel
@onready var _case_units: HBoxContainer = %CaseUnitsRow
@onready var _case_piece_icon: TextureRect = %CasePieceIcon
@onready var _case_piece_meta: Label = %CasePieceMeta
@onready var _reserve_power: Label = %ReservePower
@onready var _reserve_units_row: HBoxContainer = %ReserveUnitsRow
@onready var _reserve_stock_label: Label = $ReservePanel/VBox/ReserveStockLabel
@onready var _buy_soldier: Button = %BuySoldierButton
@onready var _buy_raider: Button = %BuyRaiderButton
@onready var _buy_hunter: Button = %BuyHunterButton
@onready var _buy_cruiser: Button = %BuyCruiserButton
@onready var _deploy: Button = %DeployButton
@onready var _hbomb: Button = %HbombFuseButton
@onready var _ex_cmd: Button = %ExchangeCommandoButton
@onready var _ex_bmb: Button = %ExchangeBomberButton
@onready var _ex_ftr: Button = %ExchangeFighterButton
@onready var _ex_dst: Button = %ExchangeDestroyerButton
@onready var _exchange_row: HBoxContainer = $ReservePanel/VBox/ExchangeRow

var _unit_buttons: Array[Button] = []
var _reserve_buttons: Array[Button] = []
var _icons_ready: bool = false


func _ready() -> void:
	_wire_static_icons()


func _wire_static_icons() -> void:
	if _icons_ready:
		return
	_icons_ready = true
	PieceIcons.setup_buy_button(_buy_soldier, GameConstants.PieceType.SOLDIER, 2)
	PieceIcons.setup_buy_button(_buy_raider, GameConstants.PieceType.RAIDER, 3)
	PieceIcons.setup_buy_button(_buy_hunter, GameConstants.PieceType.HUNTER, 5)
	PieceIcons.setup_buy_button(_buy_cruiser, GameConstants.PieceType.CRUISER, 10)
	PieceIcons.setup_exchange_button(_ex_cmd, GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO)
	PieceIcons.setup_exchange_button(_ex_bmb, GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER)
	PieceIcons.setup_exchange_button(_ex_ftr, GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER)
	PieceIcons.setup_exchange_button(_ex_dst, GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER)
	PieceIcons.setup_hbomb_button(_hbomb)
	_hbomb.visible = false
	_deploy.text = "↓"
	if _exchange_row:
		_exchange_row.visible = false


func refresh(
	state: GameState,
	human_camp: GameConstants.Camp,
	selected_sector: String,
	planning_elapsed: int = 1,
	selected_piece: PieceInstance = null,
) -> void:
	_wire_static_icons()
	_case_piece_icon.texture = null
	_case_piece_meta.text = ""
	_clear_unit_buttons()
	_clear_reserve_buttons()
	_build_reserve_row(state, human_camp, selected_piece)

	var is_hq: bool = (selected_sector != "" and selected_sector == BoardCatalog.hq_for_camp(human_camp))
	_hq_label.text = "HQ" if is_hq else ""

	if selected_sector.is_empty():
		_case_title.text = "—"
	else:
		var short := BoardCatalog.sector_short_label(selected_sector)
		_case_title.text = short

		var counts: Dictionary = {}
		for p: PieceInstance in state.pieces_on_sector(selected_sector):
			if p.camp != human_camp:
				continue
			var key: int = int(p.type)
			counts[key] = int(counts.get(key, 0)) + 1

		if not counts.is_empty():
			_build_unit_buttons(counts, selected_piece, human_camp)

	if selected_piece != null:
		_case_piece_icon.texture = PieceIcons.texture_for_piece(selected_piece.type, true)
		if selected_piece.in_reserve:
			_case_piece_meta.text = "↓"
		else:
			match GameConstants.piece_movement_domain(selected_piece.type):
				GameConstants.MovementDomain.LAND:
					_case_piece_meta.text = str(GameConstants.unity_land_nbmove(selected_piece.type))
				GameConstants.MovementDomain.SEA:
					_case_piece_meta.text = "◇"
				GameConstants.MovementDomain.AIR:
					_case_piece_meta.text = "▲"
				_:
					_case_piece_meta.text = ""

	var power: int = state.camp_power(human_camp)
	_reserve_power.text = "P%d" % power
	_reserve_power.tooltip_text = "Forces disponibles (achats, fusion H)"
	var fusion_on_sector: int = state.camp_power(human_camp)
	var has_piece_on_board: bool = false
	if not selected_sector.is_empty():
		for p: PieceInstance in state.pieces_on_sector(selected_sector):
			if p.camp == human_camp and not p.in_reserve and p.type != GameConstants.PieceType.HBOMB:
				has_piece_on_board = true
				fusion_on_sector += GameConstants.reserve_force_value(p.type)
	var fusion_ok: bool = (
		has_piece_on_board
		and state.hbomb_on_board(human_camp) == null
		and fusion_on_sector >= GameConstants.HBOMB_FUSION_FORCE
	)
	_hbomb.visible = fusion_ok
	if fusion_ok:
		PieceIcons.setup_hbomb_button(_hbomb)
	var any_exchange: bool = false
	for result: GameConstants.PieceType in [
		GameConstants.PieceType.COMMANDO,
		GameConstants.PieceType.BOMBER,
		GameConstants.PieceType.FIGHTER,
		GameConstants.PieceType.DESTROYER,
	]:
		if _can_exchange(state, human_camp, result):
			any_exchange = true
			break
	if _exchange_row:
		_exchange_row.visible = any_exchange

func _clear_unit_buttons() -> void:
	for btn: Button in _unit_buttons:
		btn.queue_free()
	_unit_buttons.clear()


func _clear_reserve_buttons() -> void:
	for btn: Button in _reserve_buttons:
		btn.queue_free()
	_reserve_buttons.clear()


func _build_reserve_row(
	state: GameState,
	human_camp: GameConstants.Camp,
	selected_piece: PieceInstance,
) -> void:
	var counts: Dictionary = {}
	for p: PieceInstance in state.reserve_pieces(human_camp):
		if state.has_piece_moved(p.id):
			continue
		var key: int = int(p.type)
		counts[key] = int(counts.get(key, 0)) + 1
	if counts.is_empty():
		_reserve_stock_label.text = "Réserve (vide)"
		return
	_reserve_stock_label.text = "Réserve"
	var camp_color: Color = GameConstants.CAMP_COLORS.get(human_camp, Color.WHITE) as Color
	var types: Array = counts.keys()
	types.sort()
	for key: Variant in types:
		var piece_type: GameConstants.PieceType = key as GameConstants.PieceType
		var n: int = int(counts[key])
		var btn: Button = PieceIcons.make_unit_button(piece_type, n, camp_color)
		if selected_piece != null and selected_piece.in_reserve and selected_piece.type == piece_type:
			btn.modulate = Color(1.3, 1.2, 0.8)
		btn.pressed.connect(_on_reserve_unit_pressed.bind(piece_type))
		_reserve_units_row.add_child(btn)
		_reserve_buttons.append(btn)


func _on_reserve_unit_pressed(piece_type: GameConstants.PieceType) -> void:
	reserve_unit_pressed.emit(piece_type)


func _build_unit_buttons(
	counts: Dictionary,
	selected_piece: PieceInstance,
	human_camp: GameConstants.Camp,
) -> void:
	var camp_color: Color = GameConstants.CAMP_COLORS.get(human_camp, Color.WHITE) as Color
	var types: Array = counts.keys()
	types.sort()
	for key: Variant in types:
		var piece_type: GameConstants.PieceType = key as GameConstants.PieceType
		var n: int = int(counts[key])
		var btn: Button = PieceIcons.make_unit_button(piece_type, n, camp_color)
		if selected_piece != null and selected_piece.type == piece_type:
			btn.modulate = Color(1.3, 1.2, 0.8)
		btn.pressed.connect(_on_unit_button_pressed.bind(piece_type))
		_case_units.add_child(btn)
		_unit_buttons.append(btn)


func _on_unit_button_pressed(piece_type: GameConstants.PieceType) -> void:
	unit_pressed.emit(piece_type)


static func _can_exchange(state: GameState, camp: GameConstants.Camp, result: GameConstants.PieceType) -> bool:
	var recipe: Dictionary = GameConstants.exchange_recipe(result)
	if recipe.is_empty():
		return false
	var from_type: GameConstants.PieceType = recipe["from"]
	var need: int = int(recipe["count"])
	var n: int = 0
	for p: PieceInstance in state.reserve_pieces(camp):
		if p.type == from_type:
			n += 1
	return n >= need


static func _format_timer(elapsed: int) -> String:
	var clamped: int = clampi(elapsed, 1, GameConstants.PLANNING_TIMER_SECONDS)
	var sec_left: int = 60 - (clamped % 60)
	if sec_left == 60:
		sec_left = 0
	var min_left: int = 59 - int(clamped / 60.0)
	if sec_left == 0 and clamped % 60 == 0:
		min_left -= 1
	var ss: String = "%02d" % sec_left
	var mm: String = "%d" % maxi(0, min_left)
	return "%s:%s" % [mm, ss]
