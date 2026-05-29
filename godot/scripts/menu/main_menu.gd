extends Control

@onready var _logo_f: Label = %LogoF
@onready var _logo_rest: Label = %LogoRest
@onready var _panel: PanelContainer = %Panel
@onready var _resume_btn: Button = %ResumeButton
@onready var _loading: LoadingScreen = $LoadingScreen


func _ready() -> void:
	DisplayServer.window_set_title("Forces")
	MenuTheme.style_panel(_panel)
	MenuTheme.style_title(_logo_f, 48)
	MenuTheme.style_title(_logo_rest, 48)
	_logo_rest.add_theme_color_override("font_color", Color(0.25, 0.45, 0.85))
	for btn: Button in [%PlayButton, %OnlineButton, %QuickPlayButton, %TutorialButton, %OptionsButton, %QuitButton]:
		MenuTheme.style_primary_button(btn)
	AudioManager.play_menu_music()
	_update_resume_button()


func _update_resume_button() -> void:
	if _resume_btn == null:
		return
	_resume_btn.visible = GameSession.has_saved_battle()
	if _resume_btn.visible:
		MenuTheme.style_primary_button(_resume_btn)


func _on_play_pressed() -> void:
	GameSession.clear_saved_battle()
	get_tree().change_scene_to_file("res://scenes/menu/game_setup.tscn")


func _on_online_pressed() -> void:
	GameSession.clear_saved_battle()
	get_tree().change_scene_to_file("res://scenes/menu/network_lobby.tscn")


func _on_resume_pressed() -> void:
	if not GameSession.has_saved_battle():
		return
	_load_battle("Resuming…")


func _on_quick_play_pressed() -> void:
	GameSession.clear_saved_battle()
	GameSession.reset_to_solo_defaults()
	_load_battle("Quick match…")


func _load_battle(hint: String) -> void:
	if _loading:
		await _loading.show_and_load("res://scenes/battle/battle.tscn", hint)
	else:
		get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/tutorial_menu.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
