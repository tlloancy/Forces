extends Node

func _ready() -> void:
	print("WebRTCLibPeerConnection: ", ClassDB.class_exists("WebRTCLibPeerConnection"))
	if ClassDB.class_exists("WebRTCLibPeerConnection"):
		WebRTCPeerConnection.set_default_extension("WebRTCLibPeerConnection")
	var peer := WebRTCPeerConnection.new()
	var err: int = peer.initialize({"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]})
	print("initialize: ", err)
	get_tree().quit(0 if err == OK else 1)
