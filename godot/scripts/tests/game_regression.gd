class_name GameRegression
extends RefCounted
## Tests logiques headless — non-régression minimale (mouvements, ordres, Power, IA).

static func run_all() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	failures.append_array(_test_graphs())
	failures.append_array(_test_orders_and_deferred_moves())
	failures.append_array(_test_movement_domains())
	failures.append_array(_test_power_and_exchange())
	failures.append_array(_test_ai_plays())
	return failures


static func _test_graphs() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	if BoardGraph.land_sector_count() < 40:
		failures.append("graphe terre incomplet")
	if BoardGraph.sea_sector_count() < 40:
		failures.append("graphe mer incomplet")
	if BoardGraph.air_sector_count() < 30:
		failures.append("graphe air incomplet")
	return failures


static func _test_orders_and_deferred_moves() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := GameState.new()
	state.human_camp = GameConstants.Camp.GREEN
	state.reset_match()
	var soldier: PieceInstance = _first_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER)
	if soldier == null:
		return ["pas de soldat"]
	var from: String = soldier.sector_id
	var dest: String = "Plains_C"
	if dest not in state.destinations_for(soldier):
		dest = state.destinations_for(soldier)[0]
	var err: String = state.try_move_human_piece(soldier, dest)
	if not err.is_empty():
		failures.append("ordre mouvement refusé: %s" % err)
	if soldier.sector_id != from:
		failures.append("mouvement appliqué avant lecture (secteur changé trop tôt)")
	var logs: Array[String] = []
	state.apply_planning_orders(logs)
	if soldier.sector_id != dest:
		failures.append("mouvement non appliqué à la lecture")

	var limit_state := GameState.new()
	limit_state.human_camp = GameConstants.Camp.GREEN
	limit_state.reset_match()
	# Inject power (STARTING_POWER may be 0)
	limit_state.power_tokens[GameConstants.Camp.GREEN] = 100
	for _i in range(GameConstants.MAX_ORDERS_PER_ROUND):
		var buy_err: String = limit_state.try_buy_human(GameConstants.PieceType.SOLDIER)
		if not buy_err.is_empty():
			failures.append("achat ordre %d refusé: %s" % [_i + 1, buy_err])
	var sixth: String = limit_state.try_buy_human(GameConstants.PieceType.SOLDIER)
	if sixth.is_empty():
		failures.append("6e ordre accepté (max %d)" % GameConstants.MAX_ORDERS_PER_ROUND)
	if limit_state.camp_orders_used(GameConstants.Camp.GREEN) > GameConstants.MAX_ORDERS_PER_ROUND:
		failures.append("compteur ordres > max")

	state.reset_match()
	soldier = _first_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER)
	state.try_move_human_piece(soldier, state.destinations_for(soldier)[0])
	var err2: String = state.try_move_human_piece(soldier, state.destinations_for(soldier)[0])
	if err2.is_empty():
		failures.append("double mouvement même pièce autorisé")
	return failures


static func _test_movement_domains() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := GameState.new()
	state.reset_match()
	var soldier: PieceInstance = _first_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER)
	var raider: PieceInstance = _first_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.RAIDER)
	var cruiser: PieceInstance = _first_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.CRUISER)
	var hunter: PieceInstance = _first_piece(state, GameConstants.Camp.GREEN, GameConstants.PieceType.HUNTER)
	if soldier != null and raider != null:
		if state.destinations_for(raider).size() <= state.destinations_for(soldier).size():
			failures.append("portée tank <= soldat")
	if cruiser != null:
		var sea: PackedStringArray = state.destinations_for(cruiser)
		if sea.is_empty():
			failures.append("croiseur sans mer")
		if "Plains_NE" in sea:
			failures.append("croiseur QG atteint Plains_NE")
	if hunter != null and state.destinations_for(hunter).is_empty():
		failures.append("chasseur sans air")
	return failures


static func _test_power_and_exchange() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var state := GameState.new()
	state.human_camp = GameConstants.Camp.GREEN
	state.reset_match()
	var start_p: int = state.camp_power(GameConstants.Camp.GREEN)
	state._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER, "Ice_NW", false)
	state.end_planning_round()
	if state.camp_power(GameConstants.Camp.GREEN) <= start_p:
		failures.append("Power territoire non crédité")
	var ex := GameState.new()
	ex.reset_match()
	var hq: String = BoardCatalog.hq_for_camp(GameConstants.Camp.GREEN)
	for _i in 3:
		ex._add_piece(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER, hq, true)
	if ex._count_reserve(GameConstants.Camp.GREEN, GameConstants.PieceType.SOLDIER) < 3:
		failures.append("seed réserve soldats")
	var err: String = ex.try_exchange_human(GameConstants.PieceType.COMMANDO)
	if not err.is_empty():
		failures.append("échange 3●→Cmd: %s" % err)
	if ex._count_reserve(GameConstants.Camp.GREEN, GameConstants.PieceType.COMMANDO) < 1:
		failures.append("échange sans commando en réserve")
	return failures


static func _test_ai_plays() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	GameSession.reset_to_solo_defaults()
	var state := GameState.new()
	state.reset_match()
	AiPlanner.run_all_ai(state)
	if state.camp_orders_used(GameConstants.Camp.BLUE) == 0:
		failures.append("IA bleue inactive")
	return failures


static func _first_piece(
	state: GameState,
	camp: GameConstants.Camp,
	piece_type: GameConstants.PieceType,
) -> PieceInstance:
	for p: PieceInstance in state.pieces:
		if p.camp == camp and p.type == piece_type and not p.in_reserve:
			return p
	return null
