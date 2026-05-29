# Changelog — Forces Godot 4

Journal des évolutions du dossier `godot/` (hors dépôt Unity legacy).

Format des entrées : `AAAA-MM-JJ HH:MM:SS` (heure locale, fuseau du commit Git si présent).

**Règle** : chaque commit Git sur `godot4-port` ajoute ou complète une section datée ici (réalisé, fichiers touchés, tests, commits `hash`).

---

## 2026-05-29 — Couche réseau Forces (`ForcesNet`, MVP 2 joueurs)

### Intégration au-dessus de `P2PNet` (pas dans l’addon)
- **`ForcesNet`** autoload : protocole JSON `start` / `order` / `state` sur `P2PNet`.
- **`network_lobby`** : Host / Join / code salle / Start match (Green host, Blue guest).
- Menu **Online (2 players)** → lobby.
- **`GameSession`** : `SlotKind.NETWORK`, `reset_for_network_host/client()`.
- **`battle.gd`** : host autoritaire (fin de manche + snapshot) ; client envoie ordres.
- **`game_state.try_apply_network_order()`** : host valide les ordres distants.

### Prérequis test
- Signaling : `res://addons/p2p_net/server/signaling_server.tscn`
- webrtc-native + `godot --import`

**Commit** : _(pending)_

---

## 2026-05-29 01:45:00 — Addon réseau générique `p2p_net` (V1.0)

### Addon `addons/p2p_net/` (GDScript, jeu-agnostique)
- **`P2PNet`** autoload V1 : `host_room()`, `join_room()`, `seal_lobby()`, `leave()`, `send_to()` / `broadcast()` avec retour `Error`, getters `room_code()` / `is_in_room()`.
- Signaux : `room_ready`, **`room_sealed`**, `peer_joined` (WebRTC prêt), `peer_left`, `message_received`, `connection_failed`.
- **`max_peers`** enforced côté serveur signaling ; TURN optionnel dans `net_config.gd`.
- **`leave()`** propre — plus de faux `connection_failed` au shutdown.
- Tests : `run_p2p_smoke.ps1` (2p), **`run_p2p_all.ps1`** (invalid room, room full, mesh 4p, seal), `run_headless.ps1 -Mode p2p`.
- Branche : `godot4-network`.

