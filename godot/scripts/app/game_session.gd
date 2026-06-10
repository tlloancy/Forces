extends Node
## Configuration de partie persistée entre menu et bataille (remplace le flux Unity menu → Create_Menu → Battleground).

enum SlotKind { HUMAN, AI, NETWORK }
enum Difficulty { EASY, NORMAL, HARD }

const CONFIGURABLE_CAMPS: Array[GameConstants.Camp] = [
	GameConstants.Camp.BLUE,
	GameConstants.Camp.RED,
	GameConstants.Camp.YELLOW,
]

## Délai avant abandon auto après déconnexion (reconnexion WiFi / crash).
const DISCONNECT_GRACE_SEC := 45
## Planification simultanée online — 60 s partagés (5 ordres max, rythme fluide).
const NETWORK_PLANNING_SEC := 60

var human_camp: GameConstants.Camp = GameConstants.Camp.GREEN
var slots: Dictionary = {}
var music_volume: float = 0.8
var sfx_volume: float = 0.8

var network_active: bool = false
var network_is_host: bool = false
var network_host_peer_id: int = 1
var network_guest_peer_id: int = 0
var network_player_count: int = 2
var network_peer_camps: Dictionary = {}
var network_room_code: String = ""
var network_match_in_progress: bool = false
## Camp (int) -> unix time when disconnect was detected.
var network_disconnected_camps: Dictionary = {}
var _reconnect_checkpoint: Dictionary = {}


func _ready() -> void:
	reset_to_solo_defaults()


func reset_to_solo_defaults() -> void:
	clear_network()
	human_camp = GameConstants.Camp.GREEN
	slots = {
		GameConstants.Camp.BLUE: _slot(SlotKind.AI, Difficulty.NORMAL),
		GameConstants.Camp.RED: _slot(SlotKind.AI, Difficulty.NORMAL),
		GameConstants.Camp.YELLOW: _slot(SlotKind.AI, Difficulty.NORMAL),
	}


func clear_network() -> void:
	network_active = false
	network_is_host = false
	network_host_peer_id = 1
	network_guest_peer_id = 0
	network_player_count = 2
	network_peer_camps.clear()
	network_room_code = ""
	network_match_in_progress = false
	network_disconnected_camps.clear()


func reset_for_network_host(player_count: int = 2) -> void:
	clear_network()
	network_active = true
	network_is_host = true
	network_host_peer_id = 1
	network_player_count = clampi(player_count, 2, 4)
	human_camp = GameConstants.Camp.GREEN
	network_peer_camps = {1: GameConstants.Camp.GREEN}
	slots = _slots_for_network_player_count(network_player_count)


func reset_for_network_client() -> void:
	clear_network()
	network_active = true
	network_is_host = false
	network_host_peer_id = 1
	human_camp = GameConstants.Camp.BLUE
	slots = _slots_for_network_player_count(2)


func _slots_for_network_player_count(player_count: int) -> Dictionary:
	var result: Dictionary = {}
	var online_slots: int = clampi(player_count, 2, 4) - 1
	for i: int in CONFIGURABLE_CAMPS.size():
		var camp: GameConstants.Camp = CONFIGURABLE_CAMPS[i]
		var kind: SlotKind = SlotKind.NETWORK if i < online_slots else SlotKind.AI
		result[camp] = _slot(kind, Difficulty.NORMAL)
	return result


func register_network_peer(peer_id: int) -> void:
	if network_peer_camps.has(peer_id):
		return
	for camp: GameConstants.Camp in CONFIGURABLE_CAMPS:
		if slot_kind(camp) != SlotKind.NETWORK:
			continue
		var taken: bool = false
		for assigned_camp: Variant in network_peer_camps.values():
			if int(assigned_camp) == int(camp):
				taken = true
				break
		if not taken:
			network_peer_camps[peer_id] = camp
			network_guest_peer_id = peer_id
			return


func network_remote_peers_connected() -> int:
	var n: int = 0
	for peer_id: Variant in network_peer_camps.keys():
		if int(peer_id) != network_host_peer_id:
			n += 1
	return n


func network_remotes_needed() -> int:
	return network_player_count - 1


func build_network_match_config() -> Dictionary:
	var peer_camps: Dictionary = {}
	for peer_id: Variant in network_peer_camps.keys():
		peer_camps[str(peer_id)] = int(network_peer_camps[peer_id])
	return {
		"player_count": network_player_count,
		"peer_camps": peer_camps,
	}


func apply_network_match_config(config: Dictionary, my_peer_id: int) -> void:
	network_player_count = int(config.get("player_count", 2))
	network_peer_camps.clear()
	var raw: Dictionary = config.get("peer_camps", {})
	for key: Variant in raw.keys():
		network_peer_camps[int(key)] = int(raw[key]) as GameConstants.Camp
	if network_peer_camps.has(my_peer_id):
		human_camp = network_peer_camps[my_peer_id] as GameConstants.Camp
	slots = _slots_for_network_player_count(network_player_count)


func camp_for_peer(peer_id: int) -> GameConstants.Camp:
	return network_peer_camps.get(peer_id, GameConstants.Camp.GREEN) as GameConstants.Camp


func mark_network_match_started(room_code: String) -> void:
	network_match_in_progress = true
	network_room_code = room_code


