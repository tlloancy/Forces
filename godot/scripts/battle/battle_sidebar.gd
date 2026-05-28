class_name BattleSidebar
extends Control
## Command dock — pièces identiques au plateau, grilles chevauchées, scroll.

const PieceIcons = preload("res://scripts/ui/ui_piece_icons.gd")
const PieceChipScript = preload("res://scripts/ui/piece_chip.gd")

const CHIP := PieceChipScript.CHIP_MD
const CHIP_LG := PieceChipScript.CHIP_LG
const CHIP_ORDER := 40.0

signal unit_pressed(piece_type: GameConstants.PieceType)
signal reserve_unit_pressed(piece_type: GameConstants.PieceType)

@onready var _case_title: Label = %CaseTitle
@onready var _hq_label: Label = %HQLabel
@onready var _case_units: HBoxContainer = %CaseUnitsRow
@onready var _orders_list: VBoxContainer = %OrdersList
@onready var _reserve_scroll: ScrollContainer = %ReserveScroll
@onready var _reserve_units: HBoxContainer = %ReserveUnitsRow
@onready var _power_bolt: Label = %PowerBolt
@onready var _power_amount: Label = %PowerAmount
@onready var _reserve_title: Label = %ReserveTitle
@onready var _reserve_summary: Label = %ReserveSummary
@onready var _reserve_panel: PanelContainer = %ReservePanel
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
@onready var _exchange_row: HBoxContainer = %ExchangeRow

var _unit_chips: Array[PieceChip] = []
var _reserve_chips: Array[PieceChip] = []
var _active_chip: PieceChip
var _icons_ready: bool = false


func _ready() -> void:
	_pin_reserve_panel()
	_wire_static_icons()
	_apply_typography()
	if _reserve_scroll:
		_reserve_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		_reserve_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED


func _pin_reserve_panel() -> void:
	if _reserve_panel == null:
		return
	var scroll: ScrollContainer = $ScrollDock
	_reserve_panel.reparent(self)
	move_child(_reserve_panel, scroll.get_index())


func _apply_typography() -> void:
	_case_title.add_theme_font_size_override("font_size", 20)
	_hq_label.add_theme_font_size_override("font_size", 18)
	_power_bolt.add_theme_font_size_override("font_size", 32)
	_power_amount.add_theme_font_size_override("font_size", 28)
	if _reserve_title:
		_reserve_title.add_theme_font_size_override("font_size", 16)


func _wire_static_icons() -> void:
	PieceIcons.setup_buy_button(_buy_soldier, GameConstants.PieceType.SOLDIER, 2)
	PieceIcons.setup_buy_button(_buy_raider, GameConstants.PieceType.RAIDER, 3)
	PieceIcons.setup_buy_button(_buy_hunter, GameConstants.PieceType.HUNTER, 5)
	PieceIcons.setup_buy_button(_buy_cruiser, GameConstants.PieceType.CRUISER, 10)
	if _icons_ready:
		return
	_icons_ready = true
	PieceIcons.setup_exchange_button(_ex_cmd, GameConstants.PieceType.SOLDIER, GameConstants.PieceType.COMMANDO)
	PieceIcons.setup_exchange_button(_ex_bmb, GameConstants.PieceType.RAIDER, GameConstants.PieceType.BOMBER)
	PieceIcons.setup_exchange_button(_ex_ftr, GameConstants.PieceType.HUNTER, GameConstants.PieceType.FIGHTER)
	PieceIcons.setup_exchange_button(_ex_dst, GameConstants.PieceType.CRUISER, GameConstants.PieceType.DESTROYER)
	PieceIcons.setup_hbomb_button(_hbomb)
	_hbomb.visible = false
	if _deploy:
		_deploy.text = "⚑ Deploy reserve → HQ"
		_deploy.tooltip_text = "Select a unit above, then deploy it onto your HQ"
	if _exchange_row:
		_exchange_row.visible = false


