@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("P2PNet", "res://addons/p2p_net/p2p_net.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("P2PNet")
