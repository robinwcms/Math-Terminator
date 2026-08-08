# Math Terminator

A top-down math-shooter where you solve arithmetic problems to kill zombies before they reach you. Built in GameMaker Studio 2. Every zombie carries a math question above its head — click the correct answer to mark it, then shoot it to kill it. Wrong answers accelerate every zombie on the field and lock your input for 3 seconds. Get better at math or get bit.

## Elevator pitch

You're the last soldier alive in a zombie outbreak, armed with a pistol and a working knowledge of arithmetic. Each zombie displays a math problem and four answer choices as floating boxes above its head. Solve the problem by clicking the right answer, then finish the kill with a well-placed shot. Do it fast — zombies keep coming, and the math gets harder as you improve.

## Gameplay

### Core loop
- **Movement**: WASD to move, mouse to aim, left-click to shoot
- **Solve**: Click the correct answer box above a zombie's head to MARK it (green flash)
- **Shoot**: Fire at the marked zombie to complete the kill
- **Repeat**: Waves get harder, math gets harder, new zombie types appear

### Zombie types
Each type has a distinct color and special ability:

- **Tan/Orange/Red normals** — 1/2/3 HP zombies. Higher HP = darker red tint. Chip them down with correct answers.
- **Bright yellow Runners** — 2× player speed, unlocked wave 3. If you see yellow, stop what you're doing and deal with it.
- **Bright red Exploders** — 1 HP but deal 1 damage in a 220px AOE on death. Chain-explodes other zombies in range. Unlocked wave 5.
- **Violet Splitters** — 1 HP. On death, spawns 2 smaller 1-HP zombies. Unlocked wave 6.
- **Mint green Healers** — 1 HP, slow. Every 4 seconds heals 1 HP on a damaged nearby zombie. Kill these first. Unlocked wave 8.
- **Marked zombies (any type)** — Universal green flash means "ready to kill." Shoot them.
- **Wave 10 BOSS** — 12 HP, 3 phases (purple → orange → red rage), 140px giant with massive fists. Manual collision, custom AI. Drops 5 powerups + 5000 score + achievement on defeat.

### Modes

- **Unlimited Mode** — Endless waves with shop intermissions after clearing waves 5, 15, 25, 35... Survive as long as you can.
- **Timed Mode** — Pick a duration (30s / 1min / 3min / 5min). Get the highest score before time runs out. Each duration has its own leaderboard.
- **Tutorial** — 11 interactive lessons in the real arena. Guided practice for every mechanic.
- **Daily Challenge** — A new modifier each day (No Powerups / Double Speed / Algebra Only / Half Hearts / Glass Cannon) applied over unlimited mode.

### Economy & Shop

Kill zombies to earn credits from dropped coins (silver 50, gold 75, diamond 100). Coins auto-magnet to you within 350px. Every 10 waves, a shop appears with 13 items across three tiers:

**Cheap (150-200cr)**: Sniper Scope, Extra Heart, Shield, Double Points, Speed Boost, Freeze
**Mid (300-500cr)**: Decoy, Turret, Airstrike, Rapid Fire
**Expensive (750-1000cr)**: Sanctuary, Mobile Shop, Beacon

### Gadgets

Purchased gadgets go into your inventory. Press **E** in-game to open the inventory popup; click any item to use it. There are 13 gadgets total:

| Gadget | Effect |
|--------|--------|
| Extra Heart | +1 HP instantly |
| Shield | 8 seconds of damage immunity |
| Sniper Scope | Zoom-out camera + piercing bullets (press "1" to toggle mid-use) |
| Double Points | 2× score for this wave |
| Rapid Fire | 3 seconds of instakill rampage — shoot anything to kill it |
| Speed Boost | 6 seconds of extra movement speed |
| Freeze | 5 seconds of zombie slowdown |
| Airstrike | Solve 3 math problems, then pan a crosshair and wipe a 400px area |
| Decoy | Lures every zombie to a fake target for 8 seconds |
| Beacon | Highlights the correct answer weakspot on every zombie in a 560px radius for 15 seconds |
| Sanctuary | Physically repels zombies from a 560px protected zone for 12 seconds |
| Turret | Auto-fires at nearest zombie every second for 10 seconds |
| Mobile Shop | Opens the shop instantly, mid-wave |

