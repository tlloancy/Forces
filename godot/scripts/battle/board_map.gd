extends Control
## Plateau Forces — texture composée (tuiles Unity) + zones cliquables sector_layout.json.

signal sector_pressed(sector_id: String)

const DESIGN := Vector2(280.0, 280.0)
const SIDEBAR_MARGIN_LEFT := 368.0
const SIDEBAR_MARGIN_RIGHT := 272.0
const BOARD_TEXTURE := "res://assets/textures/board_composed.png"

var _layout: Dictionary = {}
var _layout_meta: Dictionary = {}
var _board_tex: Texture2D
var _hits: Dictionary = {}
var _selected: String = ""
var _move_highlights: PackedStringArray = PackedStringArray()
var _highlight_color: Color = Color(0.72, 0.76, 0.82, 0.9)
var _state: GameState
var _flash_sectors: PackedStringArray = PackedStringArray()
var _flash_color: Color = Color(1.0, 0.45, 0.35, 0.7)
var _flash_time_left: float = 0.0
var _anim_t: float = 0.0

var _move_anim: Dictionary = {}
const MOVE_ANIM_SEC: float = 0.42
const DUST_COUNT := 26
var _dust: Array[Dictionary] = []


func _ready() -> void:
	if ResourceLoader.exists(BOARD_TEXTURE):
		_board_tex = load(BOARD_TEXTURE) as Texture2D
	_load_layout()
	_build()
	_init_dust()
	set_process(true)
	resized.connect(_on_resized)
	call_deferred("_on_resized")
	queue_redraw()


func _init_dust() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260528
	_dust.clear()
	for _i in range(DUST_COUNT):
		_dust.append({
			"x": rng.randf(),
			"y": rng.randf(),
			"speed": rng.randf_range(0.006, 0.022),
			"drift": rng.randf_range(-0.008, 0.008),
			"r": rng.randf_range(0.9, 2.4),
			"a": rng.randf_range(0.12, 0.34),
			"phase": rng.randf_range(0.0, TAU),
		})


func _load_layout() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/sector_layout.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		_layout = parsed as Dictionary
		if _layout.has("_meta") and typeof(_layout["_meta"]) == TYPE_DICTIONARY:
			_layout_meta = _layout["_meta"] as Dictionary
		_layout.erase("_meta")


func _design_size() -> Vector2:
	return Vector2(
		float(_layout_meta.get("design_width", DESIGN.x)),
		float(_layout_meta.get("design_height", DESIGN.y)),
	)


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_hits.clear()
	for sector_id: String in BoardCatalog.SECTOR_IDS:
		if not _layout.has(sector_id):
			continue
		var hit := Control.new()
		hit.name = sector_id
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		hit.gui_input.connect(_on_hit.bind(sector_id))
		add_child(hit)
		_hits[sector_id] = hit
	_relayout_hits()


func _board_rect() -> Rect2:
	var pad := 12.0
	var design := _design_size()
	var left := SIDEBAR_MARGIN_LEFT + pad
	var avail := Rect2(
		left,
		pad,
		maxf(1.0, size.x - left - SIDEBAR_MARGIN_RIGHT - pad),
		maxf(1.0, size.y - pad * 2.0),
	)
	var aspect := design.x / design.y
	var w := avail.size.x
	var h := w / aspect
	if h > avail.size.y:
		h = avail.size.y
		w = h * aspect
	var ox := left + (avail.size.x - w) * 0.5
	var oy := avail.position.y + (avail.size.y - h) * 0.5
	return Rect2(ox, oy, w, h)


func _on_resized() -> void:
	_relayout_hits()
	queue_redraw()


func _scale(board: Rect2) -> Vector2:
	var design := _design_size()
	return Vector2(board.size.x / design.x, board.size.y / design.y)


func _board_scale(board: Rect2) -> float:
	var s := _scale(board)
	return minf(s.x, s.y)


func _relayout_hits() -> void:
	if _hits.is_empty():
		return
	var board := _board_rect()
	var s := _scale(board)
	var sc := _board_scale(board)
	for sector_id: String in _hits:
		var hit: Control = _hits[sector_id]
		var rect := _hit_rect(board, s.x, s.y, sc, sector_id)
		hit.position = rect.position
		hit.size = rect.size


