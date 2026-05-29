extends RefCounted
## Protocole compatible demo officielle Godot webrtc_signaling.

enum Message {
	JOIN,
	ID,
	PEER_CONNECT,
	PEER_DISCONNECT,
	OFFER,
	ANSWER,
	CANDIDATE,
	SEAL,
}
