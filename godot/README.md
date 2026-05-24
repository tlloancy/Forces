# Forces — Godot 4

Portage du jeu **Forces** (Unity / JavaScript, stage 42, 2013) vers **Godot 4.6** (4.x compatible).

Le dépôt Unity d’origine reste à la racine (`Assets/`, etc.). Ce dossier est le client Godot autonome.

## Branche

Développement sur `godot4-port`.

## Ouvrir le projet

1. Installer [Godot 4.6](https://godotengine.org/download) (ou la version que tu utilises déjà).
2. Importer le dossier `godot/` comme projet.
## Flux joueur

1. **Menu** — Jouer / Partie rapide / Tutoriel / Options / Quitter  
2. **Créer partie** — Vert = vous ; Bleu/Rouge/Jaune = IA ou joueur (+ difficulté IA)  
3. **Bataille** — planification des ordres (moteur actuel)

F5 démarre sur le **menu principal**.

## Tests headless (CLI / CI / agent)

Sans ouvrir l’éditeur, pour vérifier compilation + moteur :

```powershell
cd godot
# Une fois Godot installé, optionnel :
$env:GODOT_BIN = "C:\Users\tom\Downloads\Godot_v4.6.3-stable_win64.exe"
.\tools\run_headless.ps1          # smoke (défaut)
.\tools\run_headless.ps1 compile  # charge le projet 3 frames
.\tools\run_headless.ps1 import   # importe les assets
```

Linux/macOS :

```bash
cd godot
export GODOT_BIN=/path/to/godot
./tools/run_headless.sh smoke
```

Équivalent manuel :

```bash
godot --headless --path . "res://scenes/headless_test.tscn"
godot --headless --path . "res://scenes/menu/main_menu.tscn" --quit-after 2
```

Le workflow GitHub `.github/workflows/godot-headless.yml` lance les mêmes checks sur push `godot/**`.

## Architecture

| Dossier | Rôle |
|---------|------|
| `scenes/menu/` | Menu principal, config partie, options, tutoriel |
| `scenes/battle/` | Écran de bataille (ex-UI debug) |
| `scripts/app/game_session.gd` | Autoload — config persistée menu → bataille |
| `scripts/core/` | Moteur sans UI |
| `data/land_adjacency.json` | Graphe terrestre |

## Roadmap

Voir [`CHANGELOG.md`](CHANGELOG.md) pour le détail daté.

1. ~~**Moteur terrestre**~~ — état, ordres multi-camps, résolution simplifiée, capture drapeau
2. ~~**Menus & flux**~~ — menu → config → bataille
3. ~~**IA basique**~~ — `ai_planner.gd` (Facile/Normal/Difficile)
4. **Mer / air** — parsers `Dep_mer.js` / `Dep_air.js`
5. **Plateau visuel** — assets Unity / JP
6. **Règles Power** — jetons, réserve, échanges, bombes H
7. **UI bataille** — remplacement `infoButtons.js` / `playerTurn.js`
8. **Multijoueur** — WebSocket / ENet

## Legacy Unity

Référence : `../Assets/Scripts/`
