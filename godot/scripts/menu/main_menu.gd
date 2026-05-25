extends Control

@onready var _logo_f: Label = %LogoF
@onready var _logo_rest: Label = %LogoRest
@onready var _panel: PanelContainer = %Panel
func _ready() -> void:
	DisplayServer.window_set_title("Forces")
	MenuTheme.style_panel(_panel)
	MenuTheme.style_title(_logo_f, 48)
	MenuTheme.style_title(_logo_rest, 48)
	_logo_rest.add_theme_color_override("font_color", Color(0.72, 0.52, 0.95))
	for btn: Button in [%PlayButton, %QuickPlayButton, %TutorialButton, %OptionsButton, %QuitButton]:
		MenuTheme.style_primary_button(btn)
	AudioManager.play_menu_music()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/game_setup.tscn")


func _on_quick_play_pressed() -> void:
	GameSession.reset_to_solo_defaults()
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/tutorial_menu.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