func refresh(state: GameState) -> void:
	_state = state
	queue_redraw()


func _pieces_for_display(sector_id: String) -> Array[PieceInstance]:
	if _state == null:
		return []
	if _state.phase == GameConstants.GamePhase.PLANNING:
		return _state.planning_pieces_on_sector(sector_id)
	return _state.pieces_on_sector(sector_id)


func animate_combat_outcome(_state_ref: GameState, info: Dictionary) -> void:
	_state = _state_ref
	var from_sector: String = str(info.get("from", ""))
	var to_sector: String = str(info.get("to", ""))
	if from_sector.is_empty() or to_sector.is_empty():
		return
	if not _layout.has(from_sector) or not _layout.has(to_sector):
		return
	var mode: String = str(info.get("mode", "rebound"))
	var duration: float = MOVE_ANIM_SEC * (1.0 if mode == "capture" else 0.85)
	_move_anim = {
		"piece_id": int(info.get("piece_id", -1)),
		"type": info.get("type", GameConstants.PieceType.SOLDIER),
		"camp": info.get("camp", GameConstants.Camp.GREEN),
		"winner_camp": info.get("winner_camp", GameConstants.Camp.GREEN),
		"mode": mode,
		"from": _sector_screen_center(from_sector),
		"to": _sector_screen_center(to_sector),
		"elapsed": 0.0,
		"duration": duration,
	}
	queue_redraw()
	while float(_move_anim.get("elapsed", 0.0)) < float(_move_anim.get("duration", MOVE_ANIM_SEC)):
		await get_tree().process_frame
	_move_anim = {}
	queue_redraw()


func animate_retreat(_state_ref: GameState, info: Dictionary) -> void:
	info["mode"] = info.get("mode", "rebound")
	await animate_combat_outcome(_state_ref, info)


func set_selected(sector_id: String) -> void:
	_selected = sector_id
	queue_redraw()


func set_move_highlights(sectors: PackedStringArray) -> void:
	_move_highlights = sectors
	queue_redraw()


func set_highlight_color(color: Color) -> void:
	_highlight_color = color
	queue_redraw()


func flash_sectors(sectors: PackedStringArray, color: Color = Color(1.0, 0.45, 0.35, 0.75), duration: float = 0.85) -> void:
	_flash_sectors = sectors
	_flash_color = color
	_flash_time_left = maxf(duration, 0.1)


func _process(delta: float) -> void:
	_anim_t += delta
	if _flash_time_left > 0.0:
		_flash_time_left = maxf(0.0, _flash_time_left - delta)
	if not _move_anim.is_empty():
		var elapsed: float = float(_move_anim.get("elapsed", 0.0)) + delta
		_move_anim["elapsed"] = minf(elapsed, float(_move_anim.get("duration", MOVE_ANIM_SEC)))
	# Poussière ambiante : dérive lente continue (toujours animée, coût minime).
	for d: Dictionary in _dust:
		d["y"] = fposmod(float(d["y"]) - float(d["speed"]) * delta, 1.0)
		d["x"] = fposmod(float(d["x"]) + float(d["drift"]) * delta, 1.0)
	queue_redraw()


func animate_order(state: GameState, order: GameOrder) -> void:
	var piece: PieceInstance = state.find_piece(order.piece_id)
	if piece == null:
		return
	var from_sector: String = ""
	match order.kind:
		GameOrder.Kind.MOVE:
			from_sector = piece.sector_id
		GameOrder.Kind.DEPLOY_FROM_RESERVE:
			from_sector = BoardCatalog.hq_for_camp(piece.camp)
		_:
			return
	var to_sector: String = order.to_sector
	if not _layout.has(from_sector) or not _layout.has(to_sector):
		return
	_state = state
	_move_anim = {
		"piece_id": piece.id,
		"type": piece.type,
		"camp": piece.camp,
		"from": _sector_screen_center(from_sector),
		"to": _sector_screen_center(to_sector),
		"elapsed": 0.0,
		"duration": MOVE_ANIM_SEC,
	}
	queue_redraw()
	while float(_move_anim.get("elapsed", 0.0)) < float(_move_anim.get("duration", MOVE_ANIM_SEC)):
		await get_tree().process_frame
	_move_anim = {}
	queue_redraw()


