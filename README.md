# RE:(do)(start)(call)

A turn-based grid roguelike demo built in **Godot 3.6**.
Made by **Jaime Gonzaga** for Game Math, BSCS-2C.

Three battles, six random events, twelve pieces of gear. The enemy shows you its
whole attack in a single flash — then the board goes clean. Remember it, or get hit.

---

## How to run

1. Install **Godot 3.6** (any 3.x release works — this is *not* a Godot 4 project).
2. Open `project.godot` in the Godot editor.
3. Press **F5**.

No assets to import and no plugins to enable.

- **Font** — if `res://fonts/PressStart2P-Regular.ttf` exists it is used automatically.
  If it's missing the game falls back to Godot's built-in font and still runs.
- **Sound** — every sound effect is synthesised in code at runtime (`Sfx.gd`).
  There are no audio files. Mute with **M** or the SOUND button in the battle panel.
- Window size is **960 × 640**.

---

## Controls

| Action | Mouse | Keyboard |
|---|---|---|
| Move / aim | click a highlighted tile | **WASD** or **arrows**, then **SPACE** |
| Confirm | left click | **SPACE** / **ENTER** |
| Step back / undo move | right click | **ESC** / **BACKSPACE** |
| Pick a toy | click its row | **1 – 4** |
| Stay put (end round, no attack) | click STAY PUT | **0** or **Q** |
| Field guide (pauses the fight) | click **?** | **H** |
| Mute / unmute | click SOUND | **M** |
| Restart the run | — | **R** |
| Skip the boss intro | click | **SPACE** / **ESC** |

Standing on your own tile and confirming counts as staying put during MOVE.

---

## How a round works

Every round runs in the same four beats:

1. **FLASH** — the enemy reveals its entire plan for a moment. Red tiles, orange
   tiles, done. **Nothing stays coloured afterwards.** This is the memory game.
2. **MOVE** — walk up to your step limit (green tiles). You may also stay still.
3. **FIGHT → AIM** — choose one toy and aim it.
4. **RESOLVE** — the enemy slides, your toy lands, the enemy's blast lands, then the
   floor ticks.

**Your toy hits *after* the enemy moves.** Aim at where it will end up, not where it
is standing when the flash goes off.

---

## Reading the flash

| Colour | Meaning |
|---|---|
| **RED X** | The slide path. End your move on it and you are **crushed — instant KO**. |
| **ORANGE** | The blast. Costs HP, never your whole life. A glyph marks the pattern's centre. |
| **GOLD +** | Bullseye marker on *your* attack preview. Hit the enemy exactly there for bonus damage. |

Blast glyphs: `!` charge · `*` spin · `o` drip · `~` acid fan · `#` splat / shatter ·
`O` goo bloom · `+` cross / surge · `-` sagging (a free turn).

The enemy never marks so much of the board that you have nowhere to go — a share of
your reachable tiles is always left safe.

---

## Your toys

| Toy | Damage | Shape | Leaves | Shots | Reload |
|---|---|---|---|---|---|
| **NERF BLASTER** | 8 | line, 6 tiles | foam (slows) | 3 | 2 rounds |
| **BASEBALL** | 14 | lob 2–5 tiles, plus-shaped splash | — | 2 | 3 rounds |
| **LIGHTSABER** | 20 | thrust, 3 wide × 4 long | burn | 2 | 5 rounds |
| **JUICE BOX** | heal 25 | self | — | 1 per battle | — |

### Shots and reloading
The small **pips** under each toy are its remaining shots. Spend the last one and that
toy goes into a long reload — the number on the right of the row is how many rounds
are left. You cannot spam everything; spread your damage across the fight.

When every toy is empty, **STAY PUT** lights up. End the round and let them come back.

### Bullseye
The gold crosshair sits on the exact middle of your hitbox. Land the enemy there for
**×1.5** damage (**×2.0** with the Lucky Marble).

