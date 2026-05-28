extends Control

var _pages: PackedStringArray = PackedStringArray([
	"""[b]Forces[/b] — turn-based wargame (up to 4 camps).

Each [b]round[/b]:
1. [b]Planning[/b] — up to [b]5 secret orders[/b] (moves, deploy, exchanges, H-bomb).
2. [b]Resolution[/b] — all orders run [b]at once[/b], then combat, flags, Power harvest.

[b]Goal[/b] — an enemy unit on your [b]Headquarters[/b] (HQ) eliminates that camp.""",
	"""[b]Sectors[/b] — Land (plains, forest, ice…), sea ([b]Space[/b]), air ([b]Moon[/b] / [b]Sun[/b]).

Click a sector again to change the [b]active piece[/b] (land / sea / air).

Each type has [b]combat force[/b] (F) and allowed destinations on the board graph.""",
	"""[b]Combat[/b] — after movement, any sector with [b]two or more camps[/b] fights.

Add up F for [b]every[/b] unit of each camp on that sector (H-bomb does not count).

• [b]Winner[/b] — highest total force, [b]strictly above[/b] second place — losers go to [b]reserve[/b] at HQ.
• [b]Tie[/b] — top two forces [b]equal[/b] — no capture; all units on that sector [b]bounce back[/b] to their [b]start-of-round[/b] position (sector or reserve).""",
	"""[b]Power[/b] — tokens to buy reserve units, deploy on your HQ, or merge [b]3 small → 1 large[/b] (e.g. 3 soldiers → 1 commando).

[b]Harvest[/b] — +1 Power per round if you hold any sector on an [b]enemy island[/b].

[b]H-bomb[/b] — fuse 100 F (reserve + pieces on sector + Power), place the bomb, then strike another sector — everything there is destroyed.""",
	"""[b]Tips[/b]
• Round orders appear in the tactical feed (symbols + camp colors).
• Undo your [b]last[/b] human order before ending the round.
• Quick match or [b]Play[/b] to set camps, AI, and timer.

Same rules as the original Unity game: simultaneous resolution, tie bounce, flag capture at HQ.""",
])


var _page: int = 0


func _ready() -> void:
	_show_page()


func _show_page() -> void:
	%PageLabel.text = _pages[_page]
	%PageCounter.text = "%d / %d" % [_page + 1, _pages.size()]
	%PrevButton.disabled = _page <= 0
	%NextButton.text = "Next" if _page < _pages.size() - 1 else "Main menu"


func _on_prev_pressed() -> void:
	if _page > 0:
		_page -= 1
		_show_page()


func _on_next_pressed() -> void:
	if _page < _pages.size() - 1:
		_page += 1
		_show_page()
	else:
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