func refresh(
	state: GameState,
	human_camp: GameConstants.Camp,
	selected_sector: String,
	_planning_elapsed: int = 1,
	selected_piece: PieceInstance = null,
) -> void:
	_wire_static_icons()
	_clear_chips()
	_update_deploy_button(state, human_camp, selected_piece)

	var is_hq: bool = (selected_sector != "" and selected_sector == BoardCatalog.hq_for_camp(human_camp))
	_hq_label.text = "⚑" if is_hq else ""

	if selected_sector.is_empty():
		_case_title.text = "—"
		_case_title.remove_theme_color_override("font_color")
	else:
		_case_title.text = BoardCatalog.sector_short_label(selected_sector)
		if BoardCatalog.is_neutral(selected_sector):
			_case_title.add_theme_color_override("font_color", Color(0.53, 0.6, 0.73))
		else:
			var sector_camp: GameConstants.Camp = BoardCatalog.camp_for_sector(selected_sector)
			_case_title.add_theme_color_override("font_color", GameConstants.CAMP_COLORS[sector_camp])
		var by_camp: Dictionary = state.sector_presence_counts(selected_sector)
		if by_camp.is_empty():
			_add_empty_hint(_case_units)
		else:
			var camps: Array = by_camp.keys()
			camps.sort_custom(func(a: GameConstants.Camp, b: GameConstants.Camp) -> bool:
				if a == human_camp:
					return true
				if b == human_camp:
					return false
				return int(a) < int(b)
			)
			for camp: GameConstants.Camp in camps:
				var counts: Dictionary = by_camp[camp] as Dictionary
				_add_sector_chips(counts, selected_piece, camp, camp == human_camp)

	_build_reserve_row(state, human_camp, selected_piece)
	_rebuild_orders_list(state, human_camp)

	var power: int = state.camp_power(human_camp)
	_set_power_display(power)

	var fusion_on_sector: int = state.camp_power(human_camp)
	var has_piece_on_board: bool = false
	if not selected_sector.is_empty():
		var presence: Dictionary = state.sector_presence_counts(selected_sector)
		if presence.has(human_camp):
			var human_counts: Dictionary = presence[human_camp] as Dictionary
			has_piece_on_board = not human_counts.is_empty()
			if has_piece_on_board:
				for key: Variant in human_counts:
					var pt: GameConstants.PieceType = key as GameConstants.PieceType
					if pt != GameConstants.PieceType.HBOMB:
						fusion_on_sector += int(human_counts[key]) * GameConstants.reserve_force_value(pt)
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


func _rebuild_orders_list(state: GameState, human_camp: GameConstants.Camp) -> void:
	if _orders_list == null:
		return
	for child: Node in _orders_list.get_children():
		_orders_list.remove_child(child)
		child.queue_free()
	var orders: Array[GameOrder] = state.orders_for_camp(human_camp)
	if orders.is_empty():
		var hint := Label.new()
		hint.text = "○○○○○"
		hint.add_theme_font_size_override("font_size", 16)
		hint.add_theme_color_override("font_color", Color(0.35, 0.55, 0.42))
		_orders_list.add_child(hint)
		return
	for i: int in orders.size():
		_orders_list.add_child(_make_order_row(orders[i], i + 1, human_camp))


func _make_order_row(order: GameOrder, slot: int, human_camp: GameConstants.Camp) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.custom_minimum_size = Vector2(0, 44)

	var slot_lbl := Label.new()
	slot_lbl.text = "O%d" % slot
	slot_lbl.add_theme_font_size_override("font_size", 16)
	slot_lbl.add_theme_color_override("font_color", Color(0.45, 0.75, 0.52))
	slot_lbl.custom_minimum_size = Vector2(28, 0)
	row.add_child(slot_lbl)

	var ptype: GameConstants.PieceType = _order_piece_type(order)
	var camp_color: Color = GameConstants.CAMP_COLORS.get(human_camp, Color.WHITE) as Color
	var chip: PieceChip = PieceChip.new().configure(ptype, camp_color, 1, CHIP_ORDER, false)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(chip)

	var detail := RichTextLabel.new()
	detail.bbcode_enabled = true
	detail.fit_content = true
	detail.scroll_active = false
	detail.autowrap_mode = TextServer.AUTOWRAP_OFF
	detail.text = order.detail_bbcode()
	detail.add_theme_font_size_override("normal_font_size", 16)
	detail.add_theme_font_size_override("bold_font_size", 16)
	detail.add_theme_color_override("default_color", Color(0.88, 0.92, 0.96))
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size = Vector2(0, 22)
	row.add_child(detail)
	return row


static func _order_piece_type(order: GameOrder) -> GameConstants.PieceType:
	match order.kind:
		GameOrder.Kind.EXCHANGE:
			return order.exchange_result
		GameOrder.Kind.HBOMB_PLACE, GameOrder.Kind.HBOMB_STRIKE:
			return GameConstants.PieceType.HBOMB
		_:
			return order.piece_type


func refresh_power_only(power: int) -> void:
	_set_power_display(power)


func _set_power_display(power: int) -> void:
	if _power_amount:
		_power_amount.text = str(power)


func _update_reserve_header(unit_counts: Dictionary) -> void:
	if _reserve_title == null or _reserve_summary == null:
		return
	_reserve_title.text = "RESERVE"
	if unit_counts.is_empty():
		_reserve_summary.text = "Empty — buy units below with ⚡"
		return
	var parts: PackedStringArray = PackedStringArray()
	var types: Array = unit_counts.keys()
	types.sort()
	for key: Variant in types:
		var piece_type: GameConstants.PieceType = key as GameConstants.PieceType
		var n: int = int(unit_counts[key])
		parts.append("%d× %s" % [n, GameConstants.piece_type_label(piece_type)])
	_reserve_summary.text = ", ".join(parts)


func _clear_chips() -> void:
	_unit_chips.clear()
	_reserve_chips.clear()
	for row: Node in [_case_units, _reserve_units]:
		if row == null:
			continue
		for child: Node in row.get_children():
			row.remove_child(child)
			child.queue_free()


