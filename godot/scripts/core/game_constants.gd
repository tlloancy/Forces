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

enum MovementDomain { LAND, SEA, AIR, NONE }

const MAX_ORDERS_PER_ROUND: int = 5
const PLANNING_TIMER_SECONDS: int = 3600
const STARTING_POWER: int = 12
const POWER_PER_ROUND: int = 3
const HBOMB_FUSION_FORCE: int = 100

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


## Paramètre `nbmove` passé à `Dep_terre.deplacement_terrestre` (Unity infoButtons).
static func unity_land_nbmove(piece_type: PieceType) -> int:
	match piece_type:
		PieceType.SOLDIER, PieceType.COMMANDO:
			return 2
		PieceType.RAIDER, PieceType.BOMBER:
			return 3
		_:
			return 1


static func piece_movement_domain(piece: PieceType) -> MovementDomain:
	match piece:
		PieceType.SOLDIER, PieceType.RAIDER, PieceType.COMMANDO:
			return MovementDomain.LAND
		PieceType.CRUISER, PieceType.DESTROYER:
			return MovementDomain.SEA
		PieceType.HUNTER, PieceType.BOMBER, PieceType.FIGHTER:
			return MovementDomain.AIR
		_:
			return MovementDomain.NONE


static func movement_domain_label(domain: MovementDomain) -> String:
	match domain:
		MovementDomain.LAND:
			return "terre"
		MovementDomain.SEA:
			return "mer"
		MovementDomain.AIR:
			return "air"
		_:
			return "—"


static func is_basic_buy(piece: PieceType) -> bool:
	return piece in [PieceType.SOLDIER, PieceType.RAIDER, PieceType.HUNTER, PieceType.CRUISER]


static func reserve_force_value(piece_type: PieceType) -> int:
	match piece_type:
		PieceType.SOLDIER:
			return 2
		PieceType.RAIDER:
			return 3
		PieceType.HUNTER:
			return 5
		PieceType.CRUISER:
			return 10
		PieceType.COMMANDO:
			return 20
		PieceType.BOMBER:
			return 30
		PieceType.FIGHTER:
			return 25
		PieceType.DESTROYER:
			return 50
		_:
			return 0


static func exchange_recipe(result: PieceType) -> Dictionary:
	match result:
		PieceType.COMMANDO:
			return {"from": PieceType.SOLDIER, "count": 3}
		PieceType.BOMBER:
			return {"from": PieceType.RAIDER, "count": 3}
		PieceType.FIGHTER:
			return {"from": PieceType.HUNTER, "count": 3}
		PieceType.DESTROYER:
			return {"from": PieceType.CRUISER, "count": 3}
		_:
			return {}
