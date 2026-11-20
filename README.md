# RE:(do)(start)(call)

A turn-based grid roguelike demo built in Godot 3.6.
Made by Jaime Gonzaga for Game Math, BSCS-2C.

## How to run
1. Install Godot 3.6.
2. Open `project.godot` in Godot and press F5.

## How to play
- Each round starts with a split-second flash showing the enemy's attack. Memorize it.
- RED X tiles = the enemy slides there (touching it means instant KO).
- ORANGE ! tiles = damage.
- Then move, and attack with a toy: Nerf Blaster, Baseball Throw or Lightsaber Thrust.
- Controls: mouse, or WASD + SPACE, ESC to go back, 1-5 to pick a toy.

## Demo content
- Battle 1: the Rusted Pipe
- A random event: toy chest, ice cream shop, or two doors
- Battle 2: the Melted Hanger (moves in 8 directions, random attack patterns)
- 8 modifiers to find, such as Foam Armor, Echo and Static Trade

## Project files
- `scripts/BattleScreen.gd`: combat
- `scripts/EncounterScreen.gd`: chest, shop and doors
- `scripts/Mods.gd`: modifiers
- `scripts/Constants.gd`: all tuning numbers
