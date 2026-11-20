extends Reference

# Every tuning number and color lives here.

const GRID = 7
const TILE = 72
const GRID_OFFSET = Vector2(40, 68)
const PANEL_X = 600
const SCREEN_W = 960
const SCREEN_H = 640

# ---- Player ----
const PLAYER_HP = 100
const PLAYER_MOVE = 3          # tiles you can walk per round
const SLOWED_MOVE = 1          # tiles you can walk while standing on a slow tile

# ---- Enemy: Rusted Pipe ----
const ENEMY_HP = 100
const LUNGE_LEN = 3            # tiles the Pipe slides each round (touching you = instant KO)
const SLOWED_LUNGE = 1         # lunge length while the enemy stands on a slow tile
const SWING_LEN = 3            # extra tiles past the lunge that take a swing hit
const ENEMY_HIT_MIN = 10       # swing damage
const ENEMY_HIT_MAX = 25
const TELEGRAPH_TIME = 0.5     # seconds the attack flashes at the start of every round

# ---- Rusted Pipe AI + its two attacks ----
# RUST CHARGE: slides up to LUNGE_LEN tiles, then swings a line SWING_LEN long.
# SPIN SWEEP:  slides up to PIPE_SWEEP_LUNGE tiles, then hits every tile around where it lands.
const PIPE_SWEEP_LUNGE = 2
const PIPE_ENRAGE_LUNGE = 1    # extra slide tiles under half HP (its spin also becomes a star)
const SWEEP_DMG_MULT = 0.8     # the spin covers a lot of floor, so it hits a bit softer
const PIPE_SAFE_FRAC = 0.35    # fairness: at least this share of your reachable tiles stay unmarked
const PIPE_MIN_SAFE = 2        # ...and never fewer than this many

# ---- Bullseye (crit) ----
const CRIT_MULT = 1.5          # enemy standing on the exact middle of your attack
const BULLSEYE_COL = Color(1.0, 0.82, 0.2)

# ---- Enemy: Melted Hanger (battle 2) ----
const HANGER_HP = 120
const HANGER_LUNGE = 2         # tiles it slides each round, in ANY of 8 directions (touching you = KO)
const HANGER_SWING_LEN = 4     # length of its diagonal/straight slash past the lunge
const HANGER_HIT_MIN = 15      # harder than the Pipe
const HANGER_HIT_MAX = 30
const HANGER_TELEGRAPH = 0.8   # longer flash: its patterns are random and spread out
const DRIP_COUNT = 7           # scattered drip tiles (+2 when it melts down below half HP)

# ---- Enemy: Crushed Lightbulb (battle 3, final boss) ----
# It DASHES TWICE every round (two lethal red X lines, one after the other),
# then blows out the floor where it stops.
const BULB_HP = 180
const BULB_LUNGE_1 = 2         # first dash length
const BULB_LUNGE_2 = 2         # second dash length (re-aims at you from where dash 1 stopped)
const BULB_ENRAGE_LUNGE = 1    # +1 to BOTH dashes below half HP
const BULB_LEG_PAUSE = 0.42    # the beat between the two dashes
const BULB_HIT_MIN = 18
const BULB_HIT_MAX = 32
const BULB_TELEGRAPH = 1.1     # longest flash in the game: there is a lot to remember
const BULB_SHATTER_R = 1       # SHATTER: 3x3 blast of glass around where it stops
const BULB_SURGE_LEN = 2       # SURGE: a cross, this many tiles in all 4 directions
const BULB_SURGE_LEN_RAGE = 3  # SURGE while overloaded
const BULB_SURGE_MULT = 0.9    # the surge covers a lot of floor, so it hits a bit softer
const BULB_SAFE_FRAC = 0.30    # fairness: this share of your reachable tiles stay unmarked
const BULB_MIN_SAFE = 2        # ...and never fewer than this many
const GLASS_DMG = 5            # standing on broken glass hurts (it does NOT slow you)
const BULB_CUTSCENE = true     # false = skip the intro cinematic

# ---- Between battles ----
const COIN_REWARD = 3          # coins for winning a battle (spend them at the shop)
const CHEST_TRAP_CHANCE = 0.25
const CHEST_TRAP_DMG = 12
const DOOR_HEAL = 25
const DOOR_GAMBLE_DMG = 20
const ICE_CREAM_HEAL = 30
const ICE_CREAM_PRICE = 1

