class_name FullMatchTest
extends RefCounted

const RoundResolverScript = preload("res://scripts/core/round_resolver.gd")
## Partie complète headless — règles, combats, IA, bombe H, victoire, timeout.


static func run_all() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	failures.append_array(_test_invalid_actions())
	failures.append_array(_test_buy_deploy_move_round())
	failures.append_array(_test_combat_rebound_and_capture())
	failures.append_array(_test_sea_lateral_corridors())
	failures.append_array(_test_power_territory_and_exchange())
	failures.append_array(_test_hbomb_full_cycle())
	failures.append_array(_test_hq_capture_and_victory())
	failures.append_array(_test_planning_timeout())
	failures.append_array(_test_ai_difficulties())
	failures.append_array(_test_simulated_multi_round_match())
	return failures


static func _fresh_state() -> GameState:
	GameSession.reset_to_solo_defaults()
	var state := GameState.new()
	state.human_camp = GameConstants.Camp.GREEN
	state.reset_match()
	return state


static func _test_invalid_actions() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	var green_soldier: PieceInstance = _piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER)
	var blue_soldier: PieceInstance = _piece(state, GameConstants.Camp.BLUE, GameConstants.PieceType.SOLDIER)
	if green_soldier == null or blue_soldier == null:
		return ["invalid_actions: pièces manquantes"]
	if state.try_move_human_piece(blue_soldier, "Plains_C").is_empty():
		failures.append("déplacement pièce ennemie autorisé")
	var dest: String = state.destinations_for(green_soldier)[0]
	state.try_move_human_piece(green_soldier, dest)
	if state.try_move_human_piece(green_soldier, dest).is_empty():
		failures.append("double mouvement autorisé")
	state.reset_match()
	green_soldier = _piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER)
	# Inject power for the order-limit test (STARTING_POWER may be 0)
	state.power_tokens[GameConstants.Camp.GREEN] = 100
	for _i in range(GameConstants.MAX_ORDERS_PER_ROUND + 1):
		state.try_buy_human(GameConstants.PieceType.SOLDIER)
	if state.camp_orders_used(GameConstants.Camp.GREEN) > GameConstants.MAX_ORDERS_PER_ROUND:
		failures.append(">5 achats acceptés")
	state.power_tokens[GameConstants.Camp.GREEN] = 0
	if state.try_buy_human(GameConstants.PieceType.SOLDIER).is_empty():
		failures.append("achat sans Power refusé à tort")
	return failures


static func _test_buy_deploy_move_round() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	# Inject power (STARTING_POWER may be 0 — buying unlocks only after rounds)
	state.power_tokens[GameConstants.Camp.GREEN] = 20
	var start_p: int = state.camp_power(GameConstants.Camp.GREEN)
	var buy_err: String = state.try_buy_human(GameConstants.PieceType.SOLDIER)
	if not buy_err.is_empty():
		failures.append("achat soldat: %s" % buy_err)
	if state.camp_power(GameConstants.Camp.GREEN) >= start_p:
		failures.append("Power non débité à l'achat")
	var res_piece: PieceInstance = null
	for p: PieceInstance in state.reserve_pieces(GameConstants.Camp.GREEN):
		if p.type == GameConstants.PieceType.SOLDIER:
			res_piece = p
			break
	if res_piece == null:
		return ["buy_deploy: pas de soldat en réserve"]
	var hq: String = BoardCatalog.hq_for_camp(GameConstants.Camp.GREEN)
	var dep_err: String = state.try_deploy_human(res_piece, hq)
	if not dep_err.is_empty():
		failures.append("déploiement QG: %s" % dep_err)
	var logs: Array[String] = []
	state.apply_planning_orders(logs)
	if res_piece.in_reserve:
		failures.append("déploiement non appliqué à la lecture")
	return failures


