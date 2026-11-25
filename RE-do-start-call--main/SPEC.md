Part 1: Final design (demo)

Title: RE:(do)(start)(call)
Board: one shared 6x6 grid. Player and enemy both move on it.
Health: player 100 HP, enemy hits deal 10 to 25. Enemies have HP, so fights stay at 4 to 6 rounds.
Round order (fixed):
Telegraph: danger tiles flash about 0.4 seconds, then hide.
You move up to 2 orthogonal tiles, then pick an attack, item, or wait.
The enemy moves by its rule.
Your attack lands, then the enemy strike lands.
Tile effects tick (they last 2 to 3 rounds).
Check win or lose.
Attacks: Jab (1 tile), Sweep (3-tile line, leaves slow), Burst (plus shape, leaves burn, can hurt you). Numbers are placeholders to tune.
Tile effects: rust (damage over time), slow (1 tile of movement for 1 round), burn.
Enemies:
Rusted Pipe: straight-line moves, leaves rust.
Melted Hanger: diagonal moves, leaves slow drips.
Hallway Light: moves in phases, chains two attacks at half health.
Modifiers (pick 1 of 3, three times): Fixation, Bullseye, Echo, Ripple, Safe Haven, Flinch, Extra Step, Static Trade.
Flow: Intro, Lore, Battle Ready (how-to plus first pick), Battle 1, pick, Battle 2, pick, Mini Boss, Win screen, plus Game Over and a restart button.
Cut for now: rewind, meta-progression, shop, chests, confusion, knockback.