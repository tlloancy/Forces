class_name GameOrder
extends RefCounted

enum Kind { MOVE, BUY, EXCHANGE, DEPLOY_FROM_RESERVE, HBOMB_PLACE, HBOMB_STRIKE }

var kind: Kind = Kind.MOVE
var camp: GameConstants.Camp
var piece_id: int = -1
var piece_type: GameConstants.PieceType
var from_sector: String = ""
var to_sector: String = ""
var exchange_result: GameConstants.PieceType = GameConstants.PieceType.SOLDIER


func _init(p_kind: Kind = Kind.MOVE, p_camp: GameConstants.Camp = GameConstants.Camp.GREEN) -> void:
	kind = p_kind
	camp = p_camp


func describe() -> String:
	match kind:
		Kind.MOVE:
			return "%s: %s %s → %s" % [
				GameConstants.camp_to_string(camp),
				GameConstants.piece_type_label(piece_type),
				from_sector,
				to_sector,
			]
		Kind.EXCHANGE:
			return "%s: exchange → %s" % [
				GameConstants.camp_to_string(camp),
				GameConstants.piece_type_label(exchange_result),
			]
		Kind.DEPLOY_FROM_RESERVE:
			return "%s: reserve → %s (%s)" % [
				GameConstants.camp_to_string(camp),
				to_sector,
				GameConstants.piece_type_label(piece_type),
			]
		Kind.BUY:
			return "%s: buy %s (reserve)" % [
				GameConstants.camp_to_string(camp),
				GameConstants.piece_type_label(piece_type),
			]
		Kind.HBOMB_PLACE:
			return "%s: place H-bomb on %s" % [GameConstants.camp_to_string(camp), to_sector]
		Kind.HBOMB_STRIKE:
			return "%s: H-bomb strikes %s" % [GameConstants.camp_to_string(camp), to_sector]
		_:
			return "Unknown order"


## Format pad Android : « O : HQ > CE ».
func pad_label() -> String:
	match kind:
		Kind.MOVE:
			return "O : %s > %s" % [
				BoardCatalog.sector_short_label(from_sector),
				BoardCatalog.sector_short_label(to_sector),
			]
		Kind.DEPLOY_FROM_RESERVE:
			return "O : res > %s" % BoardCatalog.sector_short_label(to_sector)
		Kind.BUY:
			return "O : buy %s" % GameConstants.piece_type_label(piece_type)
		Kind.EXCHANGE:
			return "O : merge %s" % GameConstants.piece_type_label(exchange_result)
		Kind.HBOMB_PLACE:
			return "O : fusion H → %s" % BoardCatalog.sector_short_label(to_sector)
		Kind.HBOMB_STRIKE:
			return "O : H → %s" % BoardCatalog.sector_short_label(to_sector)
		_:
			return "O : ?"


## Ligne terminal — symboles uniquement (BBCode camp + formes).
func feed_bbcode(slot: int, _max_orders: int) -> String:
	return "[color=#588860]O%d[/color] %s" % [slot, bbcode_label()]


## @deprecated Utiliser feed_bbcode().
func feed_line(_human_camp: GameConstants.Camp, slot: int, max_orders: int) -> String:
	return feed_bbcode(slot, max_orders)


## Format BBCode : icônes pièce + couleur camp, sans texte.
func bbcode_label() -> String:
	var cc: String = _camp_hex(camp)
	var ps: String = _piece_sym(piece_type)
	match kind:
		Kind.MOVE:
			return "[color=%s]%s[/color] %s→%s" % [
				cc, ps,
				_sector_bbcode(from_sector),
				_sector_bbcode(to_sector),
			]
		Kind.DEPLOY_FROM_RESERVE:
			return "[color=%s]%s[/color] ↓→%s" % [cc, ps, _sector_bbcode(to_sector)]
		Kind.BUY:
			var cost: int = int(GameConstants.PIECE_STATS.get(piece_type, {}).get("power_cost", 0))
			return "[color=%s]+%s[/color] ⚡%d" % [cc, ps, cost]
		Kind.EXCHANGE:
			return "[color=%s]%s→%s[/color]" % [cc, ps, _piece_sym(exchange_result)]
		Kind.HBOMB_PLACE:
			return "[color=%s]H→%s[/color]" % [cc, _sector_bbcode(to_sector)]
		Kind.HBOMB_STRIKE:
			return "[color=%s]H☠%s[/color]" % [cc, _sector_bbcode(to_sector)]
		_:
			return "?"


