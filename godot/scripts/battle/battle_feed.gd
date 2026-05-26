class_name BattleFeed
extends PanelContainer
## Terminal Matrix — flux lisible, défilement + frappe caractère par caractère.

enum LineKind { SYSTEM, PLAYER, PHASE, COMBAT, HARVEST, ENEMY, ERROR, WIN }

const MAX_LINES: int = 120
const CHARS_PER_SEC: float = 55.0
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

var _lines: Array[String] = []
var _typing_plain: String = ""
var _typing_kind: LineKind = LineKind.SYSTEM
var _typing_char: int = 0
var _typing_active: bool = false


func _ready() -> void:
	_out.bbcode_enabled = true
	_out.scroll_following = true
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.015, 0.05, 0.025, 0.97)
	box.border_color = Color(0.15, 0.55, 0.28, 0.45)
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	add_theme_stylebox_override("panel", box)
	clear()


func _process(delta: float) -> void:
	if not _typing_active:
		return
	var step: int = maxi(1, int(CHARS_PER_SEC * delta))
	_typing_char = mini(_typing_char + step, _typing_plain.length())
	_render()
	if _typing_char >= _typing_plain.length():
		_commit_typing()


func clear() -> void:
	_lines.clear()
	_typing_active = false
	_typing_plain = ""
	_render()
	push_system("FORCES.EXE — liaison tactique ouverte", true)
	push_system("Le flux ci-dessous décrit chaque action en direct.", true)


func set_hud(timer: String, round_n: int, power: int, orders_used: int, orders_max: int) -> void:
	_status.text = "%s  MANCHE %d  P%d  [%d/%d]" % [timer, round_n, power, orders_used, orders_max]


func push_system(text: String, instant: bool = false) -> void:
	_push(LineKind.SYSTEM, text, instant)


func push_player(text: String, instant: bool = false) -> void:
	_push(LineKind.PLAYER, text, instant)


func push_error(text: String) -> void:
	_push(LineKind.ERROR, text, true)


func push_order_planned(order: GameOrder, human_camp: GameConstants.Camp, slot: int, max_o: int) -> void:
	push_player(order.feed_line(human_camp, slot, max_o), false)


func push_engine_line(raw: String, human_camp: GameConstants.Camp) -> void:
	var parsed: Dictionary = _interpret_engine_line(_strip_bbcode(raw), human_camp)
	if parsed.is_empty():
		return
	var kind: LineKind = parsed.get("kind", LineKind.SYSTEM) as LineKind
	var text: String = str(parsed.get("text", ""))
	if text.is_empty():
		return
	_push(kind, text, false)


func push_ai_block(lines: Array[String], human_camp: GameConstants.Camp) -> void:
	for line: String in lines:
		var plain: String = _strip_bbcode(line).strip_edges()
		if plain.is_empty():
			continue
		if plain.begins_with("◈"):
			_push(LineKind.ENEMY, plain, false)
		else:
			push_engine_line(plain, human_camp)


func is_typing() -> bool:
	return _typing_active


func _push(kind: LineKind, text: String, instant: bool) -> void:
	if text.is_empty():
		return
	if instant:
		_lines.append(_line_bbcode(kind, text))
		_trim()
		_render()
	else:
		if _typing_active:
			_commit_typing()
		_typing_kind = kind
		_typing_plain = text
		_typing_char = 0
		_typing_active = true
		_render()


func _commit_typing() -> void:
	if _typing_plain.is_empty():
		_typing_active = false
		return
	_lines.append(_line_bbcode(_typing_kind, _typing_plain))
	_typing_plain = ""
	_typing_active = false
	_trim()


func _line_bbcode(kind: LineKind, text: String) -> String:
	var c: String = str(COLOR.get(kind, "#7dffb2"))
	return "[color=%s]%s[/color] [color=%s]%s[/color]" % [c, _prefix(kind), c, text]


func _prefix(kind: LineKind) -> String:
	match kind:
		LineKind.SYSTEM:
			return "> "
		LineKind.PLAYER:
			return "» "
		LineKind.PHASE:
			return "══ "
		LineKind.COMBAT:
			return "⚔ "
		LineKind.HARVEST:
			return "⚡ "
		LineKind.ENEMY:
			return "◇ "
		LineKind.ERROR:
			return "!! "
		LineKind.WIN:
			return "★ "
		_:
			return "  "


