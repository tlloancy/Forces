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
	if BoardGraph.sea_sector_count() < 40:
		failures.append("BoardGraph: sea_adjacency.json incomplet")
	if BoardGraph.air_sector_count() < 30:
		failures.append("BoardGraph: air_adjacency.json incomplet")
	GameSession.reset_to_solo_defaults()
	if GameSession.human_camp != GameConstants.Camp.GREEN:
		failures.append("GameSession: camp humain attendu Vert")
	var state := GameState.new()
	state.human_camp = GameSession.human_camp
	state.reset_match()
	if state.camp_power(GameConstants.Camp.GREEN) != GameConstants.STARTING_POWER:
		failures.append("GameState: Power de départ incorrect")
	var sea_from_hq: PackedStringArray = BoardGraph.sea_destinations("HQ_Green")
	if sea_from_hq.is_empty():
		failures.append("BoardGraph: pas de voisins mer depuis HQ_Green")
	var air_from_hq: PackedStringArray = BoardGraph.air_destinations("HQ_Green")
	if air_from_hq.is_empty():
		failures.append("BoardGraph: pas de voisins air depuis HQ_Green")
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
	var cruiser: PieceInstance = null
	for p: PieceInstance in state.pieces:
		if p.camp == GameConstants.Camp.GREEN and p.type == GameConstants.PieceType.CRUISER:
			cruiser = p
			break
	if cruiser == null:
		failures.append("GameState: pas de croiseur vert")
	elif "Space_5" not in state.destinations_for(cruiser):
		failures.append("GameState: croiseur sans destination mer depuis QG")
	else:
		var err: String = state.try_move_human_piece(cruiser, "Space_5")
		if not err.is_empty():
			failures.append("GameState: déplacement mer refusé (%s)" % err)
	var hunter: PieceInstance = null
	for p: PieceInstance in state.pieces:
		if p.camp == GameConstants.Camp.GREEN and p.type == GameConstants.PieceType.HUNTER:
			hunter = p
			break
	if hunter != null and not hunter.in_reserve:
		var air_dests: PackedStringArray = state.destinations_for(hunter)
		if air_dests.is_empty():
			failures.append("GameState: chasseur sans destination air depuis QG")
	var raider: PieceInstance = null
	var soldier: PieceInstance = null
	for p: PieceInstance in state.pieces:
		if p.camp != GameConstants.Camp.GREEN:
			continue
		if p.type == GameConstants.PieceType.RAIDER:
			raider = p
		elif p.type == GameConstants.PieceType.SOLDIER:
			soldier = p
	if raider != null and soldier != null:
		if state.destinations_for(raider).size() <= state.destinations_for(soldier).size():
			failures.append("GameState: tank sans portée > soldat depuis QG")
	var hbomb_state := GameState.new()
	hbomb_state.human_camp = GameConstants.Camp.GREEN
	hbomb_state.reset_match()
	var hq_green: String = BoardCatalog.hq_for_camp(GameConstants.Camp.GREEN)
	for _i in 50:
		hbomb_state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER, hq_green, true)
	if hbomb_state.hbomb_fusion_force_available(GameConstants.Camp.GREEN, hq_green) < GameConstants.HBOMB_FUSION_FORCE:
		failures.append("GameState: fusion H insuffisante après seed réserve")
	var fuse_err: String = hbomb_state.try_place_hbomb(GameConstants.Camp.GREEN, hq_green)
	if not fuse_err.is_empty():
		failures.append("GameState: fusion H refusée (%s)" % fuse_err)
	else:
		var apply_logs: Array[String] = []
		hbomb_state.apply_planning_orders(apply_logs)
		var target: String = "Sun"
		if hbomb_state.hbomb_on_board(GameConstants.Camp.GREEN) == null:
			failures.append("GameState: bombe H absente après fusion")
		else:
			hbomb_state._add_piece(GameConstants.Camp.BLUE, GameConstants.PieceType.SOLDIER, target, false)
			var bomb: PieceInstance = hbomb_state.hbomb_on_board(GameConstants.Camp.GREEN)
			if target not in hbomb_state.destinations_for(bomb):
				failures.append("GameState: bombe H sans cibles de frappe")
			else:
				var strike_err: String = hbomb_state.try_hbomb_strike(GameConstants.Camp.GREEN, target)
				if not strike_err.is_empty():
					failures.append("GameState: frappe H refusée (%s)" % strike_err)
				else:
					hbomb_state.end_planning_round()
					for p: PieceInstance in hbomb_state.pieces_on_sector(target):
						failures.append("GameState: frappe H n'a pas vidé %s" % target)
						break
	for path: String in [
		"res://scenes/menu/main_menu.tscn",
		"res://scenes/menu/game_setup.tscn",
		"res://scenes/battle/battle.tscn",
	]:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			failures.append("Impossible de charger %s" % path)
	return failures