### Prérequis desktop
- Extension **[webrtc-native](https://github.com/godotengine/webrtc-native)** pour WebRTC hors HTML5 ; `godot --import` une fois.

### Fichiers
- `addons/p2p_net/` (+ `README.md`, tests `net_mesh_test`, `net_negative_test`)
- `tools/run_p2p_all.ps1`
- `project.godot` — autoload `P2PNet`, plugin activé

**Commit** : `4fa2b85` (`godot4-network`)

---

### UX sidebar (fin de la galère)
- **`battle_sidebar.gd`** + **`battle.tscn`** : panneau **RESERVE** épinglé en haut (chips larges, compteur `1× Raider`), **ORDERS** avec lignes BBCode colorées par secteur, **⚡ + chiffre** en HUD (plus d’atlas `power_f` confondu avec F5).
- Bouton **`⚑ Deploy reserve → HQ`** vert pleine largeur sous les chips (plus l’icône soldier invisible sur barre noire) ; libellé dynamique `Deploy Raider → HQ` quand une unité est sélectionnée.
- Suppression **`ActiveChipHost`** — fin du rond fantôme au milieu de la sidebar.
- **`piece_chip.gd`** : chips cliquables camp + surbrillance sélection ; réserve visible même si ordre en file (dimmed).

### Règles alignées Unity
- **Power** : suppression du faux **`POWER_PER_ROUND +3`** ; le ⚡ vient **uniquement** de la récolte (`apply_power_harvest`, +1 par île ennemie occupée).
- **Combat** : vainqueur **capture** l’unité ennemie → **réserve du gagnant** (`battle_resolver.gd`, pas HQ du perdant).
- **`STARTING_POWER = 0`** conservé ; recrutement via shop RESERVE.

### Feedback & résolution
- **`power_toast.gd`** : toasts gain récolte, achat, capture combat.
- **`battle.gd`** : animations déplacement/combat, flash secteurs, undo ordre ↩, pause/sauvegarde partie, feed phases sans bonus manche.

### Plateau
- **`compose_board_from_tiles.py`** + **`board_composed.png`** : teintes îles Unity rehaussées.

### Fichiers
- `scripts/battle/battle.gd`, `battle_sidebar.gd`, `battle_feed.gd`, `board_map.gd`, `power_toast.gd`
- `scripts/core/battle_resolver.gd`, `game_state.gd`, `game_constants.gd`, `game_order.gd`, `round_resolver.gd`
- `scripts/ui/piece_chip.gd`, `ui_piece_icons.gd`, `scripts/menu/menu_theme.gd`
- `scenes/battle/battle.tscn`, `scripts/tests/full_match_test.gd`
- `tools/compose_board_from_tiles.py`, `assets/textures/board_composed.png`

### Tests
- `.\tools\run_headless.ps1 -Mode smoke` — compile OK ; 1 échec préexistant (`tie: blue must bounce to origin sector`).

**Commit** : `ed1cafe` (`godot4-port-polish`, dépôt `tlloancy/Forces`)

---

### UX — plus de double journal confus
- **`battle_feed.gd`** (`BattleFeed`) : panneau gauche style Matrix (fond vert sombre, texte défilant, frappe caractère par caractère).
- Remplace **`OrdersQueue`** + **`OrdersLog`** par **`FeedPanel`** : titre `> FORCES // TACTICAL LINK`, barre HUD (`timer · manche · P · [ordres]`), flux `%FeedOutput`.
- Couleurs par type : ordres joueur (vert clair), phases (bleu), combats (orange), récolte (jaune), IA (violet), erreurs (rouge), victoire (doré).
- **`battle.gd`** : chaque action humaine → `push_order_planned` ; résolution manche ligne par ligne avec attente de frappe ; IA via `push_ai_block`.
- **`game_order.feed_line()`** : texte français lisible (`Vous — ordre 2/5 : ○ CE → NE`, achat, déploiement, fusion H).
- Sidebar élargie (~288 px) ; **`board_map.SIDEBAR_MARGIN`** = 296.

### Sidebar forces / réserve
- Panneau **Forces** (P), **Réserve** (ligne d’unités cliquables), **Recruter** (achats) — séparation claire dans `battle.tscn` / `battle_sidebar.gd`.

### Plateau & icônes (suite)
- Connecteurs Lune/Soleil/Espace : octogones plats PIL (plus de sprites atlas superposés) — `compose_board_from_tiles.py`, `board_composed.png`.
- Boutons unités : retour **outline/filled** géométriques (pas de portraits) — `ui_piece_icons.gd`.

### Règles & tests
- **`full_match_test`** : perdant combat → réserve HQ (pas capture) ; récolte +1 Force par **île** ennemie occupée (2 îles = +2).

### Fichiers
- `scripts/battle/battle_feed.gd`, `battle.gd`, `battle_sidebar.gd`, `board_map.gd`
- `scripts/core/game_order.gd`
- `scenes/battle/battle.tscn`
- `scripts/tests/full_match_test.gd`, `scripts/ui/ui_piece_icons.gd`
- `tools/compose_board_from_tiles.py`, `assets/textures/board_composed.png`

**Commit** : `ade0043` (`godot4-port`, dépôt `tlloancy/Forces`)

---

## 2026-05-26 (nuit 4d) — Portraits d'unités, carré plein corrigé, power 0 au départ

### Assets enfin utilisés
- `UiPieceIcons` : nouveaux portraits d'unités (`soldier`/`raider`/`hunter`/`cruiser` de l'atlas) dans les boutons achat ET les boutons compteur de case
- Boutons "Recruter" : portrait 26px + coût doré "P2/P3/P5/P10" en colonne verticale
- Boutons CaseInfo : portrait 22px teinté par camp + "×N" en couleur camp

### Bug carré plein enfin résolu
- `atlas_sprites.json` : `square_filled` → `FORCE-AD-13a_20` (était erronément `_15` = outline depuis le début)
- `parse_atlas_meta.py` : source du mapping corrigée → `_20` régénéré à chaque run
- `verify_atlas_shapes.py` : assertion mise à jour + `_15` ajouté aux sprites interdits pour le carré plein
- `run_headless.ps1` : `parse_atlas_meta.py` s'exécute maintenant **avant** `verify_atlas_shapes.py`

### Équilibre : pas de recrutement dès le départ
- `STARTING_POWER = 0` (était 12) — le joueur ne peut pas recruter à la manche 1 ; le power s'accumule à raison de +3 par manche
- Tests (`game_regression.gd`, `full_match_test.gd`) : injection de power explicite pour les cas qui testent le système d'achat

---

## 2026-05-26 (nuit 4c) — Panneau "Recruter" : distinction visuelle achat vs quantité

- `battle.tscn` : label "Reserve" → "Recruter" (sémantiquement correct — on recrute des unités)
- `ui_piece_icons.setup_buy_button` : icône outline + coût **P2/P3/P5/P10** en doré — impossible de confondre avec un compteur de pièces (ex. "○2" en blanc)
- `battle.tscn` : suppression des `text` hardcodés sur les boutons d'achat (remplacés au runtime)