func _render() -> void:
	var parts: PackedStringArray = PackedStringArray()
	for bb: String in _lines:
		parts.append(bb)
	if _typing_active:
		var partial: String = _typing_plain.left(_typing_char)
		parts.append(_line_bbcode(_typing_kind, partial + CURSOR))
	_out.text = "\n".join(parts)


func _trim() -> void:
	while _lines.size() > MAX_LINES:
		_lines.pop_front()


func _strip_bbcode(text: String) -> String:
	var out: String = text
	var re := RegEx.new()
	re.compile("\\[/?[^\\]]+\\]")
	out = re.sub(out, "", true)
	return out


func _interpret_engine_line(plain: String, human_camp: GameConstants.Camp) -> Dictionary:
	var s: String = plain.strip_edges()
	if s.is_empty():
		return {}
	if s.begins_with("▸") or s.to_upper().begins_with("ORDRES") or s.to_upper().begins_with("COMBATS"):
		var phase: String = s.trim_prefix("▸").strip_edges()
		return {"kind": LineKind.PHASE, "text": "— %s —" % phase.to_upper()}
	if s.begins_with("Combat"):
		return {"kind": LineKind.COMBAT, "text": _humanize_combat(s, human_camp)}
	if "Force" in s or "île" in s:
		return {"kind": LineKind.HARVEST, "text": _humanize_harvest(s, human_camp)}
	if "éliminé" in s or "drapeau" in s.to_lower():
		return {"kind": LineKind.COMBAT, "text": s}
	if s.begins_with("Bombe H"):
		return {"kind": LineKind.COMBAT, "text": s}
	if s.begins_with("Égalité") or s.contains("galité"):
		return {"kind": LineKind.COMBAT, "text": s}
	if s.begins_with("Victoire"):
		return {"kind": LineKind.WIN, "text": s}
	if s.begins_with("──") or s.begins_with("——"):
		return {"kind": LineKind.PHASE, "text": s}
	if s.begins_with("·") or s.begins_with("  ·"):
		s = s.trim_prefix("·").strip_edges()
		return _interpret_move_line(s, human_camp)
	if s.contains("→"):
		return _interpret_move_line(s, human_camp)
	if s.contains("déploie") or s.contains("pose bombe"):
		return {"kind": LineKind.ENEMY, "text": s}
	if s.begins_with("Revenu") or "+3" in s:
		return {"kind": LineKind.HARVEST, "text": "Revenu de manche : +3 Forces pour chaque camp encore en jeu."}
	return {"kind": LineKind.SYSTEM, "text": s}


func _interpret_move_line(s: String, human_camp: GameConstants.Camp) -> Dictionary:
	var camp_name: String = ""
	var rest: String = s
	for c: GameConstants.Camp in [GameConstants.Camp.GREEN, GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		var label: String = GameConstants.camp_to_string(c)
		if s.begins_with(label):
			camp_name = label
			rest = s.trim_prefix(label).strip_edges()
			break
	var kind: LineKind = LineKind.ENEMY
	if camp_name != "" and _camp_from_label(camp_name) == human_camp:
		kind = LineKind.PLAYER
	if "→" in rest:
		var parts: PackedStringArray = rest.split("→", false, 1)
		if parts.size() >= 2:
			return {
				"kind": kind,
				"text": "%s avance : %s → %s" % [camp_name if camp_name != "" else "Unité", parts[0].strip_edges(), parts[1].strip_edges()],
			}
	return {"kind": kind, "text": s}


func _humanize_combat(s: String, human_camp: GameConstants.Camp) -> String:
	if "en réserve" in s:
		return s.replace("Combat ", "Conflit ").replace(" gagne", " l'emporte").replace("en réserve.", "envoyées en réserve.")
	if human_camp != GameConstants.Camp.GREEN:
		pass
	return s.replace("Combat ", "Bataille : ").replace(" gagne", " remporte la zone")


func _humanize_harvest(s: String, human_camp: GameConstants.Camp) -> String:
	var camp_label: String = GameConstants.camp_to_string(human_camp)
	if s.begins_with(camp_label) or s.contains(camp_label):
		return s.replace("+1 Force", "vous gagnez +1 Force").replace("île", "présence sur l'île")
	return s


func _camp_from_label(label: String) -> GameConstants.Camp:
	match label:
		"Vert": return GameConstants.Camp.GREEN
		"Bleu": return GameConstants.Camp.BLUE
		"Rouge": return GameConstants.Camp.RED
		"Jaune": return GameConstants.Camp.YELLOW
		_: return GameConstants.Camp.GREEN