func mark_camp_disconnected(camp: GameConstants.Camp) -> void:
	network_disconnected_camps[int(camp)] = _unix_time()


func is_camp_disconnected(camp: GameConstants.Camp) -> bool:
	return network_disconnected_camps.has(int(camp))


func disconnected_camp_deadline(camp: GameConstants.Camp) -> int:
	var started: int = int(network_disconnected_camps.get(int(camp), 0))
	if started <= 0:
		return 0
	return started + DISCONNECT_GRACE_SEC


func assign_peer_to_camp(peer_id: int, camp: GameConstants.Camp) -> void:
	for pid: Variant in network_peer_camps.keys():
		if int(network_peer_camps[pid]) == int(camp):
			network_peer_camps.erase(pid)
	network_peer_camps[peer_id] = camp
	network_disconnected_camps.erase(int(camp))


func network_online_camps() -> Array[GameConstants.Camp]:
	var result: Array[GameConstants.Camp] = []
	for camp: GameConstants.Camp in [GameConstants.Camp.GREEN] + CONFIGURABLE_CAMPS:
		if camp == GameConstants.Camp.GREEN or slot_kind(camp) == SlotKind.NETWORK:
			result.append(camp)
	return result


func save_reconnect_checkpoint() -> void:
	if network_room_code.is_empty():
		return
	_reconnect_checkpoint = {
		"room_code": network_room_code,
		"camp": int(human_camp),
		"player_count": network_player_count,
		"saved_at": _unix_time(),
	}


func has_reconnect_checkpoint() -> bool:
	if _reconnect_checkpoint.is_empty():
		return false
	var saved_at: int = int(_reconnect_checkpoint.get("saved_at", 0))
	return _unix_time() - saved_at <= DISCONNECT_GRACE_SEC


func peek_reconnect_checkpoint() -> Dictionary:
	return _reconnect_checkpoint.duplicate()


func take_reconnect_checkpoint() -> Dictionary:
	var cp: Dictionary = _reconnect_checkpoint.duplicate()
	_reconnect_checkpoint.clear()
	return cp


func clear_reconnect_checkpoint() -> void:
	_reconnect_checkpoint.clear()


func is_network_match() -> bool:
	return network_active


func local_player_camp() -> GameConstants.Camp:
	return human_camp


func controls_camp(camp: GameConstants.Camp) -> bool:
	return camp == human_camp


func _slot(kind: SlotKind, difficulty: Difficulty) -> Dictionary:
	return {"kind": kind, "difficulty": difficulty}


func set_slot(camp: GameConstants.Camp, kind: SlotKind, difficulty: Difficulty = Difficulty.NORMAL) -> void:
	if not slots.has(camp):
		slots[camp] = _slot(kind, difficulty)
	else:
		slots[camp]["kind"] = kind
		slots[camp]["difficulty"] = difficulty


func slot_kind(camp: GameConstants.Camp) -> SlotKind:
	return int(slots.get(camp, _slot(SlotKind.AI, Difficulty.NORMAL))["kind"]) as SlotKind


func slot_difficulty(camp: GameConstants.Camp) -> Difficulty:
	return int(slots.get(camp, _slot(SlotKind.AI, Difficulty.NORMAL))["difficulty"]) as Difficulty


func is_ai(camp: GameConstants.Camp) -> bool:
	if camp == human_camp:
		return false
	if network_active and slot_kind(camp) == SlotKind.NETWORK:
		return false
	return slot_kind(camp) == SlotKind.AI


func human_player_count() -> int:
	var n: int = 1
	for camp: GameConstants.Camp in CONFIGURABLE_CAMPS:
		if slot_kind(camp) == SlotKind.HUMAN:
			n += 1
	return n


func difficulty_label(d: Difficulty) -> String:
	match d:
		Difficulty.EASY: return "Easy"
		Difficulty.NORMAL: return "Normal"
		Difficulty.HARD: return "Hard"
		_: return "?"


func slot_summary(camp: GameConstants.Camp) -> String:
	if camp == human_camp:
		return "Player (you)"
	if slot_kind(camp) == SlotKind.HUMAN:
		return "Player (local)"
	if slot_kind(camp) == SlotKind.NETWORK:
		if camp == human_camp:
			return "Player (you, online)"
		return "Player (online)"
	return "AI (%s)" % difficulty_label(slot_difficulty(camp))


func setup_summary_lines() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("%s : %s" % [GameConstants.camp_to_string(human_camp), slot_summary(human_camp)])
	for camp: GameConstants.Camp in CONFIGURABLE_CAMPS:
		lines.append("%s : %s" % [GameConstants.camp_to_string(camp), slot_summary(camp)])
	return lines


var _saved_battle: Dictionary = {}


func has_saved_battle() -> bool:
	return not _saved_battle.is_empty()


func save_battle(snapshot: Dictionary) -> void:
	_saved_battle = snapshot.duplicate(true)


func take_saved_battle() -> Dictionary:
	var snap: Dictionary = _saved_battle.duplicate(true)
	_saved_battle.clear()
	return snap


func clear_saved_battle() -> void:
	_saved_battle.clear()


func _unix_time() -> int:
	return int(Time.get_unix_time_from_system())
