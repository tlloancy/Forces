class_name GameOrder
extends RefCounted

enum Kind { MOVE, EXCHANGE, DEPLOY_FROM_RESERVE, HBOMB }

var kind: Kind = Kind.MOVE
var camp: GameConstants.Camp
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
		Kind.HBOMB:
			return "%s: bombe H → %s" % [GameConstants.camp_to_string(camp), to_sector]
		_:
			return "Ordre inconnu"
