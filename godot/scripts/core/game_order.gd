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
			return "%s: échange → %s" % [
				GameConstants.camp_to_string(camp),
				GameConstants.piece_type_label(exchange_result),
			]
		Kind.DEPLOY_FROM_RESERVE:
			return "%s: réserve → %s (%s)" % [
				GameConstants.camp_to_string(camp),
				to_sector,
				GameConstants.piece_type_label(piece_type),
			]
		Kind.BUY:
			return "%s: achat %s (réserve)" % [
				GameConstants.camp_to_string(camp),
				GameConstants.piece_type_label(piece_type),
			]
		Kind.HBOMB_PLACE:
			return "%s: pose bombe H sur %s" % [GameConstants.camp_to_string(camp), to_sector]
		Kind.HBOMB_STRIKE:
			return "%s: bombe H frappe %s" % [GameConstants.camp_to_string(camp), to_sector]
		_:
			return "Ordre inconnu"


## Format pad Android : « O : HQ > CE ».
func pad_label() -> String:
	match kind:
		Kind.MOVE:
			return "O : %s > %s" % [
				BoardCatalog.sector_short_label(from_sector),
				BoardCatalog.sector_short_label(to_sector),
			]
		Kind.DEPLOY_FROM_RESERVE:
			return "O : réserve > %s" % BoardCatalog.sector_short_label(to_sector)
		Kind.BUY:
			return "O : achat %s" % GameConstants.piece_type_label(piece_type)
		Kind.EXCHANGE:
			return "O : fusion %s" % GameConstants.piece_type_label(exchange_result)
		Kind.HBOMB_PLACE:
			return "O : fusion H → %s" % BoardCatalog.sector_short_label(to_sector)
		Kind.HBOMB_STRIKE:
			return "O : H → %s" % BoardCatalog.sector_short_label(to_sector)
		_:
			return "O : ?"


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
			return "[color=%s]+%s[/color]" % [cc, ps]
		Kind.EXCHANGE:
			return "[color=%s]%s→%s[/color]" % [cc, ps, _piece_sym(exchange_result)]
		Kind.HBOMB_PLACE:
			return "[color=%s]H→%s[/color]" % [cc, _sector_bbcode(to_sector)]
		Kind.HBOMB_STRIKE:
			return "[color=%s]H☠%s[/color]" % [cc, _sector_bbcode(to_sector)]
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
	var camp: GameConstants.Camp = BoardCatalog.camp_for_sector(sector_id)
	var cc: String = _camp_hex(camp)
	var short: String = BoardCatalog.sector_short_label(sector_id)
	if sector_id.begins_with("HQ_"):
		return "[color=%s]⚑[/color]" % cc
	if BoardCatalog.is_neutral(sector_id):
		return "[color=#8899bb]%s[/color]" % short
	return "[color=%s]%s[/color]" % [cc, short]