func _sector_screen_center(sector_id: String) -> Vector2:
	var board := _board_rect()
	var sx := _scale(board).x
	var sy := _scale(board).y
	return _sector_center(board, sx, sy, sector_id)


func _on_hit(event: InputEvent, sector_id: String) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			set_selected(sector_id)
			sector_pressed.emit(sector_id)


func _sector_center(board: Rect2, sx: float, sy: float, sector_id: String) -> Vector2:
	var d: Dictionary = _layout[sector_id] as Dictionary
	return Vector2(
		board.position.x + float(d["x"]) * sx,
		board.position.y + float(d["y"]) * sy,
	)


func _hit_rect(board: Rect2, sx: float, sy: float, _sc: float, sector_id: String) -> Rect2:
	var center := _sector_center(board, sx, sy, sector_id)
	var design := BoardAtlas.highlight_design_size(sector_id)
	var w: float = design.x * sx
	var h: float = design.y * sy
	return Rect2(center - Vector2(w, h) * 0.5, Vector2(w, h))


func _draw() -> void:
	var board := _board_rect()
	# Fond légèrement plus profond que l'ancien bleu plat (repère visuel immédiat).
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.11, 0.12, 0.22))
	_draw_vignette()
	if _board_tex != null:
		draw_texture_rect(_board_tex, board, false)
	else:
		draw_rect(board, Color(0.22, 0.24, 0.32))
		push_warning("board_composed.png manquant — lancer tools/compose_board_from_tiles.py")
	_draw_board_frame(board)
	_draw_dust()

	if _state == null:
		return

	var sx := _scale(board).x
	var sy := _scale(board).y
	var sc := _board_scale(board)
	var anim_id: int = int(_move_anim.get("piece_id", -1)) if not _move_anim.is_empty() else -1

	if _flash_time_left > 0.0:
		var pulse: float = 0.45 + 0.55 * sin(_flash_time_left * 14.0)
		var fc := Color(_flash_color.r, _flash_color.g, _flash_color.b, _flash_color.a * pulse)
		for sector_id: String in _flash_sectors:
			if _layout.has(sector_id):
				draw_rect(_hit_rect(board, sx, sy, sc, sector_id).grow(2.0), fc, false, 3.0)

	for sector_id: String in _move_highlights:
		if _layout.has(sector_id):
			_draw_move_highlight(_hit_rect(board, sx, sy, sc, sector_id), sector_id)

	for sector_id: String in _state.human_pending_move_targets():
		if _layout.has(sector_id):
			var r := _hit_rect(board, sx, sy, sc, sector_id)
			draw_rect(r, Color(0.45, 1.0, 0.6, 0.72), false, 1.5)

	if _selected != "" and _layout.has(_selected):
		_draw_selection(_hit_rect(board, sx, sy, sc, _selected).grow(2.0))

	for sector_id: String in _layout:
		var stack: Array[PieceInstance] = _pieces_for_display(sector_id)
		if stack.is_empty():
			continue
		var drawn: Array[PieceInstance] = []
		for p: PieceInstance in stack:
			if p.id != anim_id:
				drawn.append(p)
		if drawn.is_empty():
			continue
		var c := _sector_center(board, sx, sy, sector_id)
		_draw_sector_pieces(c, sc, drawn)

	if anim_id >= 0:
		_draw_move_anim(sc)


func _draw_sector_pieces(center: Vector2, sc: float, stack: Array[PieceInstance]) -> void:
	var by_type: Dictionary = {}
	for p: PieceInstance in stack:
		var key: int = int(p.type)
		if not by_type.has(key):
			by_type[key] = {"piece": p, "n": 0}
		var entry: Dictionary = by_type[key] as Dictionary
		entry["n"] = int(entry["n"]) + 1
	var keys: Array = by_type.keys()
	keys.sort()
	if keys.size() == 1:
		var solo: Dictionary = by_type[keys[0]] as Dictionary
		_draw_piece_stack(center, sc, solo["piece"] as PieceInstance, int(solo["n"]))
		return
	var ring: float = 9.5 * sc
	for i: int in range(keys.size()):
		var entry: Dictionary = by_type[keys[i]] as Dictionary
		var angle: float = TAU * float(i) / float(keys.size()) - PI * 0.5
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * ring
		_draw_piece_stack(pos, sc * 0.88, entry["piece"] as PieceInstance, int(entry["n"]))