## Détail sidebar — coordonnées colorées par camp (sans icône pièce).
func detail_bbcode() -> String:
	const ARROW := "[color=#8899aa] → [/color]"
	match kind:
		Kind.MOVE:
			return "%s%s%s" % [_sector_bbcode(from_sector), ARROW, _sector_bbcode(to_sector)]
		Kind.DEPLOY_FROM_RESERVE:
			return "[color=#8899aa]↓ [/color]%s" % _sector_bbcode(to_sector)
		Kind.BUY:
			return "[color=#8899aa]+ reserve[/color]"
		Kind.EXCHANGE:
			return "[color=%s]⇄ %s[/color]" % [_camp_hex(camp), _piece_sym(exchange_result)]
		Kind.HBOMB_PLACE:
			return "[color=%s]H → %s[/color]" % [_camp_hex(camp), _sector_bbcode(to_sector)]
		Kind.HBOMB_STRIKE:
			return "[color=%s]H ☠ %s[/color]" % [_camp_hex(camp), _sector_bbcode(to_sector)]
		_:
			return "?"


static func _camp_hex(c: GameConstants.Camp) -> String:
	match c:
		GameConstants.Camp.GREEN:  return "#3d9e57"
		GameConstants.Camp.BLUE:   return "#4073d9"
		GameConstants.Camp.RED:    return "#d13838"
		GameConstants.Camp.YELLOW: return "#ebc72e"
		_: return "#aaaaaa"


static func _piece_sym(pt: GameConstants.PieceType) -> String:
	match pt:
		GameConstants.PieceType.SOLDIER:   return "○"
		GameConstants.PieceType.RAIDER:    return "□"
		GameConstants.PieceType.HUNTER:    return "△"
		GameConstants.PieceType.CRUISER:   return "◇"
		GameConstants.PieceType.COMMANDO:  return "●"
		GameConstants.PieceType.BOMBER:    return "■"
		GameConstants.PieceType.FIGHTER:   return "▲"
		GameConstants.PieceType.DESTROYER: return "♦"
		GameConstants.PieceType.HBOMB:     return "H"
		_: return "?"


static func _sector_bbcode(sector_id: String) -> String:
	var sector_camp: GameConstants.Camp = BoardCatalog.camp_for_sector(sector_id)
	var cc: String = _camp_hex(sector_camp)
	var short: String = BoardCatalog.sector_short_label(sector_id)
	if sector_id.begins_with("HQ_"):
		return "[color=%s]⚑[/color]" % cc
	if BoardCatalog.is_neutral(sector_id):
		return "[color=#8899bb]%s[/color]" % short
	return "[color=%s]%s[/color]" % [cc, short]


# --- Lignes tactiques (symboles, pas de prose) ---

static func feed_phase_header(sym: String) -> String:
	return "[color=#888aa0]▸ %s[/color]" % sym


static func feed_slot_dots(used: int, max_slots: int) -> String:
	var s := ""
	for i in max_slots:
		s += "●" if i < used else "○"
	return s


static func feed_round_marker(round_n: int) -> String:
	return "◎ %d" % round_n


static func feed_resolution_marker(round_n: int) -> String:
	return "[color=#6ab0ff]▸ ◎ %d[/color]" % round_n


static func feed_planning_hint(max_orders: int) -> String:
	return feed_slot_dots(0, max_orders)


static func feed_boot_line() -> String:
	return "⬚→◈→▸"


static func feed_combat_win(sector_id: String, winner: GameConstants.Camp, f_win: int, f_lose: int) -> String:
	return "⚔ %s [color=%s]▲[/color] %d‣%d" % [
		_sector_bbcode(sector_id),
		_camp_hex(winner),
		f_win,
		f_lose,
	]


static func feed_combat_tie(sector_id: String, f_a: int, f_b: int) -> String:
	return "⚔ %s ═ %d‣%d ↩" % [_sector_bbcode(sector_id), f_a, f_b]


static func feed_hbomb_strike(attacker: GameConstants.Camp, target_sector: String, removed: int) -> String:
	return "[color=%s]H☠[/color]%s ×%d" % [
		_camp_hex(attacker),
		_sector_bbcode(target_sector),
		removed,
	]


static func feed_harvest(occupier: GameConstants.Camp, enemy_island: GameConstants.Camp) -> String:
	return "⚡ [color=%s]●[/color]→[color=%s]▲[/color]" % [_camp_hex(occupier), _camp_hex(enemy_island)]


static func feed_flag_eliminated(eliminated_camp: GameConstants.Camp) -> String:
	return "⚑ [color=%s]●[/color]✕" % _camp_hex(eliminated_camp)


static func feed_victory(winner_camp: GameConstants.Camp) -> String:
	return "★ [color=%s]●[/color]" % _camp_hex(winner_camp)


static func feed_timeout() -> String:
	return "[color=#ff6666]⏱ ✕[/color]"


static func feed_ai_header(ai_camp: GameConstants.Camp, diff_letter: String) -> String:
	var cc: String = _camp_hex(ai_camp)
	return "[color=%s]◈ %s[/color]" % [cc, diff_letter]


static func feed_no_orders() -> String:
	return "· —"