## Systems worth mentioning

### Adaptive difficulty
The game auto-tunes math difficulty to the player's running accuracy. Six lines of code in `obj_enemy/Create_0.gml` implement a closed-loop control system: every zombie spawn checks the player's running accuracy, and if it's above 90% the difficulty ticks up; below 60% and it ticks down. Sweet-spot dead zone between 60-90% means the game only intervenes when the player is either dominating or drowning. Difficulty ranges from level 0 (addition only) to level 5 (square roots and algebra).

### Combo system
Consecutive correct answers within a 4-second window build a combo multiplier: `score = base × (1 + (combo - 1) × 0.5)`. A 10x combo means 5.5× score. One mistake or timeout resets the combo — the system rewards consistency over peak performance.

### Wrong-answer punishment
Clicking a wrong weakspot triggers a 3-second input lockout AND boosts every zombie on the field by +1.6 speed for several seconds. Errors don't just waste a click; they change the threat landscape.

### Zombie physics
Every zombie runs a per-frame path-follow + obstacle repulsion + zombie-zombie repulsion system in `obj_enemy/Step_0.gml`. Uses inverse-linear-distance falloff to push zombies away from walls and each other, producing organic crowd-flow behavior. Runners are exempt from the normal 2.75 speed cap so they can outpace the player at 5.6.

### Damage vignette
When the player takes damage, a red radial gradient pulses on the screen edges. Implemented in pure CPU rendering (no shaders) via 80 nested concentric rectangle "rings" with quadratic-power alpha falloff, plus a warm-tint second pass that bleeds further toward center. About 60 lines in `obj_game_manager/Draw_64.gml`.

### Boss collision
The boss's 140px body is too big for GameMaker's sprite-mask collision system, so we bypass it entirely. Bullet-vs-boss uses manual `point_distance` checks in `obj_projectile/Step_0.gml`; boss-vs-obstacles and boss-vs-zombies use per-frame pushout math in `obj_boss/Step_0.gml`. Three independent collision passes, all hand-rolled.

### Sniper zoom
Activating the sniper scope smoothly lerps the camera's view size from 1.0× to 1.5× over ~10 frames, with a snap-to-target threshold to avoid sub-pixel drift near the end. Press "1" while sniper is active to toggle between zoomed and normal without losing the wave-scoped power-up. Uses freshly-computed view width for camera centering to avoid GameMaker's one-frame propagation delay.

## Persistent progression

- **Achievements** — 13 total, ranging from "First Blood" (kill 1 zombie) to "Wave Master" (reach wave 50). Saved to `achievements.sav`.
- **High scores** — Separate leaderboards per mode: unlimited, timed-30s, timed-1min, timed-3min, timed-5min. Each stored as its own `.sav` file.
- **Recent games** — Last 20 runs saved with full stats (mode, score, wave, kills, accuracy, duration). Viewable from the main menu.
- **Daily completions** — Each day's challenge is tracked once completed.
- **Loadout picks** — Pick 3 starting gadgets that spawn in your inventory at run start.

All saves use JSON serialization written synchronously on state changes, so a crash never loses progress up to the last event.

## Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| Mouse | Aim |
| Left click | Fire / Click answer choices |
| E | Open inventory popup |
| 1 | Toggle sniper zoom (while sniper is active) |
| Space | Confirm dialogs |
| F11 | Toggle fullscreen |
| P (lowercase) | [Admin] Kill all zombies on screen |
| U (lowercase) | [Admin] Reset all achievements |

## Technical notes

**Engine**: GameMaker Studio 2, LTS version
**Language**: GML (GameMaker Language)
**Target**: Windows desktop, fullscreen 1920×1080 base with dynamic view scaling
**Arena size**: 4096×4096 world pixels
**Framerate**: 60 fps target, delta-time compensated where relevant

