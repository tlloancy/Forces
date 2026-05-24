# Changelog — Forces Godot 4

Journal des évolutions du dossier `godot/` (hors dépôt Unity legacy).

Format des entrées : `AAAA-MM-JJ HH:MM:SS` (heure locale).

---

## 2026-05-24 23:39:01 — Mer/air, Power, carte visuelle, audio legacy

### Réalisé

- **Graphes mer & air** — `parse_dep_adjacency.py`, `sea_adjacency.json` (53), `air_adjacency.json` (40), API `BoardGraph.piece_destinations()` par domaine (terre/mer/air)
- **Moteur Power** — jetons de départ/revenu par manche, recrutement en réserve, fusion 3→1 (Régiment, Bombardier…), déploiement QG *(mécanique du jeu original, pas monétisation réelle)*
- **Carte cliquable** — `board_map.gd` + `sector_layout.json`, fond océan, sélection sur la carte (liste secteurs masquée)
- **UI bataille** — barres Recruter / Fusion / Déployer, compteur Power
- **Audio** — `AudioManager`, musiques legacy `FORCE7.mp3` / `GoConquer.mp3` copiées dans `assets/audio/`
- **Présentation** — thème menu type stratégie mobile (or/bleu nuit), splash `FORCE-AD-13a.png`
- **Tests** — smoke headless étendu (mer, air, Power)

### À faire (priorité jeu complet)

- [ ] Plateau graphique fidèle (hex/cases Unity, pas seulement boutons)
- [ ] Bombes H, combats détaillés, ordre de résolution legacy
- [ ] IA : mer/air, Power, fusions, bombes
- [ ] Tutoriel jouable, polish animations
- [ ] Multijoueur
- [ ] Monétisation / pub — **tout dernier**, si jamais

---

## 2026-05-24 22:59:33 — Moteur jouable, menus, IA, CI headless

### Réalisé

#### Moteur (`scripts/core/`)

- **`game_constants.gd`** — camps (Vert/Bleu/Rouge/Jaune), types de pièces, stats force/portée/coût Power, phases de partie, couleurs UI.
- **`board_catalog.gd`** — catalogue des 56 secteurs (depuis `Biblidecor.js`) : QG, neutralité, appartenance camp, `hq_for_camp()`.
- **`board_graph.gd`** — graphe terrestre chargé depuis `data/land_adjacency.json` : voisins move-1 / move-3, BFS distance, `land_destinations()`.
- **`game_state.gd`** — état de partie : pièces, camps vivants, jetons Power (structure), ordres **par camp** (`orders_by_camp`, max 5/manche), pièces déjà déplacées (`pieces_moved_this_round`), spawn initial (4 types × 2 au QG), `try_move_piece()` / `try_move_human_piece()`, fin de manche + capture drapeau QG, signaux phase/manche/déplacement.
- **`game_order.gd`** — ordre typé (MOVE) avec description texte.
- **`piece_instance.gd`** — instance pièce (id, camp, type, secteur, réserve).
- **`battle_resolver.gd`** — résolution simplifiée des conflits : somme des forces par camp sur un secteur, capture des pièces perdantes (égalité = pas de capture).

#### Données & outils

- **`data/land_adjacency.json`** — 45 secteurs terrestres extraits de `Dep_terre.js` (move_1 et move_3).
- **`tools/parse_dep_terre.py`** — régénération du JSON depuis le legacy Unity.
- **`tools/run_headless.ps1`** / **`run_headless.sh`** — modes `smoke`, `compile`, `import` ; lecture optionnelle de `tools/godot.env` pour `GODOT_BIN`.
- **`tools/godot.env.example`** — modèle de config locale (gitignored : `godot.env`).

#### Session & menus (`scripts/app/`, `scripts/menu/`, `scenes/menu/`)

- **`GameSession`** (autoload) — config persistée menu → bataille : camp humain (Vert par défaut), slots Bleu/Rouge/Jaune (IA ou joueur humain futur), difficulté IA (Facile / Normal / Difficile), volumes musique/SFX (structure).
- **`main_menu.tscn`** — Jouer, Partie rapide, Tutoriel, Options, Quitter.
- **`game_setup.tscn`** — configuration des camps adverses + difficulté IA ; résumé avant lancement.
- **`options_menu.tscn`** — sliders volume (UI seulement, pas encore branchés audio).
- **`tutorial_menu.tscn`** — placeholder tutoriel.
- **`menu_theme.gd`** — styles communs menus.

