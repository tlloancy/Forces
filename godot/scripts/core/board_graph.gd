extends Node
## Graphes de déplacement — Dep_terre.js / Dep_mer.js / Dep_air.js (Unity).

var _land: Dictionary = {}
var _sea: Dictionary = {}
var _air: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_load()


func _load() -> void:
	if _loaded:
		return
	_land = _read_json("res://data/land_adjacency.json", "land")
	_sea = _read_json("res://data/sea_adjacency.json", "sea")
	_air = _read_json("res://data/air_adjacency.json", "air")
	_loaded = true


func _read_json(path: String, label: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing %s — run tools/parse_dep_adjacency.py %s" % [path, label])
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid %s adjacency JSON" % label)
		return {}
	return parsed as Dictionary


func land_sector_count() -> int:
	_load()
	return _land.size()


func sea_sector_count() -> int:
	_load()
	return _sea.size()


func air_sector_count() -> int:
	_load()
	return _air.size()


func has_land_sector(sector_id: String) -> bool:
	_load()
	return _land.has(sector_id)


func has_sea_sector(sector_id: String) -> bool:
	_load()
	return _sea.has(sector_id)


func has_air_sector(sector_id: String) -> bool:
	_load()
	return _air.has(sector_id)


func has_sector(sector_id: String) -> bool:
	return has_land_sector(sector_id) or has_sea_sector(sector_id) or has_air_sector(sector_id)


func land_neighbors_move1(from_sector: String) -> PackedStringArray:
	_load()
	var entry: Variant = _land.get(from_sector, null)
	if entry == null or typeof(entry) != TYPE_DICTIONARY:
		return PackedStringArray()
	var data: Dictionary = entry as Dictionary
	return _string_array(data.get("move_1", [] as Array))


func land_distance(from_sector: String, to_sector: String) -> int:
	if from_sector == to_sector:
		return 0
	if not has_land_sector(from_sector) or not has_land_sector(to_sector):
		return 999
	var queue: Array[String] = [from_sector]
	var dist: Dictionary = {from_sector: 0}
	var head: int = 0
	while head < queue.size():
		var current: String = queue[head]
		head += 1
		var current_dist: int = int(dist[current])
		for neighbor: String in land_neighbors_move1(current):
			if neighbor == to_sector:
				return current_dist + 1
			if not dist.has(neighbor):
				dist[neighbor] = current_dist + 1
				queue.append(neighbor)
	return 999


func land_destinations(from_sector: String, max_move: int) -> PackedStringArray:
	_load()
	var entry: Variant = _land.get(from_sector, null)
	if entry == null or typeof(entry) != TYPE_DICTIONARY:
		return PackedStringArray()
	var data: Dictionary = entry as Dictionary
	var result: Array[String] = []
	for n in data.get("move_1", [] as Array):
		if n is String and n not in result:
			result.append(n)
	if max_move >= 3:
		for n in data.get("move_3", [] as Array):
			if n is String and n not in result:
				result.append(n)
	return PackedStringArray(result)


func sea_destinations(from_sector: String) -> PackedStringArray:
	_load()
	if not _sea.has(from_sector):
		return PackedStringArray()
	return _string_array(_sea[from_sector])


func air_destinations(from_sector: String) -> PackedStringArray:
	_load()
	if not _air.has(from_sector):
		return PackedStringArray()
	return _string_array(_air[from_sector])


func piece_destinations(piece_type: GameConstants.PieceType, from_sector: String, max_move: int) -> PackedStringArray:
	match GameConstants.piece_movement_domain(piece_type):
		GameConstants.MovementDomain.LAND:
			return land_destinations(from_sector, max_move)
		GameConstants.MovementDomain.SEA:
			return sea_destinations(from_sector)
		GameConstants.MovementDomain.AIR:
			return air_destinations(from_sector)
		_:
			return PackedStringArray()


func format_destinations(piece_type: GameConstants.PieceType, from_sector: String, max_move: int) -> String:
	var dests := piece_destinations(piece_type, from_sector, max_move)
	if dests.is_empty():
		return "(aucune destination)"
	return ", ".join(dests)


func _string_array(raw: Variant) -> PackedStringArray:
	var result: Array[String] = []
	if typeof(raw) != TYPE_ARRAY:
		return PackedStringArray()
	for n in raw:
		if n is String:
			result.append(n)
	return PackedStringArray(result)