static func _test_combat_rebound_and_capture() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	var sector: String = "Plains_C"
	state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER, sector, false)
	state._add_piece(GameConstants.Camp.BLUE, GameConstants.PieceType.SOLDIER, sector, false)
	var msg_tie: String = BattleResolver.resolve_sector(state, sector)
	if msg_tie.is_empty() or (not msg_tie.contains("galité") and not msg_tie.contains("Égalité")):
		failures.append("égalité combat non détectée (%s)" % msg_tie)
	for i in range(state.pieces.size() - 1, -1, -1):
		if state.pieces[i].sector_id == sector:
			state.pieces.remove_at(i)
	state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.RAIDER, sector, false)
	state._add_piece(GameConstants.Camp.BLUE, GameConstants.PieceType.SOLDIER, sector, false)
	var msg_win: String = BattleResolver.resolve_sector(state, sector)
	if msg_win.is_empty():
		failures.append("combat vainqueur sans message")
	var blue_on_sector: bool = false
	var blue_in_reserve: bool = false
	var hq_blue: String = BoardCatalog.hq_for_camp(GameConstants.Camp.BLUE)
	for p: PieceInstance in state.pieces:
		if p.camp != GameConstants.Camp.BLUE or p.type != GameConstants.PieceType.SOLDIER:
			continue
		if p.sector_id == sector and not p.in_reserve:
			blue_on_sector = true
		if p.in_reserve and p.sector_id == hq_blue:
			blue_in_reserve = true
	if blue_on_sector:
		failures.append("perdant encore sur la case après combat")
	if not blue_in_reserve:
		failures.append("perdant pas renvoyé en réserve HQ")
	return failures


static func _test_sea_lateral_corridors() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var layout: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/sector_layout.json"))
	if typeof(layout) != TYPE_DICTIONARY:
		return ["sector_layout.json illisible"]
	var d: Dictionary = layout as Dictionary
	for sid: String in ["Space_5", "Space_8", "Space_12", "Space_10"]:
		if not d.has(sid):
			failures.append("couloir %s absent du layout" % sid)
	var state := _fresh_state()
	var cruiser: PieceInstance = _piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.CRUISER)
	if cruiser == null:
		return ["pas de croiseur"]
	var sea: PackedStringArray = state.destinations_for(cruiser)
	if "Space_5" not in sea:
		failures.append("croiseur sans Space_5 (couloir ouest)")
	var blue_cruiser: PieceInstance = _piece(state, GameConstants.Camp.BLUE, GameConstants.PieceType.CRUISER)
	if blue_cruiser != null and "Space_8" not in state.destinations_for(blue_cruiser):
		failures.append("croiseur bleu sans Space_8 (couloir est)")
	if "Plains_NE" in sea:
		failures.append("croiseur atteint terre en 1 pas mer")
	return failures


static func _test_power_territory_and_exchange() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	state.power_tokens[GameConstants.Camp.GREEN] = 0
	var logs: Array[String] = []
	state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.HUNTER, "Ice_NW", false)
	state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.HUNTER, "Ice_NE", false)
	state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.HUNTER, "Jungle_NE", false)
	RoundResolverScript.apply_power_harvest(state, logs)
	if state.camp_power(GameConstants.Camp.GREEN) != 2:
		failures.append("récolte: 2 îles ennemies = +2 Force (got %d)" % state.camp_power(GameConstants.Camp.GREEN))
	var islands: Array[GameConstants.Camp] = RoundResolverScript.occupied_enemy_islands(
		state, GameConstants.Camp.GREEN
	)
	if islands.size() != 2:
		failures.append("récolte: attendu 2 îles (Ice+Jungle), got %d" % islands.size())
	var ex := _fresh_state()
	var hq: String = BoardCatalog.hq_for_camp(GameConstants.Camp.GREEN)
	for _i in 3:
		ex._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER, hq, true)
	var ex_err: String = ex.try_exchange_human(GameConstants.PieceType.COMMANDO)
	if not ex_err.is_empty():
		failures.append("échange commando: %s" % ex_err)
	if ex._count_reserve(GameConstants.Camp.GREEN, GameConstants.PieceType.COMMANDO) < 1:
		failures.append("commando absent après échange")
	return failures


