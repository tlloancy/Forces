# Forces — Godot 4

Portage jouable du jeu **Forces** (Unity / JavaScript, 2013) vers **Godot 4.6**.

Le dépôt Unity d’origine reste à la racine (`Assets/`). Ce dossier est le client Godot autonome.

## Statut (v1 solo)

| Domaine | État |
|---------|------|
| Menu → config → bataille | OK |
| Plateau atlas (tuiles, mer, QG) | OK |
| Terre / mer / air + surbrillances | OK |
| Power, réserve, achats, échanges 3→1, déploiement QG | OK |
| Bombes H (fusion 100 F, frappe) | OK |
| Combats multi-camps + capture drapeau | OK |
| IA (Facile / Normal / Difficile) | OK |
| Tutoriel, options (volumes persistés) | OK |
| Multijoueur réseau | Non |
| Monétisation / pub | Hors scope (sur demande) |
| Tuiles directionnelles pixel-perfect Unity | Optionnel |

## Branche

`godot4-port`

## Lancer

1. Godot 4.6 → importer `godot/`
2. **F5** : menu principal
3. **Partie rapide** ou **Jouer** → bataille

Contrôles bataille : clic case ; reclic = changer de pièce ; clic destination = ordre ; **Fin manche** = IA + résolution.

## Tests headless

```powershell
cd godot
$env:GODOT_BIN = "C:\...\Godot_v4.6.3-stable_win64_console.exe"
.\tools\run_headless.ps1
```

## Architecture

| Dossier | Rôle |
|---------|------|
| `scenes/menu/` | Menu, config, options, tutoriel |
| `scenes/battle/` | Carte + sidebar |
| `scripts/core/` | Moteur (`game_state`, graphes, combats) |
| `scripts/ai/` | `ai_planner.gd` |
| `data/*.json` | Layout plateau, adjacences, atlas |

Journal détaillé : [`CHANGELOG.md`](CHANGELOG.md).

## Legacy Unity

Référence règles / parsers : `../Assets/Scripts/`
