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