### Codebase organization

```
objects/
  obj_game_manager/     # Persistent state, waves, stats, achievements, music
  obj_player/           # Movement, aiming, inventory access
  obj_enemy/            # All zombie types (behavior driven by type flags)
  obj_enemy_spawner/    # Consumes wave queues, applies type stats
  obj_boss/             # Wave 10 boss (manual collision + AI)
  obj_projectile/       # Bullets (with boss/enemy collision handlers)
  obj_weakspot/         # Clickable answer choices
  obj_shop/             # 4-col scrollable shop grid
  obj_inventory_popup/  # E-key gadget menu
  obj_airstrike/        # Multi-phase pause + target + AOE
  obj_decoy/            # Retargets zombies for 8s
  obj_beacon/           # Highlights correct answer in radius
  obj_sanctuary/        # Repels zombies from radius
  obj_turret/           # Auto-fires at zombies
  obj_splash_manager/   # Main menu, panels, achievements, loadout
  obj_main_menu_ui/     # Main menu buttons + timed submenu
  obj_menu_background/  # Animated menu backdrop
  obj_tutorial_overlay/ # 11-step tutorial state machine
  obj_score_popup/      # Floating text ("-1", "+100", "BOOM!", etc.)
  obj_coin/             # Silver/gold/diamond pickups with magnet
  obj_powerup/          # Drop-on-kill pickups
  ...
```

### Wave structure

Waves 1-2 are all 1-HP tan zombies for onboarding. Wave 3 introduces the first runner and 2-HP orange zombies. Wave 4 adds 3-HP dark-red zombies. Wave 5 unlocks exploders and triggers the first shop. Wave 6 unlocks splitters. Wave 8 unlocks healers. Wave 10 is a BOSS FIGHT — no other zombies spawn, just the giant. Wave 11+ ramps up special-type counts (2 runners, 2 exploders). Every wave count = wave × 3 + 3 zombies.

### The `pending_hp_queue` and `pending_type_queue` invariant

Wave generation builds two parallel arrays: one of HP integers, one of type strings. They're shuffled together in-place with a Fisher-Yates pass that uses the *same* random index for both swaps, preserving the HP-type pairing through randomization. If they desynced you'd get 3-HP runners and 1-HP splitters that never split. The spawner consumes both queues in lockstep, one entry per zombie spawned.

### Persistence pattern

There's no central save manager. Each system writes its own save file synchronously the moment its state changes. Achievements save on unlock. Scores save on run end. Daily completions save on qualifying. This makes save format changes trivial (add a field with a `variable_struct_exists` fallback) and crash-safety guaranteed (no in-memory buffer to lose).

## Design philosophy

The whole project is built around one idea: **the game should feel good without anyone being able to articulate why**. Every system has an invisible layer that improves feel without the player noticing:

- Adaptive difficulty adjusts silently — players don't know their math is being tuned to them
- The dead zone (60-90% accuracy) means the system stays passive most of the time
- Wrong-answer speed boost is visible in effect but the *reason* takes a moment to figure out
- Combo multiplier rewards steady play — players learn this by feel, not from tooltips
- Healers, exploders, and splitters teach kill-priority without any text ever explaining it
- The damage vignette communicates "you were hit" faster than a HP number could

Every choice — the 4-second combo window, the ±80px spawn offset, the widened sniper snap threshold, the 3-frame beacon timer, the input lockout after airstrike — is a small piece of "invisible polish" that individually goes unnoticed but collectively makes the game feel tight.

## Credits & assets

Built on the GameMaker "Twin Stick Shooter" template with substantial reworks. Custom sprite work for title, buttons, and gadgets. Music tracks from the template plus additional menu track. Sound effects from template with a few custom voice recordings added for damage feedback and button clicks. Font: Luckiest Guy.

## Build & run

Open `shooter template.yyp` in GameMaker Studio 2 (LTS or newer). Press F5 to run. All dependencies are included in the project.

---

*Math Terminator. Solve or die.*
