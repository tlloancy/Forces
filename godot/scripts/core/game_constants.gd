extends Node
## Constantes globales — valeurs alignées sur ScriptIA_* / allInfo (Unity).

enum Camp { GREEN, BLUE, RED, YELLOW }

enum PieceType {
	SOLDIER,
	RAIDER,
	HUNTER,
	CRUISER,
	COMMANDO,
	BOMBER,
	FIGHTER,
	DESTROYER,
	HBOMB,
}

enum SectorKind { HQ, LAND, SEA, SPECIAL }

enum GamePhase { MENU, PLANNING, RESOLUTION, GAME_OVER }

const MAX_ORDERS_PER_ROUND: int = 5

const PIECE_STATS: Dictionary = {
	PieceType.SOLDIER: { "force": 2, "max_move": 2, "power_cost": 2 },
	PieceType.RAIDER: { "force": 3, "max_move": 3, "power_cost": 3 },
	PieceType.HUNTER: { "force": 5, "max_move": 5, "power_cost": 5 },
	PieceType.CRUISER: { "force": 10, "max_move": 2, "power_cost": 10 },
	PieceType.COMMANDO: { "force": 20, "max_move": 2, "power_cost": 20 },
	PieceType.BOMBER: { "force": 30, "max_move": 7, "power_cost": 30 },
	PieceType.FIGHTER: { "force": 25, "max_move": 7, "power_cost": 25 },
	PieceType.DESTROYER: { "force": 50, "max_move": 3, "power_cost": 50 },
	PieceType.HBOMB: { "force": 0, "max_move": 0, "power_cost": 0 },
}

const CAMP_COLORS: Dictionary = {
	Camp.GREEN: Color(0.24, 0.62, 0.34),
	Camp.BLUE: Color(0.25, 0.45, 0.85),
	Camp.RED: Color(0.82, 0.22, 0.22),
	Camp.YELLOW: Color(0.92, 0.78, 0.18),
}

const CAMP_NAMES: PackedStringArray = ["Vert", "Bleu", "Rouge", "Jaune"]


static func camp_to_string(camp: Camp) -> String:
	return CAMP_NAMES[camp]


static func piece_type_label(piece: PieceType) -> String:
	match piece:
		PieceType.SOLDIER: return "Soldat"
		PieceType.RAIDER: return "Tank"
		PieceType.HUNTER: return "Chasseur"
		PieceType.CRUISER: return "Croiseur"
		PieceType.COMMANDO: return "Régiment"
		PieceType.BOMBER: return "Bombardier"
		PieceType.FIGHTER: return "Chasseur lourd"
		PieceType.DESTROYER: return "Destroyer"
		PieceType.HBOMB: return "Bombe H"
		_: return "?"