func _draw_piece_stack(center: Vector2, sc: float, piece: PieceInstance, count: int) -> void:
	var camp_color: Color = GameConstants.CAMP_COLORS[piece.camp]
	var icon_size := 12.5 * sc
	_draw_piece_backing(center, icon_size, camp_color)
	_draw_piece_icon(center, icon_size, piece.type, camp_color)
	if count > 1:
		_draw_stack_badge(center, icon_size, count)


func _draw_move_anim(sc: float) -> void:
	var duration: float = float(_move_anim.get("duration", MOVE_ANIM_SEC))
	var elapsed: float = float(_move_anim.get("elapsed", 0.0))
	var t: float = clampf(elapsed / maxf(duration, 0.001), 0.0, 1.0)
	var eased: float = t * t * (3.0 - 2.0 * t)
	var mode: String = str(_move_anim.get("mode", "move"))
	var pos: Vector2 = (_move_anim["from"] as Vector2).lerp(_move_anim["to"] as Vector2, eased)
	var piece_type: GameConstants.PieceType = _move_anim["type"] as GameConstants.PieceType
	var camp: GameConstants.Camp = _move_anim["camp"] as GameConstants.Camp
	var camp_color: Color = GameConstants.CAMP_COLORS[camp]
	if mode == "capture":
		var winner: GameConstants.Camp = _move_anim["winner_camp"] as GameConstants.Camp
		var winner_color: Color = GameConstants.CAMP_COLORS[winner]
		camp_color = camp_color.lerp(winner_color, eased)
	var icon_size := 12.5 * sc * (0.85 + 0.15 * eased)
	var alpha: float = 1.0
	if mode == "capture" and t > 0.72:
		alpha = 1.0 - clampf((t - 0.72) / 0.28, 0.0, 1.0)
		icon_size *= 1.0 - (t - 0.72) * 0.35
	if alpha > 0.02:
		camp_color.a = alpha
		_draw_piece_backing(pos, icon_size, camp_color)
		_draw_piece_icon(pos, icon_size, piece_type, camp_color)
	if mode == "capture" and t > 0.68:
		_draw_capture_burst(pos, sc, clampf((t - 0.68) / 0.32, 0.0, 1.0), camp_color)


func _draw_piece_backing(center: Vector2, icon_size: float, camp_color: Color) -> void:
	var r := icon_size * 1.05
	var a: float = camp_color.a
	draw_circle(center, r + 2.0, Color(0.02, 0.03, 0.06, 0.65 * a))
	draw_circle(center, r, Color(camp_color.r, camp_color.g, camp_color.b, 0.42 * a))
	_draw_circle_outline(center, r, Color(camp_color.r, camp_color.g, camp_color.b, 0.95 * a), 2.0)


func _draw_capture_burst(center: Vector2, sc: float, burst_t: float, color: Color) -> void:
	var n: int = 8
	for i in range(n):
		var a: float = TAU * float(i) / float(n)
		var dist: float = (6.0 + 18.0 * burst_t) * sc
		var p: Vector2 = center + Vector2(cos(a), sin(a)) * dist
		var r: float = (2.0 + 4.0 * (1.0 - burst_t)) * sc
		var fade: float = (1.0 - burst_t) * color.a
		draw_circle(p, r, Color(color.r, color.g, color.b, fade * 0.85))
	draw_circle(center, (4.0 + 14.0 * burst_t) * sc, Color(1.0, 0.55, 0.25, (1.0 - burst_t) * 0.55 * color.a))


