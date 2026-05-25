class_name UiAtlasTest
extends RefCounted
## Vérifie que les clés atlas pointent vers les bons sprites (pas F/H à la place des formes).


static func run_all() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var expected: Dictionary = {
		"diamond_outline": "FORCE-AD-13a_16",
		"diamond_filled": "FORCE-AD-13a_21",
		"square_outline": "FORCE-AD-13a_15",
		"square_filled": "FORCE-AD-13a_15",
		"hbomb_h": "FORCE-AD-13a_23",
		"power_f": "FORCE-AD-13a_18",
	}
	for key: String in expected:
		if BoardAtlas.icon_id(key) != expected[key]:
			failures.append(
				"atlas %s: %s (attendu %s)" % [key, BoardAtlas.icon_id(key), expected[key]]
			)
	for bad_key: String in ["diamond_outline", "diamond_filled"]:
		var sid: String = BoardAtlas.icon_id(bad_key)
		if sid == "FORCE-AD-13a_18":
			failures.append("%s ne doit pas être la lettre F (_18)" % bad_key)
	if BoardAtlas.icon_id("diamond_filled") == "FORCE-AD-13a_23":
		failures.append("diamond_filled ne doit pas être la lettre H (_23)")
	var tex: Texture2D = UiPieceIcons.texture_for_piece(GameConstants.PieceType.CRUISER, true)
	if tex == null:
		failures.append("texture croiseur nulle")
	elif tex is AtlasTexture:
		var at := tex as AtlasTexture
		if at.region.size.x < 18.0 or at.region.size.y < 18.0:
			failures.append("losange croiseur trop petit (sprite incorrect?)")
	return failures