---

## 2026-05-25 (nuit 4b) — Secteur non présélectionné au démarrage

- `battle.gd` : `_selected_sector = ""` au lieu de l'HQ — CaseInfo démarre vide, les 8 pièces initiales sur l'HQ ne s'affichent plus comme une "réserve chargée"
- `battle_sidebar.gd` : affiche "—" dans le titre de CaseInfo quand aucun secteur n'est sélectionné

---

## 2026-05-25 (nuit 4) — Îles en aplat + icônes unités colorées par camp

### Plateau — îles en octogone plat (style Unity)
- Abandon des sprites atlas qui produisaient un effet "tartan" : chaque île est maintenant un octogone PIL vectoriel rempli avec la couleur exacte Unity (`#8b3040`, `#4a3578`, `#2a6e6a`, `#8a6a30`)
- Grille 3×3 intérieure en teinte claircie de l'île (plus de lignes bleu-nuit sombres)
- HQ corners : petit octogone teinté sombre (couleur camp × 0.55) au lieu d'un sprite atlas écrasé par multiply
- `CAMP_TINT` : valeurs Unity directes (aplat, plus besoin de compenser le multiply)

### Icônes unités — outline/filled + couleur camp
- `UiPieceIcons.make_unit_button()` : unités de base → icône outline (○□△◇), fusionnées → filled (●■▲♦)
- Camp color transmise via `modulate` sur le `TextureRect` de l'icône
- `battle_sidebar._build_unit_buttons()` : récupère `GameConstants.CAMP_COLORS[human_camp]` et le passe à `make_unit_button`

---

## 2026-05-25 (nuit 3) — Log icônes, bouton ▶ fixé, couleurs îles rehaussées

### Bouton ▶ toujours visible
- `OrdersLog` : `fit_content = false` + `scroll_following = true` — le log n'étire plus la sidebar et ne pousse plus le bouton hors de l'écran.
- `OrdersQueue` : `custom_minimum_size = (0, 56)` pour un espace minimal garanti.

### Log sans texte — 100 % icônes colorées
- `GameOrder.bbcode_label()` — format compact BBCode : `[color=camp]piece_sym[/color] secteur_from→secteur_to`
  - HQ → `[color=camp]⚑[/color]`, mer → gris, île → couleur camp
  - Achat : `[color=camp]+sym[/color]`, échange : `sym→sym`, H-bombe : `H☠dest`
- AI planner : `◈ IA N` (N = initial difficulté) + ordres en `bbcode_label()` — plus de "Tank : HQ_Blue → Ice_SW"
- Séparateur de manche : `── R2 ──` (discret) au lieu de "Fin manche 2" en gras

### Couleurs îles
- `_tint()` : luminance remappée sur **[0.55, 1.0]** — les zones sombres de l'atlas gardent la teinte cible sans virer au noir
- `CAMP_TINT` : valeurs compensées pour que le rendu multiply atteigne les hex Unity (`#8b3040`, `#4a3578`, `#2a6e6a`, `#8a6a30`)

---

## 2026-05-25 (nuit 2) — Design plateau : fidélité Unity (fond, îles, surbrillances, sidebar)

**Référence** : captures Unity `Screenshot_20260525-000216_Forc2.jpg` / `000226`.

### Plateau (`board_map.gd` + `compose_board_from_tiles.py`)

| Élément | Avant | Après |
|---------|-------|-------|
| Fond écran | `#171c2b` | **`#2b2d4a`** — slate Unity exact |
| Fond `board_composed.png` | `#1c1e34` | **`#2b2d4a`** |
| Surbrillances déplacement | fill coloré (pâtés) | **pointillé blanc** seul (alpha 0.42) |
| Pending moves | fill vert + stroke | stroke vert seul |
| Tuiles îles | 27×27 px | **33×33 px** (îles plus présentes) |
| Tuiles HQ | 28×28 px | **32×32 px** |
| Tuiles Moons / Sun / Space | 22/24/14 | **26/28/16 px** |

### Couleurs îles (`compose_board_from_tiles.py`)

| Camp | Avant | Après | Cible Unity |
|------|-------|-------|-------------|
| Plains | `(190,90,95)` | `(175,60,78)` | `#8b3040` bordeaux |
| Ice | `(135,105,185)` | `(68,58,158)` | `#4a3578` violet profond |
| Jungle | `(80,155,145)` | `(38,108,104)` | `#2a6e6a` teal sombre |
| Desert | `(190,155,80)` | `(175,138,52)` | `#8a6a30` doré |

### Sidebar (`battle.tscn` + `battle_sidebar.gd`)