const DEBUG_BUTTONS = false    # true = show WIN / LOSE shortcut buttons on the battle screen
const DEBUG_START_STAGE = 1    # 2 or 3 = jump straight to that battle (for testing the boss)
const FORCE_ENCOUNTER = ""     # "" = random. Set to "chest", "shop" or "chance" to force one

# ---- Toys (your attacks) ----
const BLASTER_DMG = 8          # NERF BLASTER: long line of foam darts, leaves slow
const BLASTER_RANGE = 6
const BASEBALL_DMG = 14        # BASEBALL THROW: lob to any tile, plus-shaped impact
const BASEBALL_MIN = 2
const BASEBALL_RANGE = 5
const SABER_DMG = 20           # LIGHTSABER THRUST: a wide thrust, leaves burn
const SABER_RANGE = 4          # how many tiles long the thrust is
const SABER_WIDTH = 3          # how many tiles wide the thrust is

# Cooldowns: after using a toy it needs this many rounds to recharge (0 = ready every round)
const BLASTER_CD = 0
const BASEBALL_CD = 1
const SABER_CD = 2

const ITEM_HEAL = 25           # JUICE BOX (one per battle)
const RUST_DMG = 4
const BURN_DMG = 5

# ---- Palette ----
const BG = Color(0.05, 0.05, 0.08)
const PANEL_BG = Color(0.09, 0.09, 0.14)
const TILE_A = Color(0.10, 0.11, 0.16)
const TILE_B = Color(0.13, 0.14, 0.20)
const GRID_LINE = Color(0.19, 0.20, 0.28)
const BORDER = Color(0.80, 0.83, 0.95)
const BORDER_DIM = Color(0.33, 0.36, 0.50)
const TEXT = Color(0.92, 0.94, 1.0)
const TEXT_DIM = Color(0.50, 0.54, 0.68)
const ACCENT = Color(1.0, 0.85, 0.25)
const BTN = Color(0.14, 0.15, 0.22)
const BTN_HOVER = Color(0.20, 0.22, 0.32)
const BTN_PRESS = Color(0.28, 0.30, 0.42)
const BTN_OFF = Color(0.08, 0.08, 0.12)
const BAR_BG = Color(0.03, 0.03, 0.05)
const PLAYER = Color(0.25, 0.55, 1.0)
const ENEMY = Color(0.90, 0.25, 0.20)
const CRUSH = Color(1.0, 0.15, 0.25)
const DANGER = Color(1.0, 0.60, 0.10)
const RUST = Color(0.65, 0.35, 0.15)
const SLOW = Color(0.30, 0.85, 0.95)
const BURN = Color(1.0, 0.35, 0.10)
const MOVE_COL = Color(0.30, 0.90, 0.40)
const TARGET_COL = Color(1.0, 0.95, 0.30)
const PREVIEW_COL = Color(1.0, 0.30, 0.30)
const HEAL = Color(0.40, 1.0, 0.50)
const DMG = Color(1.0, 0.35, 0.35)
const SABER = Color(0.78, 0.45, 1.0)
const GOO = Color(1.0, 0.72, 0.15)

# the boss: blinding filament white-yellow, and pale broken glass on the floor
const BULB_COL = Color(1.0, 0.95, 0.45)
const BULB_GLASS = Color(1.0, 0.97, 0.72)
const GLASS_COL = Color(0.82, 0.90, 1.0)

# Softer UI colors (battle side panel)
const CARD_BG = Color(0.11, 0.12, 0.19)
const ROW_BG = Color(0.13, 0.14, 0.22)
const ROW_SEL = Color(0.20, 0.22, 0.34)
const HP_GOOD = Color(0.35, 0.82, 0.50)
const HP_MID = Color(0.95, 0.78, 0.28)
const HP_LOW = Color(0.92, 0.32, 0.32)
const DART_BODY = Color(0.25, 0.55, 1.0)
const DART_TIP = Color(1.0, 0.55, 0.10)

enum Phase { TELEGRAPH, MOVE, ENEMY_MOVE, RESOLVE, TICK, CHECK, CUTSCENE }
