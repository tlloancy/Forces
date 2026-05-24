extends Control

@onready var _logo: Label = %LogoLabel


func _ready() -> void:
	DisplayServer.window_set_title("Forces")


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
