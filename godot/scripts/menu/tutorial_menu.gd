extends Control

const PAGES: PackedStringArray = PackedStringArray([
	"""[b]Forces[/b] — wargame au tour par tour.

Chaque manche, tu prépares jusqu'à [b]5 ordres[/b] secret(s) : déplacements, échanges de pièces, déploiement depuis la réserve.

Quand tout le monde a validé, les ordres se résolvent [b]en même temps[/b].""",
	"""[b]Objectif[/b] : capturer le drapeau adverse au Quartier Général (HQ).

Terre, mer ([b]Space[/b]) et air ([b]Moon / Sun[/b]) : reclique une case pour changer de pièce active. Les combats comparent la [b]force[/b] — égalité = pas de capture.""",
	"""[b]Bombe H[/b] : fusionne 100 F (réserve + pièces sur la case + Power), place la bombe, puis clique une autre case pour frapper (tout détruit).""",
	"""[b]Les Power[/b] : achète des unités en réserve, échange 3→1 (soldats→régiment…), déploie sur ton QG.

Commence par une [b]partie rapide[/b] (IA normal) depuis le menu, puis configure chaque camp dans [b]Jouer[/b].""",
])


var _page: int = 0


func _ready() -> void:
	_show_page()


func _show_page() -> void:
	%PageLabel.text = PAGES[_page]
	%PageCounter.text = "%d / %d" % [_page + 1, PAGES.size()]
	%PrevButton.disabled = _page <= 0
	%NextButton.text = "Suivant" if _page < PAGES.size() - 1 else "Retour menu"


func _on_prev_pressed() -> void:
	if _page > 0:
		_page -= 1
		_show_page()


func _on_next_pressed() -> void:
	if _page < PAGES.size() - 1:
		_page += 1
		_show_page()
	else:
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
