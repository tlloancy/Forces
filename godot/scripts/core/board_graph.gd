extends Node
## Graphe terrestre extrait de Dep_terre.js (Unity).

var _land: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_load()


func _load() -> void:
	if _loaded:
		return
	var path := "res://data/land_adjacency.json"
	if not FileAccess.file_exists(path):
		push_error("Missing %s — run tools/parse_dep_terre.py" % path)
		return
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid land adjacency JSON")
		return
	_land = parsed as Dictionary
	_loaded = true


func land_sector_count() -> int:
	_load()
	return _land.size()


func has_sector(sector_id: String) -> bool:
	_load()
	return _land.has(sector_id)


func land_neighbors_move1(from_sector: String) -> PackedStringArray:
	_load()
	var entry: Variant = _land.get(from_sector, null)
	if entry == null or typeof(entry) != TYPE_DICTIONARY:
		return PackedStringArray()
	var data: Dictionary = entry as Dictionary
	var result: Array[String] = []
	for n in data.get("move_1", [] as Array):
		if n is String:
			result.append(n)
	return PackedStringArray(result)


func land_distance(from_sector: String, to_sector: String) -> int:
	if from_sector == to_sector:
		return 0
	if not has_sector(from_sector) or not has_sector(to_sector):
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


## Destinations en un ordre de déplacement terrestre (Dep_terre nbmove).
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


func format_destinations(from_sector: String, max_move: int) -> String:
	var dests := land_destinations(from_sector, max_move)
	if dests.is_empty():
		return "(aucune — case mer / non terrestre)"
	return ", ".join(dests)