func _draw_circle_outline(center: Vector2, radius: float, color: Color, width: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var steps := 20
	for i in range(steps + 1):
		var a := TAU * float(i) / float(steps)
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	draw_polyline(pts, color, width, true)


func _draw_stack_badge(center: Vector2, icon_size: float, count: int) -> void:
	var pos := center + Vector2(icon_size * 0.8, -icon_size * 0.8)
	var r := maxf(6.0, icon_size * 0.62)
	draw_circle(pos, r, Color(0.05, 0.06, 0.1, 0.92))
	_draw_circle_outline(pos, r, Color(1, 1, 1, 0.8), 1.0)
	var font := ThemeDB.fallback_font
	var fsize := int(maxf(9.0, r * 1.15))
	var txt := str(count)
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, fsize).x
	draw_string(
		font,
		pos + Vector2(-tw * 0.5, fsize * 0.36),
		txt,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		fsize,
		Color(1, 1, 1, 0.98),
	)


func _draw_selection(rect: Rect2) -> void:
	# Halo pulsé + cadre pointillé animé pour repérer la case active sans texte.
	var pulse: float = 0.55 + 0.45 * sin(_anim_t * 4.0)
	draw_rect(rect.grow(2.0), Color(0.95, 0.88, 0.45, 0.12 * pulse), true)
	_draw_dashed_rect(rect, Color(1, 1, 1, 0.55 + 0.4 * pulse), 5.0)


func _draw_dust() -> void:
	for d: Dictionary in _dust:
		var px: float = float(d["x"]) * size.x
		var py: float = float(d["y"]) * size.y
		var twinkle: float = 0.55 + 0.45 * sin(_anim_t * 1.8 + float(d["phase"]))
		var a: float = float(d["a"]) * twinkle
		var r: float = float(d["r"])
		draw_circle(Vector2(px, py), r + 1.2, Color(0.55, 0.72, 0.98, a * 0.35))
		draw_circle(Vector2(px, py), r, Color(0.82, 0.92, 1.0, a))


func _draw_vignette() -> void:
	# Assombrit les bords — profondeur type Spirits, visible sur tout l'écran.
	var steps := 8
	for i in range(steps):
		var t: float = float(i) / float(steps)
		var inset: float = t * 28.0
		var alpha: float = 0.07 * (1.0 - t)
		draw_rect(
			Rect2(inset, inset, size.x - inset * 2.0, size.y - inset * 2.0),
			Color(0.02, 0.03, 0.08, alpha),
			false,
			2.0,
		)


func _draw_board_frame(board: Rect2) -> void:
	# Cadre doré pulsé autour du plateau — repère que le build polish est actif.
	var pulse: float = 0.35 + 0.25 * sin(_anim_t * 2.2)
	draw_rect(board.grow(4.0), Color(0.82, 0.68, 0.22, pulse), false, 2.0)


func _draw_move_highlight(rect: Rect2, _sector_id: String) -> void:
	var pulse: float = 0.32 + 0.22 * sin(_anim_t * 3.0)
	draw_rect(rect, Color(_highlight_color.r, _highlight_color.g, _highlight_color.b, pulse * 0.5), true)
	_draw_dashed_rect(rect.grow(1.0), Color(1.0, 1.0, 1.0, 0.32 + pulse), 4.0)


func _draw_piece_icon(center: Vector2, icon_size: float, piece_type: GameConstants.PieceType, color: Color) -> void:
	var tex: AtlasTexture = BoardAtlas.piece_board_texture(piece_type)
	if tex == null or tex.atlas == null:
		return
	var tw: float = maxf(1.0, float(tex.get_width()))
	var th: float = maxf(1.0, float(tex.get_height()))
	var h := icon_size
	var w := icon_size * (tw / th)
	draw_texture_rect(tex, Rect2(center - Vector2(w * 0.5, h * 0.5), Vector2(w, h)), false, color)


func _draw_dashed_rect(rect: Rect2, color: Color, dash: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0),
		rect.position + rect.size,
		rect.position + Vector2(0, rect.size.y),
		rect.position,
	])
	for i in range(pts.size() - 1):
		_draw_dashed_line(pts[i], pts[i + 1], color, dash)


func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, dash: float) -> void:
	var dir := to - from
	var seg_len := dir.length()
	if seg_len < 1.0:
		return
	dir /= seg_len
	var t := 0.0
	while t < seg_len:
		var t2 := minf(t + dash, seg_len)
		draw_line(from + dir * t, from + dir * t2, color, 2.0)
		t += dash * 2.0