static func _test_hbomb_full_cycle() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	var hq: String = BoardCatalog.hq_for_camp(GameConstants.Camp.GREEN)
	for _i in 55:
		state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER, hq, true)
	var fuse_err: String = state.try_place_hbomb(GameConstants.Camp.GREEN, hq)
	if not fuse_err.is_empty():
		failures.append("fusion H: %s" % fuse_err)
	state.apply_planning_orders([])
	if state.hbomb_on_board(GameConstants.Camp.GREEN) == null:
		failures.append("bombe H absente après fusion")
	var target: String = "Sun"
	state._add_piece(GameConstants.Camp.BLUE, GameConstants.PieceType.SOLDIER, target, false)
	var bomb: PieceInstance = state.hbomb_on_board(GameConstants.Camp.GREEN)
	var strike_err: String = state.try_hbomb_strike(GameConstants.Camp.GREEN, target)
	if not strike_err.is_empty():
		failures.append("frappe H: %s" % strike_err)
	state.end_planning_round()
	for p: PieceInstance in state.pieces_on_sector(target):
		if p.type != GameConstants.PieceType.HBOMB:
			failures.append("frappe H n'a pas détruit la cible")
			break
	return failures


static func _test_hq_capture_and_victory() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	var green_hq: String = BoardCatalog.hq_for_camp(GameConstants.Camp.GREEN)
	state._add_piece(GameConstants.Camp.BLUE, GameConstants.PieceType.COMMANDO, green_hq, false)
	var logs: Array[String] = []
	state._check_flag_captures(logs)
	if state.is_alive(GameConstants.Camp.GREEN):
		failures.append("Vert toujours vivant avec ennemi sur QG")
	state.reset_match()
	for camp: GameConstants.Camp in [GameConstants.Camp.BLUE, GameConstants.Camp.RED, GameConstants.Camp.YELLOW]:
		state.alive[camp] = false
	if state.survivors_count() != 1:
		failures.append("survivors_count victoire != 1")
	return failures


static func _test_planning_timeout() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := _fresh_state()
	state.match_timer_seconds = 8
	var logs: Array[String] = []
	state.apply_planning_timeout(logs)
	if state.phase != GameConstants.GamePhase.GAME_OVER:
		failures.append("timeout: phase pas GAME_OVER")
	if state.survivors_count() != 0:
		failures.append("timeout: camps encore vivants")
	return failures


static func _test_ai_difficulties() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	for diff: GameSession.Difficulty in [
		GameSession.Difficulty.EASY,
		GameSession.Difficulty.NORMAL,
		GameSession.Difficulty.HARD,
	]:
		GameSession.reset_to_solo_defaults()
		GameSession.set_slot(GameConstants.Camp.BLUE, GameSession.SlotKind.AI, diff)
		var state := _fresh_state()
		AiPlanner.run_all_ai(state)
		if state.camp_orders_used(GameConstants.Camp.BLUE) == 0:
			failures.append("IA %s inactive" % GameSession.difficulty_label(diff))
	return failures


static func _test_simulated_multi_round_match() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	GameSession.reset_to_solo_defaults()
	var state := _fresh_state()
	var max_rounds: int = 12
	for _round in range(max_rounds):
		if state.phase == GameConstants.GamePhase.GAME_OVER:
			break
		if state.phase != GameConstants.GamePhase.PLANNING:
			failures.append("phase inattendue en simulation")
			break
		var human: PieceInstance = _piece(state, state.human_camp, GameConstants.PieceType.SOLDIER)
		if human != null and not human.in_reserve:
			var dests: PackedStringArray = state.destinations_for(human)
			if not dests.is_empty():
				state.try_move_human_piece(human, dests[0])
		if state.camp_power(state.human_camp) >= 2:
			state.try_buy_human(GameConstants.PieceType.SOLDIER)
		state.end_planning_round()
	if state.round_number < 2:
		failures.append("simulation: moins de 2 manches jouées")
	return failures


static func _piece(
	state: GameState,
	camp: GameConstants.Camp,
	piece_type: GameConstants.PieceType,
) -> PieceInstance:
	for p: PieceInstance in state.pieces:
		if p.camp == camp and p.type == piece_type and not p.in_reserve:
			return p
	return null