- Labels de section ajoutés : **« Case Info »**, **« Reserve »**, **« Orders »** (gris clair 10 px)
- Badge **« HQ »** rouge visible quand le secteur sélectionné est le QG humain
- Timer reformaté : `59:43  R1` (temps devant, manche derrière)

**Commit** : `60d0422` — `Design plateau: fond #2b2d4a, iles teintees Unity, surbrillances propres.`

### Fix grille mosaïque

- `_draw_grid` limitée aux **zones île** (bounding box 3×3) — plus de grille globale 23 px sur tout le plateau qui créait un effet de répétition ×8 après upscale Godot.

---

## 2026-05-25 (nuit) — Surbrillances déplacements alignées sur les tuiles

**Problème** : rectangles de surbrillance / sélection trop grands (31×31 îles, connecteurs mer jusqu’à 46 px) → chevauchements en « pâtés » sur la grille.

**Correction** :
- **`highlight_design_size()`** dans `board_atlas.gd` — mêmes tailles que `compose_board_from_tiles.py` (îles 27, HQ 28, Moons 22, Sun 24, Space 14)
- **`board_map.gd`** — `_hit_rect` utilise uniquement ces dimensions (suppression des `r × 2` / `r × 3.5`)

**Tests** : `.\tools\run_headless.ps1 -Mode smoke` — OK.

**Commit** : `5d9a565` — `Fix surbrillances deplacement alignees sur tuiles composees.`

---

## 2026-05-25 (soir) — Carte Unity complète : îles, couloirs bordure, croix centrale

**Référence** : captures `Screenshot_20260525-000216_Forc2.jpg` / `000226` ; structure `Dep_mer.js` + `filtre_case_name.js`.

### Structure plateau (correction majeure)

| Élément | Placement |
|---------|-----------|
| **4 HQs** | coins `(23,23)` … `(257,257)` |
| **4 îles** 3×3 | quadrants entre HQ et centre (tuiles octogonales NW…SE teintées) |
| **4 Moons** | **milieu de chaque bordure extérieure** `(140,23)`, `(140,257)`, `(23,140)`, `(257,140)` — plus autour du Sun |
| **Sun** | centre `(140,140)` |
| **Space_1–4** | autour du Sun (croix intérieure) |
| **Space_5–12** | 2 par HQ sur les bordures (ex. `Space_5`/`12` gauche, `Space_6`/`7` haut) |

### Rendu

- **`board_composed.png`** — généré par `compose_board_from_tiles.py` (bandes grises bordures + croix + îles + mer)
- **`board_map.gd`** — affiche `board_composed.png` ; clics via `sector_layout.json`
- **`board_atlas.gd`** — îles = sprites `NW/N/NE/…` (plus un seul `CE` carré)
- **`extract_layout_from_board_atlas.py`** — layout + preview `board_reference.png`
- **`sea_corridor_test.gd`** — vérifie Moons sur bordures et Space près des HQs

### Pipeline

```powershell
cd Forces/godot
python tools/extract_layout_from_board_atlas.py
python tools/compose_board_from_tiles.py
.\tools\run_headless.ps1 -Mode smoke
```

**Commit** : `8d0b215` — `Carte Unity complete: iles, couloirs bordure, board_composed.`

---

## 2026-05-25 (suite) — Fix atlas : F/H inversés avec losange/carré

**Cause** : les noms dans `FORCE-AD-13a.png.meta` ne correspondent pas aux formes dans le PNG.

| Sprite | Contenu réel | Ancienne erreur |
|--------|----------------|-----------------|
| `_16` | losange contour | « carré » |
| `_18` | lettre **F** | `diamond_outline` → menu **FFRCES** |
| `_21` | losange plein | `square_filled` |
| `_23` | lettre **H** | `diamond_filled` → **H** sur croiseur / échanges |
| `_15` | carré contour | — |

**Corrections** : `parse_atlas_meta.py`, `verify_atlas_shapes.py`, `ui_atlas_test.gd`, `ui_piece_icons.gd` (boutons achat en HBox icône+coût), menu `diamond_filled`, suppression traits bleus `_draw_sea_bridges`, bouton `▶` unique.

---

## 2026-05-25 — Conformité Unity `Forces/Assets` (atlas, menu, couloirs mer)

**Source de vérité** : `Forces/Assets/` (`FORCE-AD-13a.png.meta`, `Dep_mer.js`, `filtre_case_name.js`, `GeneralMenu.js`).

### Menu F ◆ RCES

- **`logo_rotating_o.gd`** — même logique que `O_Animate` : rotation continue + rappel `rotation.z = 0` chaque seconde impaire ; **plus** de `PI/4` ni de crans 45° (évitaient un « H » / carré)
- Sprite : `diamond_outline` (`FORCE-AD-13a_18`), repli `diamond_filled` (`_23`)

