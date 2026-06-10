# p2p_net — P2P networking addon for Godot 4

Game-agnostic **transport layer**: WebSocket signaling + WebRTC mesh, raw byte messages.

## Requirements

- Godot **4.3+** (tested on 4.6)
- **Desktop**: [webrtc-native](https://github.com/godotengine/webrtc-native) GDExtension in `res://webrtc/`
- **HTML5**: built-in WebRTC (no extension)

After installing webrtc-native (Windows: `.\tools\setup_webrtc.ps1` in Forces, or extract [godot-extension-webrtc.zip](https://github.com/godotengine/webrtc-native/releases) into project root):

```text
godot --headless --path . --import --quit
```

## Installation

1. Copy `addons/p2p_net/` into your project
2. Enable **Project → Project Settings → Plugins → P2P Net**
3. Autoload `P2PNet` is registered automatically

## Quick start

```gdscript
# Configure (optional)
var cfg = load("res://addons/p2p_net/net_config.gd").defaults()
cfg.signaling_url = "ws://127.0.0.1:8080"
P2PNet.configure(cfg)

# Host — starts local signaling automatically if port 8080 is free
P2PNet.ensure_local_signaling()
P2PNet.room_ready.connect(func(code): print("Room: ", code))
P2PNet.host_room(4)

# Join
P2PNet.join_room("YOUR_ROOM_CODE")

# When peer_joined fires (WebRTC ready):
P2PNet.send_to(peer_id, "hello".to_utf8_buffer())
P2PNet.message_received.connect(func(from_id, data): print(data.get_string_from_utf8()))
```

## Local signaling server

**Automatic (recommended):** call `P2PNet.ensure_local_signaling()` before `host_room()` — listens on `ws://127.0.0.1:8080` inside the game process. If the port is already in use, an external server is assumed (second game instance, dedicated server, etc.).

**Manual (optional):**

```text
godot --headless --path . res://addons/p2p_net/server/signaling_server.tscn
```

## API summary

| Method | Description |
|--------|-------------|
| `ensure_local_signaling()` | Start embedded signaling on `config.signaling_url` port (desktop) |
| `host_room(max_peers)` | Create a room (auto-starts local signaling) |
| `join_room(code)` | Join existing room |
| `seal_lobby()` | Host closes signaling lobby |
| `leave()` | Clean disconnect |
| `send_to(id, bytes, reliable)` | Returns `Error` |
| `broadcast(bytes, reliable)` | Returns `Error` |
| `room_code()` / `is_in_room()` / `is_host()` | State |

**Signals:** `room_ready`, `room_sealed`, `room_left`, `peer_joined`, `peer_left`, `message_received`, `connection_failed`

`peer_joined` means WebRTC data channels are ready, not just signaling.

## TURN (optional)

```gdscript
cfg.turn_url = "turn:your.server:3478"
cfg.turn_username = "user"
cfg.turn_password = "pass"
```

## Tests (optional)

```powershell
.\tools\setup_webrtc.ps1          # Windows — download webrtc-native once
.\tools\run_headless.ps1 -Mode p2p
```

Headless smoke tests live in `addons/p2p_net/test/`. They require webrtc-native on desktop.

## License

MIT — see repository root `LICENSE`.
