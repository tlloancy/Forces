class_name BattleFeed
extends PanelContainer
## Terminal Matrix — symboles + couleurs camp, pas de prose.

enum LineKind { SYSTEM, PLAYER, PHASE, COMBAT, HARVEST, ENEMY, ERROR, WIN }

const MAX_LINES: int = 120
const BASE_CHARS_PER_SEC: float = 60.0
const CURSOR: String = "▌"

const COLOR: Dictionary = {
	LineKind.SYSTEM: "#4a9960",
	LineKind.PLAYER: "#7dffb2",
	LineKind.PHASE: "#6ab0ff",
	LineKind.COMBAT: "#ff9a5c",
	LineKind.HARVEST: "#ffe066",
	LineKind.ENEMY: "#c88cff",
	LineKind.ERROR: "#ff6666",
	LineKind.WIN: "#fff3a0",
}

@onready var _out: RichTextLabel = %FeedOutput
@onready var _status: Label = %FeedStatus
@onready var _orders_out: RichTextLabel = %OrdersOutput

var _lines: Array[String] = []
var _typing_plain: String = ""
var _typing_kind: LineKind = LineKind.SYSTEM
var _typing_char: int = 0
var _typing_active: bool = false
var _typing_speed: float = BASE_CHARS_PER_SEC
var _typing_indent: int = 0


func _ready() -> void:
	_out.bbcode_enabled = true
	_out.scroll_following = true
	_out.scroll_active = true
	_out.autowrap_mode = TextServer.AUTOWRAP_OFF
	_out.add_theme_constant_override("line_separation", 8)
	_out.add_theme_font_size_override("normal_font_size", 17)
	_out.add_theme_font_size_override("bold_font_size", 17)
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.015, 0.05, 0.025, 0.97)
	box.border_color = Color(0.15, 0.55, 0.28, 0.45)
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	add_theme_stylebox_override("panel", box)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clear()


func _process(delta: float) -> void:
	if not _typing_active:
		return
	var step: int = maxi(1, int(_typing_speed * delta))
	_typing_char = mini(_typing_char + step, _typing_plain.length())
	_render()
	if _typing_char >= _typing_plain.length():
		_commit_typing()


func _gui_input(event: InputEvent) -> void:
	if not _typing_active:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_typing_char = _typing_plain.length()
		_commit_typing()
		_render()
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		_typing_char = _typing_plain.length()
		_commit_typing()
		_render()


func clear() -> void:
	_lines.clear()
	_typing_active = false
	_typing_plain = ""
	set_planned_orders([], GameConstants.MAX_ORDERS_PER_ROUND)
	_render()
	push_system("▸ ◎", true, 0)
	push_system(GameOrder.feed_boot_line(), true, 1)


func set_hud(timer: String, round_n: int, power: int, orders_used: int, orders_max: int) -> void:
	_status.text = "%s  ◎%d  ⚡%d  %s" % [
		timer,
		round_n,
		power,
		GameOrder.feed_slot_dots(orders_used, orders_max),
	]


func set_planned_orders(orders: Array[GameOrder], max_orders: int) -> void:
	if _orders_out == null:
		return
	var parts: PackedStringArray = PackedStringArray()
	if orders.is_empty():
		parts.append(
			"[p][color=#3a6848]├─ [/color][color=#588860]%s[/color][/p]"
			% GameOrder.feed_slot_dots(0, max_orders)
		)
	else:
		for i: int in orders.size():
			var order: GameOrder = orders[i]
			parts.append(
				"[p][color=#3a6848]├─ [/color]%s[/p]" % order.feed_bbcode(i + 1, max_orders)
			)
	_orders_out.text = "".join(parts)


func push_system(text: String, instant: bool = false, indent: int = 0) -> void:
	_push(LineKind.SYSTEM, text, instant, indent)


func push_player(text: String, instant: bool = false) -> void:
	_push(LineKind.PLAYER, text, instant, 1)


func push_error(text: String) -> void:
	_push(LineKind.ERROR, "✕ " + text, true, 1)


func push_order_planned(order: GameOrder, _human_camp: GameConstants.Camp, slot: int, max_o: int) -> void:
	push_bbcode(LineKind.PLAYER, order.feed_bbcode(slot, max_o), 1)


func push_bbcode(kind: LineKind, bbcode: String, indent: int = 0) -> void:
	if bbcode.is_empty():
		return
	if kind == LineKind.PHASE and not _lines.is_empty():
		_lines.append("")
	_lines.append(_format_line(kind, bbcode, indent))
	_trim()
	_render()


func push_engine_line(raw: String, human_camp: GameConstants.Camp) -> void:
	var s: String = raw.strip_edges()
	if s.is_empty():
		return
	var kind: LineKind = _kind_for_line(s, human_camp)
	var indent: int = _default_indent(kind)
	if kind == LineKind.PHASE and not _lines.is_empty():
		_lines.append("")
	_lines.append(_format_line(kind, s, indent))
	_trim()
	_render()