### Atlas / UI (formes ≠ H)

- **`parse_atlas_meta.py`** régénère `atlas_sprites.json` depuis `Assets/Textures/FORCE-AD-13a.png.meta`
- Formes réserve (Unity `ContainsPlace`) : cercle `_14/_19`, carré `_16/_21`, triangle `_17/_22`, losange `_18/_23`, Power **F** `_15`, bombe **H** `_20` (`hbomb_h` / `hbomb`)
- Portraits plateau : `hunter` → `_27` ; `hbomb` plateau → `_20` (plus de doublon hunter/hbomb sur `_27`)

### Couloirs d’eau (capture 216)

- **`board_atlas.gd`** — `Space_5/8/10/12` → barres horizontales `_105`/`_108` ; `Space_6/7/9/11` → barres verticales `_83` (Unity `Sp*` ≠ losanges 70×70 `_106`)
- Teinte grise type `color_grey` ; tailles connecteurs 72×58 px
- **`sector_layout.json`** — positions centre depuis `calibrate_sector_layout.py` / `generate_sector_layout.py`

### Tests

- **`headless_test.gd`** — `AiStrengthTest` **désactivé** jusqu’à reprise étape IA
- Smoke : `SeaCorridorTest` + `GameRegression` + `FullMatchTest` → OK

```powershell
python tools\parse_atlas_meta.py
python tools\generate_sector_layout.py
.\tools\run_headless.ps1 -Mode smoke
```

---

## 2026-05-25 — Partie complète headless, fixes H / carte / play

**Commit** : `4c3694b` — `Fix H atlas, carte mer laterale, tests partie complete, timeout.`

### Bugs corrigés

- **« H » partout** — `atlas_sprites.json` : `hunter` → `_22` (triangle), `hbomb` → `_20` (plus `_27` partagé avec portrait chasseur) ; `ui_piece_icons.gd` n’utilise que les clés `circle_filled` / `square_filled` / `triangle_filled` / `diamond_filled` / `hbomb_h`
- **Menu « FHRCES »** — losange `diamond_outline` atlas (rotation par crans), plus le losange vectoriel / filled en H
- **Double ▶▶** — `PlayRoundButton` supprimé ; un seul `EndRoundButton`
- **Centre carte « éclaté »** — `generate_sector_layout.py` : croix `Space_1–4` autour du Sun, couloirs **latéraux** `Space_5/8` à x=74/206, `Space_12/10` en bas ; Moons écartées
- **Couloirs mer** — connecteurs H/V selon Space ; taille mer 62px ; `sector_layout.json` régénéré

### Gameplay

- **`GameState.apply_planning_timeout()`** — temps écoulé → tous camps éliminés, `GAME_OVER` ; `match_timer_seconds` pour tests
- **`battle.gd`** — vérifie `planning_time_limit()` chaque seconde de planification

### Tests

- **`scripts/tests/full_match_test.gd`** — invalides, achat/déploiement, combat égalité/capture, mer latérale, Power/échange, bombe H, capture QG, victoire, timeout, IA easy/normal/hard, simulation 12 manches
- **`headless_test.gd`** — `GameRegression` + `FullMatchTest`
- **`run_headless.ps1`** — mode `regression` (= smoke complet)

### Commande

```powershell
.\tools\run_headless.ps1 -Mode smoke
```

---

## 2026-05-25 04:35:57 — UI atlas, sidebar épurée, losange mécanique, warnings GDScript

**Commit** : `ae45e26` — `UI icônes atlas, sidebar sans doublons, losange mécanique, fix warnings.`

### Réalisé

- **`scripts/ui/ui_piece_icons.gd`** — boutons achat / échange / unités Case Info avec **textures FORCE-AD** (`circle_filled`, `square_filled`, etc.) ; plus de `● ■ ▲ ◆` Unicode en dur
- **`battle_sidebar.gd`** — doublons retirés : plus de `CaseHq`, `CaseStats`, `ReserveCounts`, `ReserveTitle` ; une ligne `CasePieceIcon` + chiffre portée ; échanges = 3 icônes + icône résultat
- **`battle.tscn`** — structure allégée (`CasePieceRow`, boutons achat = coût seul `2`/`3`/…)
- **`logo_rotating_o.gd`** — losange **`diamond_filled`** atlas ; rotation **par cran** 45° / 0,13 s + léger wobble (effet mécanique)
- **`game_constants.gd`** — autoload conservé ; méthodes utilitaires **sans `static`** → fin des `STATIC_CALLED_ON_INSTANCE`
- **Warnings** — retrait `const AiPlanner` / `const BoardAtlas` shadowing ; `board_scale` au lieu de `scale` ; `game_session` cast enum ; `board_graph` `_max_move` ; `ai_planner` variable `stats` inutile
- **Mer** — surbrillance `Space_*` alignée sur tuile (plus cercles 2,2× qui se superposaient)