func _update_deploy_button(
	state: GameState,
	human_camp: GameConstants.Camp,
	selected_piece: PieceInstance,
) -> void:
	if _deploy == null:
		return
	var planning: bool = state.phase == GameConstants.GamePhase.PLANNING
	var hq: String = BoardCatalog.hq_for_camp(human_camp)
	var can_deploy: bool = (
		selected_piece != null
		and selected_piece.in_reserve
		and not state.has_piece_moved(selected_piece.id)
	)
	if can_deploy:
		var label: String = GameConstants.piece_type_label(selected_piece.type)
		_deploy.text = "⚑ Deploy %s → HQ" % label
		_deploy.tooltip_text = "Send %s from reserve to your HQ (%s)" % [label, hq]
	elif (
		planning
		and selected_piece != null
		and selected_piece.in_reserve
		and state.has_piece_moved(selected_piece.id)
	):
		_deploy.text = "⚑ Order queued"
		_deploy.tooltip_text = "This unit already has a deploy order"
	else:
		_deploy.text = "⚑ Deploy reserve → HQ"
		_deploy.tooltip_text = "Tap a unit in RESERVE, then press here (or tap your HQ on the map)"
	_deploy.disabled = not planning or not can_deploy


func _add_empty_hint(row: Control) -> void:
	var hint := Label.new()
	hint.text = "∅"
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(0.45, 0.5, 0.58))
	row.add_child(hint)


func _add_reserve_empty_hint(row: Control) -> void:
	var hint := Label.new()
	hint.text = "—"
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(0.35, 0.4, 0.48))
	row.add_child(hint)


func _add_sector_chips(
	counts: Dictionary,
	selected_piece: PieceInstance,
	camp: GameConstants.Camp,
	interactive: bool,
) -> void:
	var camp_color: Color = GameConstants.CAMP_COLORS.get(camp, Color.WHITE) as Color
	var types: Array = counts.keys()
	types.sort()
	for key: Variant in types:
		var piece_type: GameConstants.PieceType = key as GameConstants.PieceType
		var n: int = int(counts[key])
		var hi: bool = (
			selected_piece != null
			and selected_piece.camp == camp
			and selected_piece.type == piece_type
		)
		var chip: PieceChip = PieceChip.new().configure(piece_type, camp_color, n, CHIP, hi)
		if interactive:
			chip.chip_pressed.connect(_on_unit_chip.bind(piece_type))
		else:
			chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_case_units.add_child(chip)
		_unit_chips.append(chip)


func _build_reserve_row(
	state: GameState,
	human_camp: GameConstants.Camp,
	selected_piece: PieceInstance,
) -> void:
	var counts: Dictionary = {}
	var reserve_list: Array[PieceInstance] = state.reserve_pieces(human_camp)
	for p: PieceInstance in reserve_list:
		var key: int = int(p.type)
		counts[key] = int(counts.get(key, 0)) + 1
	_update_reserve_header(counts)
	if reserve_list.is_empty():
		_add_reserve_empty_hint(_reserve_units)
		_update_buy_affordability(state, human_camp)
		return
	var camp_color: Color = GameConstants.CAMP_COLORS.get(human_camp, Color.WHITE) as Color
	reserve_list.sort_custom(func(a: PieceInstance, b: PieceInstance) -> bool:
		return int(a.type) < int(b.type)
	)
	for p: PieceInstance in reserve_list:
		var hi: bool = selected_piece != null and selected_piece.id == p.id
		var chip: PieceChip = PieceChip.new().configure(p.type, camp_color, 1, CHIP_LG, hi)
		if state.has_piece_moved(p.id):
			chip.modulate = Color(0.72, 0.72, 0.78, 0.85)
			chip.tooltip_text += " (order queued)"
		chip.chip_pressed.connect(_on_reserve_chip.bind(p.type))
		_reserve_units.add_child(chip)
		_reserve_chips.append(chip)
	_update_buy_affordability(state, human_camp)


func _update_buy_affordability(state: GameState, human_camp: GameConstants.Camp) -> void:
	var power: int = state.camp_power(human_camp)
	var planning: bool = state.phase == GameConstants.GamePhase.PLANNING
	for pair: Array in [
		[_buy_soldier, GameConstants.PieceType.SOLDIER],
		[_buy_raider, GameConstants.PieceType.RAIDER],
		[_buy_hunter, GameConstants.PieceType.HUNTER],
		[_buy_cruiser, GameConstants.PieceType.CRUISER],
	]:
		var btn: Button = pair[0] as Button
		var pt: GameConstants.PieceType = pair[1] as GameConstants.PieceType
		if btn == null:
			continue
		var cost: int = int(GameConstants.PIECE_STATS.get(pt, {}).get("power_cost", 99))
		btn.disabled = not planning or power < cost


func _on_unit_chip(piece_type: GameConstants.PieceType) -> void:
	unit_pressed.emit(piece_type)


func _on_reserve_chip(piece_type: GameConstants.PieceType) -> void:
	reserve_unit_pressed.emit(piece_type)


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