func push_ai_block(lines: Array[String], human_camp: GameConstants.Camp) -> void:
	for line: String in lines:
		var plain: String = _strip_bbcode(line).strip_edges()
		if plain.is_empty():
			continue
		if plain.begins_with("◈"):
			push_bbcode(LineKind.ENEMY, line.strip_edges(), 0)
		elif plain == "· —" or plain.begins_with("(aucun"):
			push_bbcode(LineKind.ENEMY, GameOrder.feed_no_orders(), 2)
		elif line.strip_edges().contains("[color="):
			push_engine_line(line.strip_edges(), human_camp)
		else:
			push_engine_line(line.strip_edges(), human_camp)


func is_typing() -> bool:
	return _typing_active


func _push(kind: LineKind, text: String, instant: bool, indent: int = 0) -> void:
	if text.is_empty():
		return
	if kind == LineKind.PHASE and not _lines.is_empty():
		_lines.append("")
	if instant or text.contains("[color="):
		_lines.append(_format_line(kind, text, indent))
		_trim()
		_render()
	else:
		if _typing_active:
			_commit_typing()
		_typing_kind = kind
		_typing_plain = text
		_typing_indent = indent
		_typing_speed = _speed_for(kind, text)
		_typing_char = 0
		_typing_active = true
		_render()


func _commit_typing() -> void:
	if _typing_plain.is_empty():
		_typing_active = false
		return
	_lines.append(_format_line(_typing_kind, _typing_plain, _typing_indent))
	_typing_plain = ""
	_typing_active = false
	_trim()


func _format_line(kind: LineKind, text: String, indent: int) -> String:
	var tree: String = _tree_prefix(indent)
	if text.contains("[color=") or text.contains("[/color]"):
		return "%s%s" % [tree, text]
	var c: String = str(COLOR.get(kind, "#7dffb2"))
	return "%s[color=%s]%s%s[/color]" % [tree, c, _prefix(kind), text]


func _tree_prefix(indent: int) -> String:
	match indent:
		1:
			return "[color=#3a6848]├─ [/color]"
		2:
			return "[color=#3a6848]│ ├─ [/color]"
		3:
			return "[color=#3a6848]│ │ ├─ [/color]"
		_:
			return ""


func _default_indent(kind: LineKind) -> int:
	match kind:
		LineKind.PHASE, LineKind.WIN:
			return 0
		LineKind.PLAYER:
			return 1
		LineKind.ERROR:
			return 1
		LineKind.COMBAT, LineKind.HARVEST, LineKind.ENEMY:
			return 2
		_:
			return 1


func _prefix(kind: LineKind) -> String:
	match kind:
		LineKind.SYSTEM:
			return "> "
		LineKind.PLAYER:
			return "» "
		LineKind.PHASE:
			return ""
		LineKind.COMBAT:
			return ""
		LineKind.HARVEST:
			return ""
		LineKind.ENEMY:
			return ""
		LineKind.ERROR:
			return "!! "
		LineKind.WIN:
			return ""
		_:
			return ""


func _kind_for_line(s: String, _human_camp: GameConstants.Camp) -> LineKind:
	var plain: String = _strip_bbcode(s)
	if plain.begins_with("★"):
		return LineKind.WIN
	if plain.begins_with("⏱") or plain.begins_with("✕"):
		return LineKind.ERROR
	if plain.begins_with("▸") or plain.begins_with("◎"):
		return LineKind.PHASE
	if plain.begins_with("⚔") or plain.begins_with("H☠") or plain.begins_with("⚑"):
		return LineKind.COMBAT
	if plain.begins_with("⚡"):
		return LineKind.HARVEST
	if plain.begins_with("◈"):
		return LineKind.ENEMY
	if plain.begins_with("·"):
		return LineKind.ENEMY
	if "→" in plain or "↓" in plain or plain.begins_with("+"):
		return LineKind.PLAYER
	return LineKind.SYSTEM


func _render() -> void:
	var parts: PackedStringArray = PackedStringArray()
	for bb: String in _lines:
		if bb.is_empty():
			parts.append("[p] [/p]")
		else:
			parts.append("[p]%s[/p]" % bb)
	if _typing_active:
		var partial: String = _typing_plain.left(_typing_char)
		parts.append("[p]%s[/p]" % _format_line(_typing_kind, partial + CURSOR, _typing_indent))
	_out.text = "".join(parts)


func _trim() -> void:
	while _lines.size() > MAX_LINES:
		_lines.pop_front()


func _speed_for(kind: LineKind, text: String) -> float:
	var speed: float = BASE_CHARS_PER_SEC
	match kind:
		LineKind.PHASE:
			speed = 84.0
		LineKind.COMBAT:
			speed = 76.0
		LineKind.HARVEST:
			speed = 72.0
		LineKind.ERROR:
			speed = 100.0
		LineKind.WIN:
			speed = 95.0
		_:
			speed = BASE_CHARS_PER_SEC
	if text.length() > 72:
		speed += 16.0
	if _lines.size() > 85:
		speed += 20.0
	return speed


func _strip_bbcode(text: String) -> String:
	var out: String = text
	var re := RegEx.new()
	re.compile("\\[/?[^\\]]+\\]")
	out = re.sub(out, "", true)
	return out
