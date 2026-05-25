class_name SeaCorridorTest
extends RefCounted
## Vérifie le placement des couloirs mer vs captures Unity (Screenshot 216).


static func run_all() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var layout: Dictionary = _load_layout()
	if layout.is_empty():
		return ["sector_layout.json illisible"]
	failures.append_array(_test_positions(layout))
	failures.append_array(_test_lateral_links())
	failures.append_array(_test_graph_reachability())
	failures.append_array(_test_corridor_sprite_sizes())
	return failures


static func _test_corridor_sprite_sizes() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	for sid: String in ["Space_5", "Space_8", "Space_6", "Space_1"]:
		var sz := BoardAtlas.tile_design_size(sid)
		if minf(sz.x, sz.y) < 10.0:
			failures.append("%s trop petit pour être visible (%.1f×%.1f)" % [sid, sz.x, sz.y])
	var tex := BoardAtlas.tile_texture("Space_5")
	if tex == null or tex.atlas == null:
		failures.append("texture Space_5 / Sp5 introuvable")
	return failures


static func _load_layout() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/sector_layout.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = parsed as Dictionary
	d.erase("_meta")
	return d


static func _pos(layout: Dictionary, sid: String) -> Vector2:
	var e: Dictionary = layout[sid] as Dictionary
	return Vector2(float(e["x"]), float(e["y"]))


static func _dist(a: Vector2, b: Vector2) -> float:
	return a.distance_to(b)


static func _test_positions(layout: Dictionary) -> PackedStringArray:
	## Layout Unity capture 216 : Moons sur bordures extérieures (pas autour du Sun).
	var failures: PackedStringArray = PackedStringArray()
	var required: PackedStringArray = PackedStringArray([
		"Space_5", "Space_8", "Space_12", "Space_10", "Space_6", "Space_11",
		"Moon_W", "Moon_E", "Moon_N", "Moon_S", "Sun",
		"HQ_Green", "HQ_Blue", "HQ_Red", "HQ_Yellow",
	])
	for sid: String in required:
		if not layout.has(sid):
			failures.append("secteur manquant: %s" % sid)
	var sun := _pos(layout, "Sun")
	var mw := _pos(layout, "Moon_W")
	var me := _pos(layout, "Moon_E")
	var mn := _pos(layout, "Moon_N")
	var ms := _pos(layout, "Moon_S")
	# Sun au centre.
	if absf(sun.x - 140.0) > 4.0 or absf(sun.y - 140.0) > 4.0:
		failures.append("Sun pas au centre (%.1f, %.1f)" % [sun.x, sun.y])
	# Moons sur bordures extérieures.
	if mw.x > 35.0:
		failures.append("Moon_W pas sur bordure gauche (x=%.1f)" % mw.x)
	if me.x < 245.0:
		failures.append("Moon_E pas sur bordure droite (x=%.1f)" % me.x)
	if mn.y > 35.0:
		failures.append("Moon_N pas sur bordure haut (y=%.1f)" % mn.y)
	if ms.y < 245.0:
		failures.append("Moon_S pas sur bordure bas (y=%.1f)" % ms.y)
	# Space_5/12 sur bordure gauche autour de Moon_W.
	var s5 := _pos(layout, "Space_5")
	var s12 := _pos(layout, "Space_12")
	if s5.x > 35.0 or s12.x > 35.0:
		failures.append("Space_5/12 doivent être sur bordure gauche")
	if s5.y > mw.y or s12.y < mw.y:
		failures.append("Space_5 doit être au-dessus de Moon_W, Space_12 en-dessous")
	# Space_8/10 sur bordure droite autour de Moon_E.
	var s8 := _pos(layout, "Space_8")
	var s10 := _pos(layout, "Space_10")
	if s8.x < 245.0 or s10.x < 245.0:
		failures.append("Space_8/10 doivent être sur bordure droite")
	# Space_1–4 doivent rester proches du Sun.
	for i in [1, 2, 3, 4]:
		var sp := _pos(layout, "Space_%d" % i)
		if sp.distance_to(sun) > 30.0:
			failures.append("Space_%d trop loin du Sun (%.1f px)" % [i, sp.distance_to(sun)])
	return failures


static func _test_lateral_links() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := GameState.new()
	state.reset_match()
	var green_cruiser: PieceInstance = _find_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.CRUISER)
	var blue_cruiser: PieceInstance = _find_piece(state, GameConstants.Camp.BLUE, GameConstants.PieceType.CRUISER)
	if green_cruiser == null or blue_cruiser == null:
		return ["pas de croiseur pour test mer"]
	var g_sea: PackedStringArray = state.destinations_for(green_cruiser)
	if "Space_5" not in g_sea:
		failures.append("vert: pas de mer vers Space_5 depuis QG")
	var b_sea: PackedStringArray = state.destinations_for(blue_cruiser)
	if "Space_8" not in b_sea:
		failures.append("bleu: pas de mer vers Space_8 depuis QG")
	return failures


static func _test_graph_reachability() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var from_green: PackedStringArray = BoardGraph.sea_destinations("HQ_Green")
	if "Space_5" not in from_green:
		failures.append("graphe: HQ_Green sans Space_5")
	var from5: PackedStringArray = BoardGraph.sea_destinations("Space_5")
	if "Moon_W" not in from5:
		failures.append("graphe: Space_5 sans lien Moon_W")
	return failures


static func _find_piece(
	state: GameState,
	camp: GameConstants.Camp,
	piece_type: GameConstants.PieceType,
) -> PieceInstance:
	for p: PieceInstance in state.pieces:
		if p.camp == camp and p.type == piece_type and not p.in_reserve:
			return p
	return null
