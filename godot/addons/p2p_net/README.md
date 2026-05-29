# p2p_net — addon réseau Godot 4

Couche **transport P2P** jeu-agnostique : signaling WebSocket + WebRTC mesh, API bytes bruts.

## Prérequis

- Godot **4.6+**
- Desktop : [webrtc-native](https://github.com/godotengine/webrtc-native) dans `res://webrtc/` (GDExtension)
- HTML5 : WebRTC intégré (pas de GDExtension)

Première ouverture ou CI :

```powershell
godot --headless --path . --import --quit
```

## Installation

1. Copier `addons/p2p_net/` dans le projet
2. Activer le plugin **P2P Net** (Project → Project Settings → Plugins)
3. L’autoload `P2PNet` est enregistré automatiquement

## API (`P2PNet`)

| Méthode | Description |
|---------|-------------|
| `configure(config)` | `net_config.gd` : URL signaling, STUN/TURN, max peers |
| `host_room(max_peers)` | Crée une salle (host = peer id `1` en mesh) |
| `join_room(code)` | Rejoint une salle existante |
| `seal_lobby()` | Host only — ferme le lobby signaling |
| `leave()` | Quitte proprement (sans faux `connection_failed`) |
| `send_to(id, bytes, reliable)` | → `Error` |
| `broadcast(bytes, reliable)` | → `Error` |
| `room_code()` / `is_in_room()` / `is_host()` / `my_peer_id()` / `peer_ids()` | État |

### Signaux

`room_ready`, `room_sealed`, `room_left`, `peer_joined`, `peer_left`, `message_received`, `connection_failed`

`peer_joined` = WebRTC data channels prêts (pas seulement signaling).

## Configuration TURN (optionnel)

```gdscript
var cfg = load("res://addons/p2p_net/net_config.gd").defaults()
cfg.turn_url = "turn:your.server:3478"
cfg.turn_username = "user"
cfg.turn_password = "pass"
P2PNet.configure(cfg)
```

## Serveur signaling local

```powershell
godot --headless --path . res://addons/p2p_net/server/signaling_server.tscn
```

Écoute `ws://127.0.0.1:8080`. Protocole compatible [demo officielle Godot `webrtc_signaling`](https://github.com/godotengine/godot-demo-projects/tree/master/networking/webrtc_signaling).

`max_peers` est transmis à la création de salle et enforced côté serveur.

## Tests

```powershell
cd godot
.\tools\run_p2p_smoke.ps1      # 2 joueurs
.\tools\run_p2p_all.ps1        # suite V1 complète
.\tools\run_headless.ps1 -Mode p2p
```

Suite `run_p2p_all` : import GDExtension, salle invalide, smoke 2p, salle pleine, mesh 4p, `seal_lobby`.

## Backends

| Backend | État |
|---------|------|
| `WEBRTC_SIGNALING` | **V1.0** |
| `JANUS` | stub |

## Hors scope addon

- Règles de jeu Forces (`GameOrder`, sync état) → couche `forces_net_adapter` séparée
- UI lobby / matchmaking

## Version

`1.0.0` — voir `plugin.cfg`