- **Blaster** — the first tile of the line (point blank)
- **Baseball** — the dead centre of the plus
- **Lightsaber** — the middle of the centre lane (tiles 2–3 of the thrust)

When a hit is modified, the damage popup shows the breakdown underneath the total:
`BASE 20`, `TAPE +5`, `FIX +8`, `BULLSEYE x1.5`, `PLUSH -4`.

---

## The floor

Effects last a couple of rounds and tick at the end of every round.

| Effect | What it does |
|---|---|
| **RUST** (Pipe trail) | 4 damage if you end the round on it |
| **GLASS** (Bulb trail / shatter) | 4 damage |
| **ACID** (Hanger patterns) | 4 damage **and** slows you |
| **BURN** (Lightsaber) | 5 damage to whoever stands on it — including the enemy |
| **FOAM** (Blaster) | slows you to 1 tile — and shortens enemy slides to 1 tile |
| **GOO** (Hanger trail / drip) | slows you to 1 tile, no damage |

Foam is your control tool: a slowed enemy can barely move. Acid and glass are the
reason you keep walking even when the blast misses.

---

## The three battles

### 1 — THE RUSTED PIPE · 100 HP · hits 10–22
A hunter. It builds every attack it could make and scores them by how much of your
next move they cover — including the tile you're on and the direction you walked
last time. It slides up to 3 tiles, then swings.

- **RUST CHARGE** `!` — a long line past its slide
- **SPIN SWEEP** `*` — every tile around where it lands

Below half HP it **ENRAGES**: longer slides and a star-shaped sweep.

### 2 — THE MELTED HANGER · 120 HP · hits 13–24
Slides in all eight directions, diagonals included. This is the status-effect fight:
it floods the floor and the mess outlasts the hit.

- **DRIP RAIN** `o` — scattered goo across the board
- **ACID FAN** `~` — three wide lanes of burning metal
- **MELT SPLAT** `#` — a big acid diamond where you were standing
- **GOO BLOOM** `O` — a ring of sticky metal around it
- **CROSS RAIN** `+` — your entire row and column

After a MELT SPLAT it sags and rests for a round — a free turn if you take it.
Below half HP it **MELTS DOWN** and uses two patterns at once.

### 3 — THE CRUSHED LIGHTBULB · 170 HP · hits 16–28
A short cinematic plays first (skippable). Then:

**It dashes twice, and both paths are lethal.**

- **Crimson, one dot** — the first dash
- **Violet, two dots** — the second dash, re-aimed at you from where the first stopped

The second path appears a beat after the first so you can read the order.
**The blast lands where the second dash ends — that is where you aim.**

- **SHATTER** `#` — a 3×3 burst that leaves glass shards behind
- **SURGE** `+` — a cross of light, 2 tiles in every direction

Below half HP it **OVERLOADS**: both dashes get longer, the surge widens, the shatter
grows spikes. Foam darts still slow it to 1 tile per dash.

---

## Between battles

You get one random event after battle 1 and another after battle 2. They are drawn
from a shuffled bag, so you never see the same event twice in one run and the order
changes every run.

| Event | Your options |
|---|---|
| **TOY CHEST** | Open it (25% chance of a −12 HP trap, you still get the toy) or walk past |
| **ICE CREAM MAN** | Buy gear with coins; ice cream is 1 coin for 30 HP |
| **TWO DOORS** | Quiet door: safe +25 HP. Buzzing door: 50% free gear / 50% −20 HP trap |
| **VENDING MACHINE** | Free soda +22 HP · pay 15 HP for gear · kick the glass for even odds |
| **LOST & FOUND** | +30 HP · +10 max HP permanently · +3 coins |
| **NIGHTLIGHT SHRINE** | Trade 15 max HP for gear · warm your hands for +15 HP · back away |

You earn **3 coins** per battle won, plus 1 more with the Scavenger Pin.
Health, max health, coins and gear all carry forward between battles.

---

## Gear

Twelve modifiers. Offers are always things you don't already own.

