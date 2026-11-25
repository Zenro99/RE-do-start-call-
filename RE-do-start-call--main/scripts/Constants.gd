extends Reference

const GRID = 7
const TILE = 72
const GRID_OFFSET = Vector2(40, 68)
const PANEL_X = 600
const SCREEN_W = 960
const SCREEN_H = 640

const PLAYER_HP = 100
const PLAYER_MOVE = 3
const SLOWED_MOVE = 1

const ENEMY_HP = 100
const LUNGE_LEN = 3
const SLOWED_LUNGE = 1
const SWING_LEN = 3
const ENEMY_HIT_MIN = 10
const ENEMY_HIT_MAX = 22
const TELEGRAPH_TIME = 0.9
const PIPE_SWEEP_LUNGE = 2
const PIPE_ENRAGE_LUNGE = 1
const SWEEP_DMG_MULT = 0.8
const PIPE_SAFE_FRAC = 0.35
const PIPE_MIN_SAFE = 2

const CRIT_MULT = 1.5
const BULLSEYE_COL = Color(1.0, 0.82, 0.2)

const HANGER_HP = 120
const HANGER_LUNGE = 2
const HANGER_SWING_LEN = 4
const HANGER_HIT_MIN = 13
const HANGER_HIT_MAX = 24
const HANGER_TELEGRAPH = 1.2
const DRIP_COUNT = 13

const COIN_REWARD = 3
const CHEST_TRAP_CHANCE = 0.25
const CHEST_TRAP_DMG = 12
const DOOR_HEAL = 25
const DOOR_GAMBLE_DMG = 20
const ICE_CREAM_HEAL = 30
const ICE_CREAM_PRICE = 1

const DEBUG_BUTTONS = false
const FORCE_ENCOUNTER = ""

const BLASTER_DMG = 8
const BLASTER_RANGE = 6
const BASEBALL_DMG = 14
const BASEBALL_MIN = 2
const BASEBALL_RANGE = 5
const SABER_DMG = 20
const SABER_RANGE = 4
const SABER_WIDTH = 3
const BLASTER_CD = 0
const BASEBALL_CD = 1
const SABER_CD = 2

const ITEM_HEAL = 25
const RUST_DMG = 4
const BURN_DMG = 5

const BG = Color(0.045, 0.045, 0.075)
const PANEL_BG = Color(0.075, 0.078, 0.115)
const TILE_A = Color(0.098, 0.105, 0.155)
const TILE_B = Color(0.115, 0.125, 0.185)
const GRID_LINE = Color(0.165, 0.175, 0.245)
const BORDER = Color(0.78, 0.81, 0.93)
const BORDER_DIM = Color(0.27, 0.30, 0.43)
const TEXT = Color(0.93, 0.95, 1.0)
const TEXT_DIM = Color(0.46, 0.50, 0.63)
const ACCENT = Color(1.0, 0.85, 0.25)
const BTN = Color(0.13, 0.14, 0.21)
const BTN_HOVER = Color(0.19, 0.21, 0.31)
const BTN_PRESS = Color(0.26, 0.28, 0.40)
const BTN_OFF = Color(0.08, 0.08, 0.12)
const BAR_BG = Color(0.03, 0.03, 0.05)
const PLAYER = Color(0.25, 0.55, 1.0)
const ENEMY = Color(0.90, 0.25, 0.20)
const CRUSH = Color(1.0, 0.15, 0.25)
const DANGER = Color(1.0, 0.60, 0.10)
const RUST = Color(0.68, 0.36, 0.14)
const SLOW = Color(0.30, 0.85, 0.95)
const BURN = Color(1.0, 0.35, 0.10)
const MOVE_COL = Color(0.30, 0.90, 0.40)
const TARGET_COL = Color(1.0, 0.95, 0.30)
const PREVIEW_COL = Color(1.0, 0.30, 0.30)
const HEAL = Color(0.40, 1.0, 0.50)
const DMG = Color(1.0, 0.35, 0.35)
const SABER = Color(0.74, 0.36, 1.0)
const GOO = Color(1.0, 0.72, 0.15)
const CARD_BG = Color(0.105, 0.115, 0.175)
const ROW_BG = Color(0.12, 0.13, 0.20)
const ROW_SEL = Color(0.19, 0.21, 0.32)
const HP_GOOD = Color(0.35, 0.82, 0.50)
const HP_MID = Color(0.95, 0.78, 0.28)
const HP_LOW = Color(0.92, 0.32, 0.32)
const DART_BODY = Color(0.25, 0.55, 1.0)
const DART_TIP = Color(1.0, 0.55, 0.10)

enum Phase { TELEGRAPH, MOVE, ENEMY_MOVE, RESOLVE, TICK, CHECK }