#### Bataille (`scripts/battle/`, `scenes/battle/`)

- **`battle.tscn`** + **`battle.gd`** — UI debug fonctionnelle : liste secteurs, pièces du joueur, destinations terrestres, journal RichText, bouton **Fin de manche**, retour menu.
- Déplacements terrestres du camp humain validés en jeu (F5).
- Compteur « Vos ordres X/5 ».
- À la fin de manche : exécution **`AiPlanner.run_all_ai()`** puis résolution combats ; détection victoire basique (≤ 1 camp vivant après manche 1).

#### IA (`scripts/ai/`)

- **`ai_planner.gd`** — IA unique paramétrée par difficulté (agressivité 0.35 / 0.62 / 0.88) :
  - cible QG ennemi le plus proche (BFS terrestre) ;
  - scoring destinations : attaque favorable, expansion territoire, progression vers QG, défense QG ;
  - priorité pièces par force de combat ;
  - max 5 ordres / manche, une pièce déplacée une fois par manche.
- Preload explicite dans `battle.gd` et `headless_test.gd` (class_name non indexée en CLI sans cache éditeur).

#### Tests & CI

- **`scenes/headless_test.tscn`** + **`headless_test.gd`** — smoke : BoardGraph, GameSession, GameState, **AiPlanner** (Bleu joue ≥ 1 ordre), chargement scènes menu/bataille.
- **`.github/workflows/godot-headless.yml`** — Godot 4.6.3 Linux, which `godot/**` : smoke + compile menu.
- Dernière exécution locale validée : `smoke` exit 0, `compile` exit 0.

#### Projet

- **`project.godot`** — Godot 4.6, scène principale = menu, autoloads GameConstants / BoardCatalog / BoardGraph / GameSession, renderer mobile.
- **`README.md`** (racine Forces) — lien vers branche `godot4-port` et dossier `godot/`.
- Suppression de l’ancienne scène orpheline `scenes/main.tscn` (remplacée par le flux menu).

### Non réalisé (prochaines étapes)

#### Graphe & déplacements

- [ ] Parser **`Dep_mer.js`** → `data/sea_adjacency.json` + API `BoardGraph.sea_*`.
- [ ] Parser **`Dep_air.js`** → `data/air_adjacency.json` + API `BoardGraph.air_*`.
- [ ] Types navals / aériens (Croiseur mer, Bombardier, Chasseur lourd, Destroyer) — règles move depuis secteurs mer / air.
- [ ] Cases **Space_*** et règles spéciales non terrestres.

#### Moteur & règles Power

- [ ] Jetons **Power** : gain, dépense, achat de pièces (`orders.js`, `allChoose.js`).
- [ ] **Réserve** : pièces en attente, déploiement.
- [ ] **Échanges** entre camps.
- [ ] **Commando**, **Bombe H** — règles complètes.
- [ ] Résolution combat fidèle au legacy (pas seulement somme des forces).
- [ ] Phases distinctes planification / résolution en UI.

#### Interface

- [ ] Plateau visuel (carte, tokens, assets `Assets/Textures/`).
- [ ] UI bataille remplaçant `infoButtons.js` / `playerTurn.js`.
- [ ] Tutoriel jouable (contenu depuis `ScriptMenu/Tutorial.js`).
- [ ] Options : persistance volumes, plein écran.
- [ ] Animations / SFX (`Assets/Sound/`).

#### IA

- [ ] Équilibrage fin vs `ScriptIA_*.js` (~23k lignes × 3) si nécessaire.
- [ ] IA mer / air / achats Power / bombes.

#### Multijoueur

- [ ] Remplacement UNet Unity (WebSocket / ENet / Godot multiplayer) — écran « joueur réseau » déjà prévu dans `GameSession`.

#### Qualité

- [ ] Tests unitaires GDScript supplémentaires (combat, Power, graphes mer/air).
- [ ] Export mobile (Android / iOS) — cible historique Google Play (`com.QD.Forc2`).

### Notes techniques

- Godot **4.6.3** ; binaire console Windows : chemin dans `tools/godot.env` (local, gitignored).
- Legacy Unity inchangé sous `Assets/` — référence pour parsers et règles.
- Ce changelog ne documente pas le dépôt Unity d’origine ; uniquement l’avancement du client Godot.
