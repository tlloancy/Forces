class_name BattleSidebar
extends Control
## Panneaux latéraux — icônes atlas, pas de doublons texte/symboles.

const UiPieceIcons = preload("res://scripts/ui/ui_piece_icons.gd")

signal unit_pressed(piece_type: GameConstants.PieceType)

@onready var _case_title: Label = %CaseTitle
@onready var _case_units: HBoxContainer = %CaseUnitsRow
@onready var _case_piece_icon: TextureRect = %CasePieceIcon
@onready var _case_piece_meta: Label = %CasePieceMeta
@onready var _reserve_power: Label = %ReservePower
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
@onready var _orders_timer: Label = %OrdersTimer
@onready var _orders_queue: RichTextLabel = %OrdersQueue

var _unit_buttons: Array[Button] = []
var _icons_ready: bool = false


func _ready() -> void:
	_wire_static_icons()


func _wire_static_icons() -> void:
	if _icons_ready:
		return
	_icons_ready = true
	UiPieceIcons.setup_buy_button(_buy_soldier, GameConstants.PieceType.SOLDIER, 2)
	UiPieceIcons.setup_buy_button(_buy_raider, GameConstants.PieceType.RAIDER, 3)
	UiPieceIcons.setup_buy_button(_buy_hunter, GameConstants.PieceType.HUNTER, 5)
	UiPieceIcons.setup_buy_button(_buy_cruiser, GameConstants.PieceType.CRUISER, 10)
	UiPieceIcons.setup_exchange_button(_ex_cmd, GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO)
	UiPieceIcons.setup_exchange_button(_ex_bmb, GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER)
	UiPieceIcons.setup_exchange_button(_ex_ftr, GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER)
	UiPieceIcons.setup_exchange_button(_ex_dst, GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER)
	var hb_tex: Texture2D = UiPieceIcons.texture_hbomb()
	if hb_tex != null:
		_hbomb.icon = hb_tex
		_hbomb.expand_icon = true
	_hbomb.text = "100"
	_deploy.text = "↓"


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

	if selected_sector != "":
		var short := BoardCatalog.sector_short_label(selected_sector)
		_case_title.text = short

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

		if not counts.is_empty():
			_build_unit_buttons(counts, selected_piece)

	if selected_piece != null:
		_case_piece_icon.texture = UiPieceIcons.texture_for_piece(selected_piece.type, true)
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

	var fusion_f: int = state.hbomb_fusion_force_available(human_camp, selected_sector)
	_reserve_power.text = "P%d ☢%d" % [state.camp_power(human_camp), fusion_f]

	_orders_timer.text = "R%d %s" % [state.round_number, _format_timer(planning_elapsed)]
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
		var btn: Button = UiPieceIcons.make_unit_button(piece_type, n)
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
		lines.append("[color=#888]—[/color]")
	lines.append("[color=#aaa](%d/%d)[/color]" % [used, max_o])
	return "\n".join(lines)


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