### Fichiers

- `scripts/ui/ui_piece_icons.gd` (nouveau)
- `scripts/battle/battle_sidebar.gd`, `scenes/battle/battle.tscn`
- `scripts/menu/logo_rotating_o.gd`, `scenes/menu/main_menu.tscn`
- `scripts/core/game_constants.gd`, `project.godot`
- `scripts/battle/battle.gd`, `board_map.gd`, `ai/ai_planner.gd`, `app/game_session.gd`, `core/board_graph.gd`, `tests/game_regression.gd`

### Tests

- `run_headless.ps1 -Mode smoke` → OK
- `run_headless.ps1 -Mode compile` → OK

### À faire

- [ ] Pads ordres / journal résolution en symboles
- [ ] Affiner layout `Space_*` si couloirs encore trop superposés au centre

---

## 2026-05-25 04:10:46 — Couloirs mer visibles, UI épurée, menu nettoyé

**Commit** : `7607e7e` — `Afficher couloirs mer, symboles echanges, menu et surbrillances epures.`

### Problème utilisateur

- Couloirs d’eau **invisibles** → déplacements croiseur incompréhensibles
- Boutons échange encore `Cmd` / `Bmb` / `Ch` / `Dst`
- Menu : losange géant + `④` + texture O avec motif interne = « c’est quoi cette merde »
- Carte : carrés bleus empilés au centre à la sélection mer (surbrillance texture × N)

### Réalisé

- **`board_map.gd`** — tuiles `Space_*` (Sp1–Sp12, connecteurs H/V) **toujours dessinées** (plus masquées) ; teinte mer `Color(0.5, 0.7, 0.92)` ; surbrillance mer = **contour seule** (plus de empilement de textures semi-transparentes)
- **`board_atlas.gd`** — connecteurs mer agrandis (`long_side` 40 → 52) ; modulate mer aligné
- **`board_catalog.gd`** — pads courts symboles : `⚑` `☀` `◇{n}` (plus `HQ` / `Sp3`)
- **`battle.tscn`** — échanges `3●→◎` `3■→□` `3▲→△` `3◆→◇` ; ligne `ReserveOutline` dupliquée supprimée
- **`battle_sidebar.gd`** — une seule ligne compteurs réserve
- **Menu** — `BackdropDiamond` et sous-titre `④` supprimés ; `logo_rotating_o.gd` : losange **plat** (`plain_rhombus`) pour le O du titre (sans chevron atlas)

### Fichiers

- `scripts/battle/board_map.gd`
- `scripts/core/board_atlas.gd`
- `scripts/core/board_catalog.gd`
- `scenes/battle/battle.tscn`
- `scripts/battle/battle_sidebar.gd`
- `scenes/menu/main_menu.tscn`
- `scripts/menu/main_menu.gd`
- `scripts/menu/logo_rotating_o.gd`

### Tests

- `.\tools\run_headless.ps1 -Mode smoke` → OK

### À faire

- [ ] Réduire texte `%OrdersLog` / résolution
- [ ] Vérifier visuellement les 12 couloirs Sp entre quadrants (F5)

---

## 2026-05-25 04:01:45 — UI bataille symboles + tests non-régression headless

**Commit** : `25322fb` — `UI bataille en symboles et tests de non-régression headless.`

### Réalisé

- **Panneau Case Info** — titre `◎ {secteur}` ; QG `⚑` ; boutons unités `● 2` / `■ 1` (sans libellés Sold./Tank…) ; pièce active `● ▣2` / `◆` / `▲` selon domaine ; réserve `↓ ●`
- **Réserve** — en-tête `R` ; Power `P {n}  ☢{fusion}` ; déployer `↓` ; fusion H `☢100` ; achats `●2` `■3` `▲5` `◆10` ; échanges `3●→Cmd` etc. conservés
- **Ordres** — timer `R{n} ⏱{mm:ss}` ; file vide `—` ; hint long supprimé (`OrdersHint`) ; lecture `▶▶` (doublon MenuRow conservé)
- **Game over** — `★` + boutons `↻` `☰` ; texte explicatif retiré
- **`scripts/tests/game_regression.gd`** — graphes land/sea/air ; mouvement différé (secteur inchangé avant `apply_planning_orders`) ; max 5 ordres (6ᵉ refusé) ; double déplacement même pièce refusé ; portées tank > soldat, mer sans `Plains_NE`, air chasseur ; Power +1 sur territoire ennemi (`Ice_NW`) ; échange 3●→Cmd ; IA bleue ≥1 ordre
- **`scripts/headless_test.gd`** — appelle `GameRegression.run_all()` avant les checks existants (hbomb, scènes, etc.)