| Gear | Cost | Effect |
|---|---|---|
| **DUCT TAPE** | 2 | +5 damage on every hit |
| **SPARE MAGAZINE** | 3 | +1 shot per toy, reloads finish 1 round sooner |
| **JUMBO LUNCHBOX** | 2 | +20 max health (and heals 20 now) |
| **LIGHT-UP SNEAKERS** | 2 | +1 tile of movement every round |
| **FOAM ARMOR** | 2 | Blocks the first hit of each battle |
| **ECHO STICKER** | 3 | Your last attack repeats next round at half damage |
| **FIXATION** | 2 | +4 damage per consecutive hit, up to +16. Missing resets it |
| **RIPPLE CAP** | 2 | Foam and burn spread to tiles beside your attack |
| **COMFORT OBJECT** | 2 | Heal 6 at the end of any round you took no damage |
| **LUCKY MARBLE** | 3 | Bullseyes go from ×1.5 to ×2.0 |
| **PLUSH GUARD** | 2 | Take 4 less damage from every hit |
| **SCAVENGER PIN** | 1 | +1 coin per battle won |

Owned gear shows as coloured badges at the bottom of the battle panel.
**Hover a badge to read it.** A dimmed badge is spent (Foam Armor used, Echo not armed).
Badges flash when their effect fires.

---

## The battle panel

Kept deliberately quiet so the board can be loud.

- **ROUND** counter, **SOUND** toggle, **?** field guide
- Enemy card — name and health bar (the name turns red when it enrages)
- Your card — health bar
- A status chip only when you're standing on something (RUST / GLASS / ACID / BURN / SLOWED)
- Four toy rows — name, damage, shot pips
- **STAY PUT** strip
- **GEAR** badges

---

## Project files

    project.godot
    scripts/Main.gd             screen flow, run state, event bag, sound bank
    scripts/BattleScreen.gd     combat, telegraphs, all attack animations
    scripts/EncounterScreen.gd  the six between-battle events
    scripts/Mods.gd             the twelve modifiers
    scripts/Constants.gd        shared tuning numbers and palette
    scripts/Style.gd            pixel font and UI theme
    scripts/Sfx.gd              procedural sound effects (no audio files)
    scripts/EventScreen.gd      legacy entry point, forwards to EncounterScreen
    fonts/                      optional pixel font

`BattleScreen.gd` defines its own enemy and effect tuning locally, so it does not
depend on a particular version of `Constants.gd`.

---

## Demo and testing switches

| Switch | File | What it does |
|---|---|---|
| `DEBUG_START_STAGE` | `Main.gd` | Set to `2` or `3` to jump straight to that battle |
| `BULB_CUTSCENE` | `BattleScreen.gd` | Set to `false` to skip the boss intro |
| `DEBUG_BUTTONS` | `Constants.gd` | Set to `true` for a WIN shortcut on the battle panel |
| `FORCE_ENCOUNTER` | `Constants.gd` | Force one event: `"chest"`, `"shop"`, `"doors"`, `"vending"`, `"lostfound"`, `"shrine"` |

All are off / neutral by default.

---

## Troubleshooting

**The battle screen is blank or shows an error panel.**
A script failed to compile. `Main.gd` catches this and prints which file broke instead
of leaving a black screen — read the panel, then check Godot's **Output** dock for the
parse error and line number.

**Everything is a grey box.**
The theme failed to build. In Godot 3 the `Theme` setters take
`(value, name, type)` — for example `set_stylebox(stylebox, "normal", "Button")`.
`Style.gd` already uses that order; don't swap the arguments.

**The font looks wrong.**
`res://fonts/PressStart2P-Regular.ttf` is missing. Drop it in, or ignore it — the game
falls back to Godot's default font and plays identically.

**Nothing opens in Godot 4.**
This project uses the Godot 3 API (`DynamicFont`, `StyleBoxFlat.anti_aliasing`,
`AudioStreamSample`, `rand_range`). Use Godot 3.6.
