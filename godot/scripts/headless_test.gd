extends Node

const AiPlanner = preload("res://scripts/ai/ai_planner.gd")


func _ready() -> void:
	var failures: PackedStringArray = _run_checks()
	if failures.is_empty():
		print("[headless_smoke] OK — tous les tests passent.")
		get_tree().quit(0)
	else:
		printerr("[headless_smoke] ECHEC (%d) :" % failures.size())
		for msg: String in failures:
			printerr("  - ", msg)
		get_tree().quit(1)


func _run_checks() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	if BoardGraph.land_sector_count() < 40:
		failures.append("BoardGraph: land_adjacency.json incomplet")
	GameSession.reset_to_solo_defaults()
	if GameSession.human_camp != GameConstants.Camp.GREEN:
		failures.append("GameSession: camp humain attendu Vert")
	var state := GameState.new()
	state.human_camp = GameSession.human_camp
	state.reset_match()
	if state.pieces.is_empty():
		failures.append("GameState: aucune pièce")
	var ai_logs: Array[String] = AiPlanner.run_all_ai(state)
	if ai_logs.is_empty():
		failures.append("AiPlanner: aucune IA n'a joué")
	var blue_orders: int = state.camp_orders_used(GameConstants.Camp.BLUE)
	if blue_orders == 0:
		failures.append("AiPlanner: le Bleu n'a pas joué d'ordre")
	var dests: PackedStringArray = BoardGraph.land_destinations("HQ_Green", 2)
	if dests.is_empty():
		failures.append("BoardGraph: pas de voisins HQ_Green")
	for path: String in [
		"res://scenes/menu/main_menu.tscn",
		"res://scenes/menu/game_setup.tscn",
		"res://scenes/battle/battle.tscn",
	]:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			failures.append("Impossible de charger %s" % path)
	return failures