### Fichiers

- `scenes/battle/battle.tscn`
- `scripts/battle/battle_sidebar.gd`
- `scripts/tests/game_regression.gd` (nouveau)
- `scripts/headless_test.gd`

### Tests

- `.\tools\run_headless.ps1 -Mode smoke` → OK (2026-05-25 ~04:02)

### À faire

- [x] Symboliser les échanges (`3●→◎` etc., commit couloirs mer)
- [ ] Réduire texte dans `%OrdersLog` / résolution (pads encore en français)

---

## 2026-05-25 04:01:44 — Menu : logo F◆RCES rotatif, fond sans atlas parasite

**Commit** : `5bde35d` — `Menu: logo F◆RCES avec losange rotatif, fond épuré.`

### Réalisé

- **Titre FORCES** — `HBox` **F** (doré `#d2ad38`) + **losange** (`logo_rotating_o.gd`, atlas `diamond_outline`, 44 px, ~0,55 rad/s) + **RCES** (violet `#b885f2`) ; police menu 48 px inchangée
- **Arrière-plan** — `SplashTexture` (`FORCE-AD-13a` plein écran, opacité 0,18) **désactivé** : fin du texte parasite NW / Sp1 / HQ / Res visible derrière le panneau
- **`BackdropDiamond`** — losange géant (220 px, rotation 0,22 rad/s, modulate ~0,14) centré écran, `mouse_filter` ignore
- **Sous-titre** — `④` à la place de « Conquête stratégique — 4 camps »
- **Boutons menu** — Jouer / Partie rapide / Tutoriel / Options / Quitter : texte français conservé (choix volontaire menu)

### Fichiers

- `scenes/menu/main_menu.tscn`
- `scripts/menu/main_menu.gd`
- `scripts/menu/logo_rotating_o.gd` (nouveau)

### Tests

- Compilation scène : `run_headless.ps1 -Mode compile` (non relancé ; smoke inclut `main_menu.tscn`)

---

## 2026-05-25 03:45:56 — Surbrillances mer alignées couloirs Space

**Commit** : `0e584b3` — `Corriger surbrillances mer (losanges) alignees sur les couloirs Space.`

### Réalisé

- Rectangles surbrillance mer recalés sur `sector_layout.json` / couloirs `Space_*` (plus de losanges décalés sur la carte)

---

## 2026-05-25 22:00:00 — Ordres secrets, centre plateau, UI Case Info (réf. captures 216/221/231)

### Réalisé

- **Centre « éclaté » corrigé** — couloirs `Space_*` sans tuile dessinée (zones cliquables conservées) ; Sun + 4 Moons repositionnés ; `sector_layout.json` régénéré
- **Ordres simultanés** — déplacements / déploiements / bombe H appliqués à la **lecture** (`▶▶` / Lecture), pas pendant la planification ; fantômes verts = destinations prévues
- **Surbrillance sol** — rectangles sur les cases (plus les grands cercles jaunes)
- **Case Info** — boutons ● ■ ▲ ◆ par type (comme capture 221) ; clic unité → portée affichée
- **Portées terre Unity** — `unity_land_nbmove` (soldat/commando 2, tank/bombardier 3) via `Dep_terre`
- **Power territoire** — +1 Power si présence sur grille ennemie en fin de manche (sans combat bloquant)

### À faire

- [ ] Connecteurs mer visibles entre quadrants (style 216)
- [ ] Animations déplacement à la révélation

---

## 2026-05-25 18:00:00 — Port solo v1 (jouable de bout en bout)

### Réalisé

- **Écran victoire** — overlay Rejouer / Menu quand un seul camp survit
- **Résolution visuelle** — flash orange sur les cases en conflit avant résolution des combats
- **Réserve au QG** — cycle pièce inclut la réserve ; clic QG ou bouton Déployer
- **Journal d’ordres** — chaque action humaine loggée en pad dans `%OrdersLog`
- **`GameSettings`** — persistance `user://forces_settings.cfg` (musique / SFX)
- **IA** — déploiement depuis la réserve (normal+)
- **`README.md`** — tableau de statut v1

### Hors scope v1 (volontaire)

- Multijoueur réseau
- Monétisation / publicité (**uniquement sur demande utilisateur**)
- Tuiles directionnelles emboîtées type Unity (le CE générique suffit pour jouer)
- `Battleground.unity` absent — calibration pixel-perfect reportée

---

## 2026-05-25 12:00:00 — Plateau tuiles atlas, grilles ancrées QG, sidebar

### Réalisé

- **`board_map.gd`** — rendu **tuile par tuile** depuis l’atlas (plus de PNG composé au runtime) ; couches mer → terrain → centre → QG ; teintes camps renforcées ; badge pièces sur QG
- **`board_atlas.gd`** — `tile_shapes` (NW…SE, Sp1–Sp12, HQ, CE), `sector_tile_modulate()`, octogone CE pour tout le terrain
- **`sector_layout.json`** — grille 280×280 ; QG aux coins symétriques **(18,18) / (262,18) / (18,262) / (262,262)** ; grilles 3×3 **ancrées sur le QG** de chaque quadrant (NW/NE/SW/SE)
- **`generate_sector_layout.py`** — régénération géométrique (remplace calibration peaks sur PNG noir)
- **`parse_atlas_meta.py`** — mapping `tile_shapes` ContainsPlace Unity
- **`battle_sidebar.gd`** + **`battle.tscn`** — Case Info / Reserve / Orders+timer ; sélection QG au démarrage
- **`export_board_image.py`**, **`calibrate_sector_layout.py`** — outils référence (PNG composé optionnel)
- **`assets/textures/board_reference.png`** — preview export 4 quadrants

### Réalisé (suite)

- **Connecteurs mer** — `Space_*` rendus (Sp + `connector_h`/`connector_v`), tailles selon aspect atlas, positions couloirs entre quadrants

### Réalisé (suite)

- **File d’ordres** — `%OrdersQueue` dans la sidebar (pad `O : HQ > CE`, compteur 0/5), journal `%OrdersLog` pour événements de manche

### Réalisé (suite)

- **Déplacements mer/air** — sélection pièce par reclic sur la case (cycle soldat/tank/chasseur/croiseur), surbrillance bleue mer / jaune air, tests smoke croiseur QG→`Space_5`

### Réalisé (suite)

- **Bombes H** — fusion 100 F (réserve + pièces sur la case + Power), placement sur case, frappe (toutes pièces du secteur détruites), pad `H : HQ > CE`
- **Combats** — vainqueur doit dépasser la 2ᵉ force ; égalité = pas de capture ; HBOMB ignorée dans les totaux de combat

### Réalisé (suite)

- **IA** — destinations via `destinations_for`, bonus mer/air, achats réserve (normal+), fusion H (difficile)
- **Tutoriel** — pages mer/air, combats, bombe H, Power

### À faire (améliorations futures)

- [ ] Tuiles directionnelles emboîtées (échelle Unity) si souhaité
- [ ] `Battleground.unity` pour calibration pixel-perfect
- [ ] Animations déplacement pièces ; multijoueur

---

## 2026-05-25 00:15:00 — Bataille fidèle : calibration, sprites, timer, ordres

### Réalisé

- **`calibrate_sector_layout.py`** — positions secteurs extraites du diagramme `FORCE-AD-13a_13` (57 cases)
- **`board_atlas.gd`** — icônes pièces/UI depuis atlas (`piece_icons` dans `atlas_sprites.json`)
- **`board_map.gd`** — pièces en sprites atlas teintés camp, surbrillance destinations, sélection pointillée
- **`battle_sidebar.gd`** — timer 59:59 (logique Unity), pad ordres `O : HQ > CE`
- **`board_catalog.gd`** — libellés courts secteurs (HQ, CE, NW, Sp3…)
- **`battle.gd`** — timer planification, file d'ordres, clic case → destination

### À faire

- [ ] Récupérer `Battleground.unity` pour calibration pixel-perfect finale
- [ ] Sprites connecteurs mer entre cases
- [ ] Animations fin de manche / combat

---

## 2026-05-24 23:48:00 — Plateau graphique fidèle (atlas FORCE-AD-13a)

### Réalisé

- **`board_atlas.gd`** + **`parse_atlas_meta.py`** — 87 sprites extraits du `.meta` Unity, tuiles HQ/terre/mer
- **`board_map.gd`** refondu — fond diagramme Unity (`FORCE-AD-13a_13`), tuiles atlas teintées par camp, anneau de sélection, pastilles pièces, badges V×2 B×1…
- **`atlas_sprites.json`** — régions atlas en coords Godot
- Panneau carte agrandi (520×380)

### À faire (plateau)

- [ ] Calibrer positions secteurs sur le diagramme (Battleground.unity manquant)
- [ ] Connecteurs 210×70 entre cases, sprites pièces depuis atlas
- [ ] Animations déplacement / combat

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
