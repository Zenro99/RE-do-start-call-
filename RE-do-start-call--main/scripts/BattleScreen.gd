extends Control

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")
const M = preload("res://scripts/Mods.gd")
const SFX = preload("res://scripts/Sfx.gd")

const PH_TELEGRAPH = 0
const PH_MOVE = 1
const PH_ENEMY_MOVE = 2
const PH_RESOLVE = 3
const PH_TICK = 4
const PH_CHECK = 5
const PH_CUTSCENE = 6

const SHOTS_BLASTER = 3
const SHOTS_BASEBALL = 2
const SHOTS_SABER = 2
const SHOTS_JUICE = 1
const RELOAD_BLASTER = 2
const RELOAD_BASEBALL = 3
const RELOAD_SABER = 5
const MAG_BONUS = 1
const MAG_RELOAD_CUT = 1

const TAPE_DMG = 5
const FIX_STEP = 4
const FIX_MAX = 16
const PLUSH_CUT = 4
const LUCKY_MULT = 2.0
const COMFORT_HEAL = 6

# --- Hanger (unchanged balance) ---
const HANGER_SAFE_FRAC = 0.28
const HANGER_MIN_SAFE = 3
const HANGER_PATTERN_MULT = 0.8
const DRIP_ENRAGE_BONUS = 5
const SPRAY_LEN = 5
const SPLAT_RADIUS = 2
const BLOOM_RADIUS = 2
const RESIDUE_CAP = 9
const ACID_DMG = 4

# --- Bulb: BULLET HELL. Two dashes, two real blasts, dense patterns. ---
const BULB_HP = 170
const BULB_LUNGE_1 = 2
const BULB_LUNGE_2 = 2
const BULB_ENRAGE_LUNGE = 1
const BULB_LEG_PAUSE = 0.5
const BULB_HIT_MIN = 16
const BULB_HIT_MAX = 28
const BULB_TELEGRAPH = 1.9
const BULB_SHATTER_R = 1
const BULB_SHATTER_SPIKE = 2
const BULB_SURGE_LEN = 3
const BULB_SURGE_LEN_RAGE = 4
const BULB_SURGE_DIAG = 1
const BULB_SURGE_DIAG_RAGE = 2
const BULB_SAFE_FRAC = 0.22
const BULB_MIN_SAFE = 2
const BULB_GLASS_SPRAY = 6
const GLASS_DMG = 4
const BULB_CUTSCENE = true
const SFX_VOL = -8.0

const FX_CYAN = Color(0.35, 0.95, 1.0)
const FX_MAGENTA = Color(1.0, 0.30, 0.86)
const FX_EMBER = Color(1.0, 0.58, 0.16)
const FX_STEEL = Color(0.78, 0.84, 0.98)
const FX_BONE = Color(1.0, 0.97, 0.88)
const FX_ACID = Color(0.60, 0.96, 0.20)
const FX_LEG1 = Color(1.0, 0.16, 0.28)
const FX_LEG2 = Color(0.80, 0.32, 1.0)
const FX_BULB = Color(1.0, 0.94, 0.42)
const FX_GLASS = Color(0.86, 0.93, 1.0)

const ACTIONS = ["NERF BLASTER", "BASEBALL", "LIGHTSABER", "JUICE BOX"]
const KINDS = ["blaster", "baseball", "saber", "item"]
const TOYS = ["blaster", "baseball", "saber"]

const PX = 616
const PW = 328

const TOY_ANIM = 0.70
const TOY_IMPACT = 0.46
const FOE_ANIM = 1.05
const FOE_IMPACT = 0.42

const SPRITE_PLAYER = [
    "..oooo..", ".obbbbo.", ".owbbwo.", ".obbbbo.",
    "oobbbboo", "oblbbbbo", ".obbbbo.", ".oo..oo.",
]
const SPRITE_PIPE = [
    ".oooooo.", "osgggggo", "orggggro", "ogeggego",
    "ogggggro", "odddddgo", "orRddRro", ".oooooo.",
]
const SPRITE_HANGER = [
    "...oo...", "..oggo..", "...og...", "...og...",
    "..ogggo.", ".ogmmggo", "ogmmmmgo", "o.d.md.o",
]
const SPRITE_BULB = [
    "o..oo..o", ".oy.yyo.", "oywwyyyo", ".oywyyo.",
    "..oyyo..", "..oggo..", ".oggggo.", "..oooo..",
]

const CUTSCENE = [
    {"dur": 1.4, "text": "The hallway goes dark.", "col": "dim", "shake": 0.0, "flash": 0.0, "snd": ""},
    {"dur": 1.6, "text": "Something is still plugged in.", "col": "accent", "shake": 1.5, "flash": 0.16, "snd": "telegraph"},
    {"dur": 1.6, "text": "Glass under your sneakers.", "col": "text", "shake": 2.5, "flash": 0.0, "snd": "glass"},
    {"dur": 1.7, "text": "It remembers being whole.", "col": "crush", "shake": 4.0, "flash": 0.34, "snd": "boss"},
    {"dur": 2.3, "text": "THE CRUSHED LIGHTBULB", "col": "bulb", "shake": 10.0, "flash": 0.9, "reveal": true, "snd": "boom"},
    {"dur": 1.2, "text": "DON'T BLINK.", "col": "crush", "shake": 0.0, "flash": 0.18, "snd": ""},
]

const HELP = [
    {"t": "HOW IT WORKS", "f": 16, "c": "accent"},
    {"t": "", "f": 8, "c": "text"},
    {"t": "The enemy flashes its plan once. You move. You throw a toy.", "f": 8, "c": "text"},
    {"t": "Nothing stays lit - remember the flash.", "f": 8, "c": "text"},
    {"t": "Your toy lands after it moves, so aim where it will end up.", "f": 8, "c": "text"},
    {"t": "", "f": 8, "c": "text"},
    {"t": "THE FLASH", "f": 12, "c": "accent"},
    {"t": "RED     the slide. Being there is fatal.", "f": 8, "c": "crush"},
    {"t": "ORANGE  the blast. It costs health.", "f": 8, "c": "danger"},
    {"t": "GOLD    a bullseye. It hits much harder.", "f": 8, "c": "bull"},
    {"t": "", "f": 8, "c": "text"},
    {"t": "THE FLOOR", "f": 12, "c": "accent"},
    {"t": "Rust, glass and acid hurt you.", "f": 8, "c": "text"},
    {"t": "Only foam and goo slow you. Acid never holds you.", "f": 8, "c": "dim"},
    {"t": "", "f": 8, "c": "text"},
    {"t": "YOUR TOYS", "f": 12, "c": "accent"},
    {"t": "The pips are shots. Empty a toy and it reloads.", "f": 8, "c": "text"},
    {"t": "Nothing loaded? Stay put and let them come back.", "f": 8, "c": "text"},
    {"t": "", "f": 8, "c": "text"},
    {"t": "THE BULB", "f": 12, "c": "accent"},
    {"t": "Two dashes. Crimson first, violet second.", "f": 8, "c": "leg1"},
    {"t": "It BLASTS after each dash. Two hits every round.", "f": 8, "c": "leg2"},
    {"t": "Glass at the first stop. Light at the second.", "f": 8, "c": "dim"},
    {"t": "", "f": 8, "c": "text"},
    {"t": "WASD move    SPACE confirm    ESC back", "f": 8, "c": "dim"},
    {"t": "1-4 toys    0 stay put    M sound    R restart", "f": 8, "c": "dim"},
]

# ---------------- state ----------------
var enemy_type = "pipe"
var player_pos = Vector2(3, 6)
var enemy_pos = Vector2(3, 0)
var player_vis = Vector2(3, 6)
var enemy_vis = Vector2(3, 0)
var player_hp = 100
var enemy_hp = 100
var round_num = 1
var phase = PH_TELEGRAPH
var sub_state = "busy"
var lunge_tiles = []
var swing_tiles = []
var effects = {}
var queued_attack = {}
var juice_left = 1
var cursor = Vector2(3, 6)
var move_origin = Vector2(3, 6)
var current_kind = ""
var action_index = 0
var move_tiles = []
var target_tiles = []
var result = ""

var run = {}
var mods = []
var max_hp = 100
var enemy_max = 100
var player_dead = false
var enemy_dead = false
var player_dead_t = 0.0
var enemy_dead_t = 0.0

var ammo = {}
var reload = {}

var hit_streak = 0
var echo = {}
var armor_used = false
var damaged_this_round = false
var mod_pulse = {}
var hover_mod = ""

var last_pattern = ""
var enraged = false
var pattern_label = ""
var enemy_dir = Vector2(0, 1)
var swing_groups = []
var strike_mult = 1.0
var last_pipe_variant = ""
var last_move = Vector2(0, 0)
var enemy_anim = {}
var enemy_anim_t = 0.0
var enemy_lerp = 12.0
var trail = []
var idle_t = 0.0
var crit_t = 0.0
var crit_tile = Vector2(0, 0)

var lunge_legs = []
var leg_ends = []
var tele_origin = Vector2(3, 0)
var tele_total = 1.0

# the boss fires twice: one real blast per dash
var bulb_blasts = []
var bulb_phase = 0
var active_swing = []
var active_groups = []
var active_mult = 1.0

var cutscene_i = -1
var cutscene_t = 0.0
var cutscene_dark = 0.0
var cutscene_flash = 0.0
var boss_revealed = true

var help_open = false

var player_hp_vis = 100.0
var enemy_hp_vis = 100.0
var deny_index = -1
var deny_t = 0.0
var banner_t = 0.0

var next_step = ""
var wait_time = 0.0
var anim_t = 0.0
var show_lunge_t = 0.0
var show_swing_t = 0.0
var attack_flash = []
var attack_flash_t = 0.0
var attack_flash_color = Color(1, 1, 1)
var attack_anim = {}
var attack_anim_t = 0.0
var player_flash = 0.0
var enemy_flash = 0.0
var shake = 0.0
var floaters = []
var popups = []
var banner_text = ""
var banner_color = Color(1, 1, 1)

var rings = []
var sparks = []
var arcs = []
var wash_t = 0.0
var wash_dur = 0.3
var wash_col = Color(1, 1, 1)
var wash_amt = 0.0
var hurt_t = 0.0
var hitstop = 0.0

var f8 = null
var f12 = null
var f16 = null
var pal_player = {}
var pal_pipe = {}
var pal_hanger = {}
var pal_bulb = {}
var sfx = null
var sound_on = true

var DIRS = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
var DIRS8 = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
var SPECKS = [Vector2(12, 14), Vector2(44, 22), Vector2(26, 46)]


# ---------------- setup ----------------

func _ready():
    f8 = S.make_font(8)
    f12 = S.make_font(12)
    f16 = S.make_font(16)
    if f8 == null:
        f8 = get_font("font", "Label")
    if f12 == null:
        f12 = get_font("font", "Label")
    if f16 == null:
        f16 = get_font("font", "Label")

    pal_player = {"o": Color(0.04, 0.06, 0.14), "b": C.PLAYER, "l": Color(0.6, 0.8, 1.0), "w": Color(1, 1, 1)}
    pal_pipe = {"o": Color(0.16, 0.08, 0.05), "s": Color(0.82, 0.86, 0.92), "g": Color(0.55, 0.58, 0.65), "r": C.RUST, "R": Color(1.0, 0.55, 0.2), "e": Color(1.0, 0.9, 0.2), "d": Color(0.10, 0.03, 0.03)}
    pal_hanger = {"o": Color(0.10, 0.08, 0.10), "g": Color(0.66, 0.69, 0.76), "m": Color(1.0, 0.55, 0.15), "d": Color(1.0, 0.85, 0.30)}
    pal_bulb = {"o": Color(0.12, 0.12, 0.16), "y": FX_BULB, "w": Color(1, 1, 1), "g": Color(0.55, 0.57, 0.62)}

    var par = get_parent()
    var carried = null
    if par != null:
        carried = par.get("run")
    if carried != null and not carried.empty():
        run = carried
    else:
        run = {"hp": C.PLAYER_HP, "max_hp": C.PLAYER_HP, "coins": 0, "mods": []}
    mods = run.get("mods", [])
    max_hp = int(run.get("max_hp", C.PLAYER_HP))
    player_hp = int(run.get("hp", C.PLAYER_HP))

    sound_on = true
    if par != null:
        var ps = par.get("sound_on")
        if ps != null:
            sound_on = bool(ps)
        if par.get("sfx") != null:
            sfx = par.get("sfx")
    if sfx == null:
        sfx = SFX.new()
        sfx.setup(self, sound_on, SFX_VOL)

    juice_left = SHOTS_JUICE
    for k in TOYS:
        ammo[k] = uses_of(k)
        reload[k] = 0

    enemy_max = enemy_base_hp()
    enemy_hp = enemy_max
    player_hp_vis = float(player_hp)
    enemy_hp_vis = float(enemy_hp)
    tele_origin = enemy_pos

    if enemy_type == "bulb" and BULB_CUTSCENE:
        start_cutscene()
    else:
        start_round()


func snd(key, pitch = 1.0):
    if sfx != null:
        sfx.play(key, pitch)


# ---------------- helpers ----------------

func in_grid(t):
    return t.x >= 0 and t.x < C.GRID and t.y >= 0 and t.y < C.GRID


func tile_px(t):
    return C.GRID_OFFSET + t * C.TILE


func tile_center(t):
    return tile_px(t) + Vector2(C.TILE * 0.5, C.TILE * 0.5)


func tile_rect(t):
    return Rect2(tile_px(t), Vector2(C.TILE, C.TILE))


func board_rect():
    var g = C.GRID * C.TILE
    return Rect2(C.GRID_OFFSET.x - 8, C.GRID_OFFSET.y - 8, g + 16, g + 16)


func alpha(col, a):
    return Color(col.r, col.g, col.b, a)


func ease_out(p):
    return 1.0 - pow(1.0 - clamp(p, 0.0, 1.0), 3.0)


func fit_text(font, text, maxw):
    if font == null:
        return text
    if font.get_string_size(text).x <= maxw:
        return text
    var s = text
    while s.length() > 3 and font.get_string_size(s + "...").x > maxw:
        s = s.substr(0, s.length() - 1)
    return s + "..."


func effect_at(pos):
    if effects.has(pos):
        return effects[pos]["type"]
    return ""


func add_effect(pos, type, turns):
    effects[pos] = {"type": type, "turns": turns}


func effect_color(type):
    if type == "rust":
        return C.RUST
    if type == "slow":
        return C.SLOW
    if type == "goo":
        return C.GOO
    if type == "acid":
        return FX_ACID
    if type == "glass":
        return FX_GLASS
    return C.BURN


# ONLY foam and goo slow. Acid burns but never impedes movement.
func is_slow(pos):
    var e = effect_at(pos)
    return e == "slow" or e == "goo"


func set_banner(text, col, dur = 1.2):
    banner_text = text
    banner_color = col
    banner_t = dur


func enemy_title():
    if enemy_type == "hanger":
        return "MELTED HANGER"
    if enemy_type == "bulb":
        return "CRUSHED LIGHTBULB"
    return "RUSTED PIPE"


func enemy_color():
    if enraged:
        return C.CRUSH
    if enemy_type == "hanger":
        return C.DANGER
    if enemy_type == "bulb":
        return FX_BULB
    return C.ENEMY


func enemy_base_hp():
    if enemy_type == "hanger":
        return C.HANGER_HP
    if enemy_type == "bulb":
        return BULB_HP
    return C.ENEMY_HP


func enemy_hit_color():
    if enemy_type == "hanger":
        return C.GOO
    if enemy_type == "bulb":
        return FX_BULB
    return C.RUST


func floor_effect():
    if enemy_type == "hanger":
        return "goo"
    if enemy_type == "bulb":
        return "glass"
    return "rust"


func hit_min():
    if enemy_type == "hanger":
        return C.HANGER_HIT_MIN
    if enemy_type == "bulb":
        return BULB_HIT_MIN
    return C.ENEMY_HIT_MIN


func hit_max():
    if enemy_type == "hanger":
        return C.HANGER_HIT_MAX
    if enemy_type == "bulb":
        return BULB_HIT_MAX
    return C.ENEMY_HIT_MAX


func has_mod(id):
    return mods.has(id)


func pulse_mod(id):
    mod_pulse[id] = 0.7


func player_steps():
    var steps = C.PLAYER_MOVE
    if is_slow(player_pos):
        steps = C.SLOWED_MOVE
    if has_mod("extra_step"):
        steps += 1
    return steps


func uses_of(kind):
    if kind == "item":
        return SHOTS_JUICE
    var base = 1
    if kind == "blaster":
        base = SHOTS_BLASTER
    elif kind == "baseball":
        base = SHOTS_BASEBALL
    elif kind == "saber":
        base = SHOTS_SABER
    if has_mod("spare_mag"):
        base += MAG_BONUS
    return base


func reload_of(kind):
    var base = 1
    if kind == "blaster":
        base = RELOAD_BLASTER
    elif kind == "baseball":
        base = RELOAD_BASEBALL
    elif kind == "saber":
        base = RELOAD_SABER
    if has_mod("spare_mag"):
        base = int(max(1, base - MAG_RELOAD_CUT))
    return base


func toy_ready(kind):
    if kind == "item":
        return juice_left > 0
    return int(reload.get(kind, 0)) <= 0 and int(ammo.get(kind, 0)) > 0


func any_toy_ready():
    for k in TOYS:
        if toy_ready(k):
            return true
    return false


func crit_mult():
    if has_mod("lucky"):
        return LUCKY_MULT
    return C.CRIT_MULT


func telegraph_time():
    if enemy_type == "hanger":
        return C.HANGER_TELEGRAPH
    if enemy_type == "bulb":
        return BULB_TELEGRAPH
    return C.TELEGRAPH_TIME


func schedule(method, delay):
    next_step = method
    wait_time = delay


func update_ui():
    update()


func float_text(text, tile, col, dy = 0):
    var p = tile_px(tile) + Vector2(C.TILE * 0.5, 24 + dy)
    floaters.append({"text": text, "pos": p, "t": 0.0, "color": col})


func push_popup(tile, head, parts, col):
    var p = tile_center(tile) + Vector2(0, -16)
    popups.append({"pos": p, "head": head, "parts": parts, "color": col, "t": 0.0})


# ---------------- effect spawners ----------------

func add_ring(pos, r0, r1, life, col, w, shape = "circle", delay = 0.0):
    rings.append({"pos": pos, "r0": r0, "r1": r1, "life": life, "col": col, "w": w, "shape": shape, "t": 0.0, "delay": delay})


func add_arc(pos, a0, a1, rad, life, col, w, delay = 0.0):
    arcs.append({"pos": pos, "a0": a0, "a1": a1, "rad": rad, "life": life, "col": col, "w": w, "t": 0.0, "delay": delay})


func add_spark(pos, vel, life, col, sz, grav = 0.0, delay = 0.0, tail_on = true):
    sparks.append({"pos": pos, "vel": vel, "life": life, "col": col, "sz": sz, "grav": grav, "t": 0.0, "delay": delay, "tail": tail_on})


func add_burst(pos, n, speed, col, life, sz, grav = 0.0, delay = 0.0):
    for i in range(n):
        var ang = rand_range(0.0, TAU)
        var sp = rand_range(speed * 0.45, speed)
        add_spark(pos, Vector2(cos(ang), sin(ang)) * sp, rand_range(life * 0.6, life), col, sz, grav, delay)


func add_cone(pos, dvec, n, spread, speed, col, life, sz, grav = 0.0, delay = 0.0):
    var base_ang = atan2(dvec.y, dvec.x)
    for i in range(n):
        var ang = base_ang + rand_range(-spread, spread)
        var sp = rand_range(speed * 0.5, speed)
        add_spark(pos, Vector2(cos(ang), sin(ang)) * sp, rand_range(life * 0.6, life), col, sz, grav, delay)


func add_wash(col, amt, dur = 0.3):
    wash_col = col
    wash_amt = max(wash_amt, amt)
    wash_dur = dur
    wash_t = dur


func add_hitstop(d):
    hitstop = max(hitstop, d)


func tile_pop(tile, col, delay = 0.0):
    var cp = tile_center(tile)
    add_ring(cp, 8, 42, 0.32, col, 3.0, "square", delay)
    add_burst(cp, 5, 150, col, 0.34, 4, 260, delay)


func big_pop(pos, col, delay = 0.0):
    add_ring(pos, 12, 104, 0.46, col, 5.0, "circle", delay)
    add_ring(pos, 6, 66, 0.30, Color(1, 1, 1), 3.0, "circle", delay)
    add_burst(pos, 16, 260, col, 0.5, 5, 320, delay)


func spawn_idle():
    var cp = tile_center(enemy_vis)
    if enemy_type == "hanger":
        add_spark(cp + Vector2(rand_range(-12, 12), 22), Vector2(0, 62), 0.42, C.GOO, 4, 40, 0.0, false)
    elif enemy_type == "bulb":
        add_spark(cp + Vector2(rand_range(-12, 12), rand_range(-14, 8)), Vector2(rand_range(-20, 20), rand_range(-52, -18)), 0.42, FX_BULB, 3, -20)
    else:
        add_spark(cp + Vector2(rand_range(-14, 14), -26), Vector2(rand_range(-9, 9), -38), 0.6, FX_STEEL, 3, -8, 0.0, false)


# ---------------- damage ----------------

func damage_player(n, parts = []):
    player_hp = int(max(0, player_hp - n))
    damaged_this_round = true
    player_flash = 0.24
    shake = max(shake, 7.0)
    hurt_t = 0.42
    add_wash(C.CRUSH, 0.16, 0.24)
    add_hitstop(0.05)
    push_popup(player_pos, "-" + str(n), parts, C.DMG)
    add_burst(tile_center(player_pos), 12, 210, C.PLAYER, 0.45, 5, 300)
    add_ring(tile_center(player_pos), 10, 60, 0.34, C.CRUSH, 4.0, "circle")
    snd("hurt")
    if player_hp <= 0:
        kill_player()
    update_ui()


func damage_enemy(n, parts = [], crit = false):
    enemy_hp = int(max(0, enemy_hp - n))
    enemy_flash = 0.24
    shake = max(shake, 4.5)
    var cp = tile_center(enemy_pos)
    if crit:
        shake = 11.0
        crit_t = 0.6
        crit_tile = enemy_pos
        add_hitstop(0.085)
        add_wash(C.BULLSEYE_COL, 0.30, 0.34)
        push_popup(enemy_pos, str(n), parts, C.BULLSEYE_COL)
        big_pop(cp, C.BULLSEYE_COL)
        add_ring(cp, 18, 150, 0.6, FX_BONE, 2.0, "circle", 0.06)
        add_burst(cp, 22, 330, C.BULLSEYE_COL, 0.62, 6, 240)
        add_cone(cp, Vector2(0, -1), 10, 0.7, 300, FX_BONE, 0.55, 4, 300)
        set_banner("BULLSEYE", C.BULLSEYE_COL, 0.9)
        snd("crit")
    else:
        push_popup(enemy_pos, str(n), parts, C.TEXT)
        add_burst(cp, 10, 200, enemy_color(), 0.42, 5, 260)
        add_ring(cp, 8, 52, 0.28, FX_BONE, 3.0, "circle")
        snd("hit")
    if enemy_hp <= 0 and not enemy_dead:
        enemy_dead = true
        enemy_dead_t = 0.0
        add_hitstop(0.12)
        add_wash(Color(1, 1, 1), 0.5, 0.5)
        shake = 14.0
        big_pop(cp, enemy_color())
        add_ring(cp, 20, 220, 0.9, FX_BONE, 3.0, "circle", 0.08)
        add_burst(cp, 30, 340, enemy_color(), 0.8, 6, 260)
        snd("boom")
        if enemy_type == "bulb":
            add_burst(cp, 26, 300, FX_BULB, 0.9, 5, 200)
            add_ring(cp, 10, 260, 1.1, FX_BULB, 4.0, "circle", 0.16)
            set_banner("THE LIGHT GOES OUT", FX_BULB, 1.5)
            snd("glass")
    update_ui()


func kill_player():
    if player_dead:
        return
    player_dead = true
    player_dead_t = 0.0
    add_wash(C.CRUSH, 0.4, 0.6)
    add_hitstop(0.12)
    big_pop(tile_center(player_pos), C.PLAYER)
    add_burst(tile_center(player_pos), 26, 300, C.PLAYER, 0.8, 6, 280)
    snd("lose")


func kind_name(kind):
    var i = KINDS.find(kind)
    if i < 0:
        return str(kind)
    return ACTIONS[i]


func attack_dmg(kind):
    if kind == "blaster":
        return C.BLASTER_DMG
    if kind == "baseball":
        return C.BASEBALL_DMG
    return C.SABER_DMG


func line_range(kind):
    if kind == "blaster":
        return C.BLASTER_RANGE
    return C.SABER_RANGE


# ---------------- help ----------------

func toggle_help():
    help_open = not help_open
    snd("ui")
    update()


func help_color(key):
    if key == "accent":
        return C.ACCENT
    if key == "crush":
        return C.CRUSH
    if key == "danger":
        return C.DANGER
    if key == "bull":
        return C.BULLSEYE_COL
    if key == "leg1":
        return FX_LEG1
    if key == "leg2":
        return FX_LEG2
    if key == "dim":
        return C.TEXT_DIM
    return C.TEXT


func draw_help():
    draw_rect(Rect2(0, 0, C.SCREEN_W, C.SCREEN_H), Color(0.02, 0.02, 0.04, 0.92))
    var r = Rect2(80, 40, 800, 560)
    draw_rect(r, C.PANEL_BG)
    frame(r, C.BORDER_DIM, 2)
    var y = 84
    for line in HELP:
        var font = f8
        if line["f"] == 16:
            font = f16
        elif line["f"] == 12:
            font = f12
        if font != null and line["t"] != "":
            draw_string(font, Vector2(116, y), line["t"], help_color(line["c"]))
        if line["f"] == 16:
            y += 28
        elif line["f"] == 12:
            y += 22
        else:
            y += 16
    if f8 != null:
        draw_string(f8, Vector2(116, 576), "H closes this. The fight is paused.", C.TEXT_DIM)


# ---------------- cinematic ----------------

func in_cutscene():
    return cutscene_i >= 0


func cutscene_color(key):
    if key == "dim":
        return C.TEXT_DIM
    if key == "accent":
        return C.ACCENT
    if key == "crush":
        return C.CRUSH
    if key == "bulb":
        return FX_BULB
    return C.TEXT


func start_cutscene():
    phase = PH_CUTSCENE
    sub_state = "busy"
    cutscene_i = 0
    cutscene_t = 0.0
    cutscene_dark = 0.0
    cutscene_flash = 0.0
    boss_revealed = false
    apply_cutscene_step()
    update_ui()


func apply_cutscene_step():
    var d = CUTSCENE[cutscene_i]
    set_banner(d["text"], cutscene_color(d["col"]), d["dur"] + 0.2)
    shake = max(shake, d["shake"])
    cutscene_flash = max(cutscene_flash, d["flash"])
    if d["snd"] != "":
        snd(d["snd"])
    if d.has("reveal"):
        boss_revealed = true
        var cp = tile_center(enemy_pos)
        big_pop(cp, FX_BULB)
        add_ring(cp, 20, 250, 1.0, FX_BONE, 3.0, "circle", 0.1)
        add_burst(cp, 30, 320, FX_BULB, 0.9, 5, 220)


func tick_cutscene(delta):
    cutscene_t += delta
    cutscene_dark = min(1.0, cutscene_dark + delta * 1.6)
    if not boss_revealed and randf() < delta * 10.0:
        var sx = C.GRID_OFFSET.x + rand_range(0.0, C.GRID * C.TILE)
        add_spark(Vector2(sx, C.GRID_OFFSET.y - 10), Vector2(rand_range(-10, 10), rand_range(90, 170)), 0.7, FX_BULB, 3, 60)
    if cutscene_t >= CUTSCENE[cutscene_i]["dur"]:
        cutscene_i += 1
        cutscene_t = 0.0
        if cutscene_i >= CUTSCENE.size():
            end_cutscene()
        else:
            apply_cutscene_step()


func end_cutscene():
    cutscene_i = -1
    cutscene_dark = 0.0
    cutscene_flash = 0.0
    boss_revealed = true
    start_round()


# ---------------- round ----------------

func start_round():
    phase = PH_TELEGRAPH
    sub_state = "busy"
    move_tiles = []
    target_tiles = []
    queued_attack = {}
    damaged_this_round = false
    compute_enemy_attack()
    var tt = telegraph_time()
    tele_total = tt
    # THE ONLY PLACE THE TELEGRAPH IS EVER LIT.
    show_lunge_t = tt
    show_swing_t = tt
    var title = pattern_label
    if enraged:
        if enemy_type == "hanger":
            title = "MELTDOWN  " + pattern_label
        elif enemy_type == "bulb":
            title = "OVERLOAD  " + pattern_label
        else:
            title = "ENRAGED  " + pattern_label
    if enraged:
        set_banner(title, C.CRUSH, tt + 0.2)
    else:
        set_banner(title, C.TEXT, tt + 0.2)
    snd("telegraph")
    update_ui()
    schedule("end_telegraph", tt + 0.1)


func compute_enemy_attack():
    strike_mult = 1.0
    swing_groups = []
    lunge_legs = []
    leg_ends = []
    bulb_blasts = []
    bulb_phase = 0
    active_swing = []
    active_groups = []
    active_mult = 1.0
    tele_origin = enemy_pos
    if enemy_type == "hanger":
        compute_hanger_attack()
    elif enemy_type == "bulb":
        compute_bulb_attack()
    else:
        compute_pipe_attack()


# ---- the Pipe (UNCHANGED) ----

func compute_pipe_attack():
    enraged = enemy_hp * 2 <= enemy_max
    var reach = reachable_tiles()
    var habit = player_pos + last_move
    var base_charge = C.LUNGE_LEN
    var base_sweep = C.PIPE_SWEEP_LUNGE
    if enraged:
        base_charge += C.PIPE_ENRAGE_LUNGE
    if is_slow(enemy_pos):
        base_charge = C.SLOWED_LUNGE
        base_sweep = C.SLOWED_LUNGE
    var min_safe = int(max(C.PIPE_MIN_SAFE, ceil(reach.size() * C.PIPE_SAFE_FRAC)))
    var best = null
    var best_score = -99999.0
    var fallback = null
    var fallback_safe = -1

    for variant in ["charge", "sweep"]:
        var max_n = base_charge
        if variant == "sweep":
            max_n = base_sweep
        for dvec in DIRS:
            for n in range(1, max_n + 1):
                var cand = build_pipe_candidate(variant, dvec, n)
                if cand.empty():
                    continue
                var covered = 0.0
                var safe = 0
                for t in reach:
                    if cand["lunge"].has(t):
                        covered += pipe_tile_weight(t, habit) * 1.7
                    elif cand["swing"].has(t):
                        covered += pipe_tile_weight(t, habit)
                    else:
                        safe += 1
                if safe > fallback_safe:
                    fallback_safe = safe
                    fallback = cand
                if safe < min_safe:
                    continue
                var e = cand["end"]
                var dist = abs(e.x - player_pos.x) + abs(e.y - player_pos.y)
                var score = covered + (12.0 - dist) * 0.9
                if variant == last_pipe_variant:
                    score *= 0.9
                score *= rand_range(0.9, 1.1)
                if score > best_score:
                    best_score = score
                    best = cand

    if best == null:
        best = fallback
    if best == null:
        lunge_tiles = []
        swing_tiles = []
        swing_groups = []
        pattern_label = "STUCK"
        return
    lunge_tiles = best["lunge"]
    swing_tiles = best["swing"]
    enemy_dir = best["dir"]
    last_pipe_variant = best["variant"]
    swing_groups = [{"kind": best["variant"], "tiles": best["swing"], "center": best["end"], "fx": ""}]
    if best["variant"] == "sweep":
        pattern_label = "SPIN SWEEP"
        strike_mult = C.SWEEP_DMG_MULT
    else:
        pattern_label = "RUST CHARGE"


func build_pipe_candidate(variant, dvec, n):
    var lunge = []
    for i in range(1, n + 1):
        var t = enemy_pos + dvec * i
        if not in_grid(t):
            return {}
        lunge.append(t)
    var end = lunge[lunge.size() - 1]
    var swing = []
    if variant == "charge":
        for i in range(1, C.SWING_LEN + 1):
            var t2 = end + dvec * i
            if not in_grid(t2):
                break
            swing.append(t2)
    else:
        var ring_off = []
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                if dx != 0 or dy != 0:
                    ring_off.append(Vector2(dx, dy))
        if enraged:
            ring_off.append(Vector2(2, 0))
            ring_off.append(Vector2(-2, 0))
            ring_off.append(Vector2(0, 2))
            ring_off.append(Vector2(0, -2))
        for o in ring_off:
            var t3 = end + o
            if in_grid(t3) and t3 != enemy_pos and not lunge.has(t3):
                swing.append(t3)
    if swing.empty():
        return {}
    return {"variant": variant, "dir": dvec, "lunge": lunge, "swing": swing, "end": end}


func pipe_tile_weight(t, habit):
    var w = 1.0
    if t == player_pos:
        w += 1.5
    if t == habit:
        w += 1.0
    w += 0.25 * (abs(t.x - enemy_pos.x) + abs(t.y - enemy_pos.y))
    if t.x == enemy_pos.x or t.y == enemy_pos.y:
        w += 1.0
    return w


# ---- the Hanger ----

func compute_hanger_attack():
    enraged = enemy_hp * 2 <= enemy_max
    var dvec = best_dir8_from(enemy_pos)
    if randf() < 0.3:
        dvec = rand_dir8_from(enemy_pos)
    enemy_dir = dvec
    var lunge_len = C.HANGER_LUNGE
    if is_slow(enemy_pos):
        lunge_len = C.SLOWED_LUNGE
    lunge_tiles = []
    for i in range(1, lunge_len + 1):
        var t = enemy_pos + dvec * i
        if not in_grid(t):
            break
        lunge_tiles.append(t)
    var end = enemy_pos
    if lunge_tiles.size() > 0:
        end = lunge_tiles[lunge_tiles.size() - 1]

    var patterns = []
    if last_pattern == "splat" and not enraged:
        patterns = ["sag"]
    else:
        var first = pick_hanger_pattern()
        patterns.append(first)
        if enraged:
            var second = first
            var guard = 0
            while second == first and guard < 12:
                second = pick_hanger_pattern()
                guard += 1
            patterns.append(second)
    last_pattern = "other"
    if patterns.has("splat"):
        last_pattern = "splat"

    swing_tiles = []
    swing_groups = []
    var names = []
    strike_mult = HANGER_PATTERN_MULT
    for p in patterns:
        var res = hanger_pattern(p, end, dvec)
        names.append(res["name"])
        for t in res["tiles"]:
            add_unique(swing_tiles, t)
        swing_groups.append({"kind": p, "tiles": res["tiles"], "center": res["center"], "fx": res["fx"]})

    pattern_label = ""
    for nm in names:
        if pattern_label != "":
            pattern_label += " + "
        pattern_label += nm

    for t in lunge_tiles:
        unmark(t)
    trim_swing_for_escape(reachable_tiles(), HANGER_SAFE_FRAC, HANGER_MIN_SAFE)


func pick_hanger_pattern():
    var r = randi() % 100
    if r < 26:
        return "drip"
    if r < 48:
        return "spray"
    if r < 68:
        return "splat"
    if r < 86:
        return "bloom"
    return "cross"


func hanger_pattern(p, end, dvec):
    var tiles = []
    var center = end
    var nm = "SAGGING"
    var fx = ""
    if p == "drip":
        nm = "DRIP RAIN"
        fx = "goo"
        var n = C.DRIP_COUNT
        if enraged:
            n += DRIP_ENRAGE_BONUS
        tiles = random_scatter(n)
    elif p == "spray":
        nm = "ACID FAN"
        fx = "acid"
        var perp = Vector2(dvec.y, dvec.x)
        for i in range(1, SPRAY_LEN + 1):
            for w in range(-1, 2):
                var t = end + dvec * i + perp * w
                if in_grid(t):
                    add_unique(tiles, t)
    elif p == "splat":
        nm = "MELT SPLAT"
        fx = "acid"
        center = player_pos
        for dx in range(-SPLAT_RADIUS, SPLAT_RADIUS + 1):
            for dy in range(-SPLAT_RADIUS, SPLAT_RADIUS + 1):
                if abs(dx) + abs(dy) <= SPLAT_RADIUS:
                    var t2 = player_pos + Vector2(dx, dy)
                    if in_grid(t2):
                        add_unique(tiles, t2)
    elif p == "bloom":
        nm = "GOO BLOOM"
        fx = "goo"
        for dx in range(-BLOOM_RADIUS, BLOOM_RADIUS + 1):
            for dy in range(-BLOOM_RADIUS, BLOOM_RADIUS + 1):
                if max(abs(dx), abs(dy)) == BLOOM_RADIUS:
                    var t3 = end + Vector2(dx, dy)
                    if in_grid(t3):
                        add_unique(tiles, t3)
    elif p == "cross":
        nm = "CROSS RAIN"
        fx = "acid"
        center = player_pos
        for i in range(C.GRID):
            var a = Vector2(i, player_pos.y)
            var b = Vector2(player_pos.x, i)
            if in_grid(a):
                add_unique(tiles, a)
            if in_grid(b):
                add_unique(tiles, b)
    return {"tiles": tiles, "center": center, "name": nm, "fx": fx}


# ---- the Bulb: TWO dashes, TWO real blasts, dense bullet hell ----

func compute_bulb_attack():
    enraged = enemy_hp * 5 <= enemy_max * 3
    var reach = reachable_tiles()
    var extra = 0
    if enraged:
        extra = BULB_ENRAGE_LUNGE
    var len1 = BULB_LUNGE_1 + extra
    var len2 = BULB_LUNGE_2 + extra
    if is_slow(enemy_pos):
        len1 = C.SLOWED_LUNGE
        len2 = C.SLOWED_LUNGE

    var dir1 = best_dir8_from(enemy_pos)
    if randf() < 0.2:
        dir1 = rand_dir8_from(enemy_pos)
    var leg1 = slide_tiles(enemy_pos, dir1, len1)
    var end1 = enemy_pos
    if leg1.size() > 0:
        end1 = leg1[leg1.size() - 1]

    var dir2 = best_dir8_from(end1)
    if randf() < 0.3:
        dir2 = rand_dir8_from(end1)
    var raw2 = slide_tiles(end1, dir2, len2)
    var leg2 = []
    for t in raw2:
        if t == enemy_pos or leg1.has(t):
            break
        leg2.append(t)

    lunge_legs = [leg1, leg2]
    lunge_tiles = []
    for t in leg1:
        add_unique(lunge_tiles, t)
    for t in leg2:
        add_unique(lunge_tiles, t)

    var guard = 0
    while count_safe_from_lunge(reach) < 1 and guard < 8:
        guard += 1
        if lunge_legs[1].size() > 0:
            var last2 = lunge_legs[1][lunge_legs[1].size() - 1]
            lunge_legs[1].remove(lunge_legs[1].size() - 1)
            lunge_tiles.erase(last2)
        elif lunge_legs[0].size() > 0:
            var last1 = lunge_legs[0][lunge_legs[0].size() - 1]
            lunge_legs[0].remove(lunge_legs[0].size() - 1)
            lunge_tiles.erase(last1)
        else:
            break

    var e1 = enemy_pos
    if lunge_legs[0].size() > 0:
        e1 = lunge_legs[0][lunge_legs[0].size() - 1]
    var e2 = e1
    if lunge_legs[1].size() > 0:
        e2 = lunge_legs[1][lunge_legs[1].size() - 1]
    leg_ends = [e1, e2]
    enemy_dir = dir2
    if lunge_legs[1].empty():
        enemy_dir = dir1

    # BLAST A - glass burst at the FIRST stop. 3x3 plus diagonal spikes.
    var ga = []
    for dx in range(-BULB_SHATTER_R, BULB_SHATTER_R + 1):
        for dy in range(-BULB_SHATTER_R, BULB_SHATTER_R + 1):
            var ta = e1 + Vector2(dx, dy)
            if in_grid(ta):
                add_unique(ga, ta)
    var sp = BULB_SHATTER_SPIKE
    for o in [Vector2(sp, sp), Vector2(sp, -sp), Vector2(-sp, sp), Vector2(-sp, -sp)]:
        var ta2 = e1 + o
        if in_grid(ta2):
            add_unique(ga, ta2)
    if enraged:
        for o in [Vector2(sp, 0), Vector2(-sp, 0), Vector2(0, sp), Vector2(0, -sp)]:
            var ta3 = e1 + o
            if in_grid(ta3):
                add_unique(ga, ta3)

    # BLAST B - light surge at the SECOND stop. Long cross plus diagonals.
    var gb = [e2]
    var arm = BULB_SURGE_LEN
    var diag = BULB_SURGE_DIAG
    if enraged:
        arm = BULB_SURGE_LEN_RAGE
        diag = BULB_SURGE_DIAG_RAGE
    for d in DIRS:
        for i in range(1, arm + 1):
            var tb = e2 + d * i
            if in_grid(tb):
                add_unique(gb, tb)
    for o in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
        for i in range(1, diag + 1):
            var tb2 = e2 + o * i
            if in_grid(tb2):
                add_unique(gb, tb2)

    bulb_blasts = [
        {"kind": "shatter", "tiles": ga, "center": e1, "fx": "glass", "mult": 1.0},
        {"kind": "surge", "tiles": gb, "center": e2, "fx": "glass", "mult": 1.0},
    ]
    swing_groups = [bulb_blasts[0], bulb_blasts[1]]
    swing_tiles = []
    for t in ga:
        add_unique(swing_tiles, t)
    for t in gb:
        add_unique(swing_tiles, t)
    for t in lunge_tiles:
        unmark(t)
    trim_swing_for_escape(reach, BULB_SAFE_FRAC, BULB_MIN_SAFE)
    pattern_label = "SHATTER + SURGE"
    strike_mult = 1.0


# ---- shared AI helpers ----

func unmark(t):
    swing_tiles.erase(t)
    for g in swing_groups:
        g["tiles"].erase(t)


func add_unique(list, t):
    if not list.has(t):
        list.append(t)


func best_dir8_from(pos):
    var d = player_pos - pos
    var options = []
    for v in DIRS8:
        if in_grid(pos + v):
            options.append(v)
    if options.empty():
        return DIRS8[0]
    if d == Vector2(0, 0):
        return options[randi() % options.size()]
    var dn = d.normalized()
    var best = options[0]
    var best_s = -2.0
    for v in options:
        var sc = dn.dot(v.normalized())
        if sc > best_s:
            best_s = sc
            best = v
    return best


func rand_dir8_from(pos):
    var options = []
    for v in DIRS8:
        if in_grid(pos + v):
            options.append(v)
    if options.empty():
        return Vector2(0, 1)
    return options[randi() % options.size()]


func slide_tiles(from, dvec, n):
    var out = []
    for i in range(1, n + 1):
        var t = from + dvec * i
        if not in_grid(t):
            break
        out.append(t)
    return out


func random_scatter(n):
    var tiles = []
    var tries = 0
    while tiles.size() < n and tries < 700:
        tries += 1
        var t = Vector2(randi() % C.GRID, randi() % C.GRID)
        if t == enemy_pos:
            continue
        var ok = true
        for o in tiles:
            if max(abs(o.x - t.x), abs(o.y - t.y)) < 2:
                ok = false
                break
        if ok:
            tiles.append(t)
    return tiles


func count_safe(reach):
    var n = 0
    for t in reach:
        if not swing_tiles.has(t) and not lunge_tiles.has(t):
            n += 1
    return n


func count_safe_from_lunge(reach):
    var n = 0
    for t in reach:
        if not lunge_tiles.has(t):
            n += 1
    return n


func trim_swing_for_escape(reach, frac, min_safe):
    var want = int(max(min_safe, ceil(reach.size() * frac)))
    var guard = 0
    while count_safe(reach) < want and guard < 90:
        guard += 1
        var cand = []
        for t in reach:
            if swing_tiles.has(t):
                cand.append(t)
        if cand.empty():
            return
        unmark(cand[randi() % cand.size()])


func reachable_tiles():
    var out = []
    var steps = player_steps()
    var visited = {}
    visited[player_pos] = 0
    var queue = [player_pos]
    while queue.size() > 0:
        var cur = queue.pop_front()
        out.append(cur)
        if visited[cur] >= steps:
            continue
        for d in DIRS:
            var n = cur + d
            if in_grid(n) and not visited.has(n) and n != enemy_pos:
                visited[n] = visited[cur] + 1
                queue.append(n)
    return out


# ---------------- player turn ----------------

func end_telegraph():
    show_lunge_t = 0.0
    show_swing_t = 0.0
    phase = PH_MOVE
    enter_move()


func enter_move():
    sub_state = "move"
    calc_move_tiles()
    cursor = player_pos
    update_ui()


func enter_action():
    sub_state = "action"
    target_tiles = []
    update_ui()


func calc_move_tiles():
    move_tiles = []
    var steps = player_steps()
    var visited = {}
    visited[player_pos] = 0
    var queue = [player_pos]
    while queue.size() > 0:
        var cur = queue.pop_front()
        move_tiles.append(cur)
        if visited[cur] >= steps:
            continue
        for d in DIRS:
            var n = cur + d
            if in_grid(n) and not visited.has(n) and n != enemy_pos:
                visited[n] = visited[cur] + 1
                queue.append(n)


func compute_targets(kind):
    var list = []
    if kind == "baseball":
        var r = C.BASEBALL_RANGE
        for dx in range(-r, r + 1):
            for dy in range(-r, r + 1):
                var m = abs(dx) + abs(dy)
                if m >= C.BASEBALL_MIN and m <= r:
                    var t = player_pos + Vector2(dx, dy)
                    if in_grid(t):
                        list.append(t)
    else:
        for d in DIRS:
            var t = player_pos + d
            if in_grid(t):
                list.append(t)
    return list


func attack_tiles(kind, target):
    var tiles = []
    if kind == "baseball":
        for o in [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
            var t = target + o
            if in_grid(t):
                tiles.append(t)
    elif kind == "saber":
        var dvec = target - player_pos
        var perp = Vector2(dvec.y, dvec.x)
        var half = int(C.SABER_WIDTH / 2)
        for i in range(1, line_range(kind) + 1):
            for w in range(-half, half + 1):
                var t2 = player_pos + dvec * i + perp * w
                if in_grid(t2):
                    tiles.append(t2)
    else:
        var dvec2 = target - player_pos
        for i in range(1, line_range(kind) + 1):
            var t3 = player_pos + dvec2 * i
            if in_grid(t3):
                tiles.append(t3)
    return tiles


func bullseye_tiles(kind, target):
    var out = []
    if kind == "baseball":
        out.append(target)
    else:
        var dvec = target - player_pos
        if kind == "blaster":
            out.append(player_pos + dvec)
        else:
            var n = line_range(kind)
            var lo = int(ceil(n / 2.0))
            var hi = int(floor(n / 2.0)) + 1
            for i in range(lo, hi + 1):
                out.append(player_pos + dvec * i)
    var res = []
    for t in out:
        if in_grid(t):
            res.append(t)
    return res


func nearest_to_enemy(list):
    if list.empty():
        return player_pos
    var best = list[0]
    var best_d = 999
    for t in list:
        var dist = abs(t.x - enemy_pos.x) + abs(t.y - enemy_pos.y)
        if dist < best_d:
            best_d = dist
            best = t
    return best


func deny(i, why):
    deny_index = i
    deny_t = 0.35
    set_banner(why, C.CRUSH, 0.8)
    snd("deny")


func choose_action(i):
    if i < 0 or i >= KINDS.size():
        return
    action_index = i
    var kind = KINDS[i]
    if kind == "item":
        if juice_left <= 0:
            deny(i, "EMPTY")
            return
        juice_left -= 1
        var healed = int(min(C.ITEM_HEAL, max_hp - player_hp))
        player_hp += healed
        float_text("+" + str(healed), player_pos, C.HEAL)
        var cp = tile_center(player_pos)
        add_ring(cp, 10, 70, 0.5, C.HEAL, 4.0, "circle")
        add_cone(cp, Vector2(0, -1), 14, 1.0, 150, C.HEAL, 0.7, 4, -60)
        snd("heal")
        queued_attack = {}
        lock_in()
        return
    if int(reload.get(kind, 0)) > 0:
        deny(i, "RELOADING")
        return
    if int(ammo.get(kind, 0)) <= 0:
        deny(i, "EMPTY")
        return
    current_kind = kind
    target_tiles = compute_targets(kind)
    cursor = nearest_to_enemy(target_tiles)
    sub_state = "target"
    snd("ui")
    update_ui()


func stay_put():
    if sub_state != "action" and sub_state != "target":
        return
    queued_attack = {}
    snd("ui", 0.8)
    lock_in()


func lock_in():
    sub_state = "busy"
    target_tiles = []
    move_tiles = []
    update_ui()
    schedule("step_enemy_move", 0.3)


# ---------------- resolution ----------------

func step_enemy_move():
    phase = PH_ENEMY_MOVE
    update_ui()
    if enemy_type == "bulb":
        bulb_dash_one()
        return
    if lunge_tiles.has(player_pos):
        crush_player()
        return
    var cur = enemy_pos
    var floor_fx = floor_effect()
    enemy_lerp = 20.0
    if enemy_type == "hanger":
        enemy_lerp = 9.0
    for t in lunge_tiles:
        add_effect(cur, floor_fx, 2)
        cur = t
    slide_vfx(enemy_pos, cur, enemy_hit_color())
    enemy_pos = cur
    snd("step", 0.8)
    schedule("step_attack", 0.75)


func slide_vfx(from, to, col):
    var a = tile_center(from)
    var b = tile_center(to)
    if a.distance_to(b) < 1.0:
        return
    var dvec = (b - a).normalized()
    add_cone(a, -dvec, 12, 0.6, 220, col, 0.45, 4, 120)
    add_ring(b, 8, 58, 0.3, col, 3.0, "circle", 0.16)
    add_burst(b, 8, 170, FX_BONE, 0.35, 4, 240, 0.16)
    shake = max(shake, 4.0)


func crush_player():
    enemy_pos = player_pos
    player_hp = 0
    player_flash = 0.5
    shake = 16.0
    push_popup(player_pos, "CRUSHED", [], C.CRUSH)
    big_pop(tile_center(player_pos), C.CRUSH)
    add_burst(tile_center(player_pos), 24, 320, C.CRUSH, 0.7, 6, 300)
    snd("boom")
    kill_player()
    update_ui()
    schedule("step_check", 1.4)


func bulb_dash_one():
    do_bulb_dash(0)


func bulb_dash_two():
    do_bulb_dash(1)


func do_bulb_dash(i):
    if i >= lunge_legs.size():
        schedule("step_attack", 0.2)
        return
    var leg = lunge_legs[i]
    if leg.has(player_pos):
        crush_player()
        return
    if not leg.empty():
        var cur = enemy_pos
        for t in leg:
            add_effect(cur, "glass", 2)
            cur = t
        var col = FX_LEG1
        if i == 1:
            col = FX_LEG2
        slide_vfx(enemy_pos, cur, col)
        enemy_pos = cur
        enemy_lerp = 26.0
        snd("dash", 1.0 + i * 0.22)
    update_ui()
    # dash 1 ALWAYS blasts before dash 2 begins
    if i == 0:
        schedule("bulb_blast_one", BULB_LEG_PAUSE)
    else:
        schedule("step_attack", 0.45)


func bulb_blast_one():
    if bulb_blasts.empty():
        schedule("bulb_dash_two", 0.2)
        return
    bulb_phase = 0
    var g = bulb_blasts[0]
    active_groups = [g]
    active_swing = g["tiles"].duplicate()
    active_mult = g["mult"]
    enemy_anim = {"main": g["kind"], "groups": [g], "origin": enemy_pos, "dir": enemy_dir}
    enemy_anim_t = 0.0
    set_banner("SHATTER", FX_BULB, 0.7)
    snd("glass", 0.85)
    schedule("step_strike_hit", FOE_IMPACT)


# one shared damage roll for whichever blast is currently landing
func resolve_active_hit():
    if not active_swing.has(player_pos):
        return
    if has_mod("foam_armor") and not armor_used:
        armor_used = true
        pulse_mod("foam_armor")
        push_popup(player_pos, "BLOCKED", [{"label": "ARMOR", "color": M.color_of("foam_armor")}], C.HEAL)
        var cpb = tile_center(player_pos)
        add_ring(cpb, 12, 86, 0.45, FX_CYAN, 5.0, "circle")
        add_ring(cpb, 8, 60, 0.32, FX_BONE, 3.0, "circle", 0.04)
        add_burst(cpb, 16, 220, FX_CYAN, 0.5, 5, 180)
        snd("block")
        return
    var lo = hit_min()
    var hi = hit_max()
    var raw = lo + randi() % (hi - lo + 1)
    raw = int(round(raw * active_mult))
    var total = int(max(1, raw))
    var parts = []
    if has_mod("plush"):
        var cut = int(min(PLUSH_CUT, total - 1))
        if cut > 0:
            total -= cut
            parts.append({"label": "PLUSH -" + str(cut), "color": M.color_of("plush")})
            pulse_mod("plush")
    if parts.size() > 0:
        parts.insert(0, {"label": "BASE " + str(raw), "color": C.TEXT_DIM})
    damage_player(total, parts)


func apply_echo():
    if echo.empty():
        return
    var tiles = echo["tiles"]
    attack_flash = tiles
    attack_flash_t = 0.4
    attack_flash_color = FX_STEEL
    for i in range(tiles.size()):
        tile_pop(tiles[i], FX_STEEL, i * 0.02)
    if tiles.has(enemy_pos) and enemy_hp > 0:
        pulse_mod("echo")
        damage_enemy(echo["dmg"], [{"label": "ECHO", "color": M.color_of("echo")}])
    echo = {}


func step_attack():
    phase = PH_RESOLVE
    update_ui()
    apply_echo()
    if queued_attack.empty():
        hit_streak = 0
        schedule("step_strike", 0.35)
        return
    var kind = queued_attack["kind"]
    var adir = queued_attack["dir"]
    var reach = 0
    if kind != "baseball":
        for i in range(1, line_range(kind) + 1):
            if in_grid(player_pos + adir * i):
                reach = i
    attack_anim = {"kind": kind, "from": player_pos, "target": queued_attack["target"], "dir": adir, "tiles": queued_attack["tiles"], "reach": reach}
    attack_anim_t = 0.0

    var muzzle = tile_center(player_pos) + adir * 30.0
    if kind == "blaster":
        add_cone(muzzle, adir, 10, 0.45, 260, FX_CYAN, 0.3, 4, 60)
        add_ring(muzzle, 4, 30, 0.2, FX_BONE, 3.0, "circle")
        snd("shoot")
    elif kind == "baseball":
        add_ring(tile_center(player_pos), 6, 34, 0.24, FX_BONE, 2.0, "circle")
        snd("lob")
    else:
        add_ring(muzzle, 6, 46, 0.26, FX_MAGENTA, 4.0, "circle")
        add_cone(muzzle, adir, 12, 0.5, 240, C.SABER, 0.4, 4, -40)
        snd("saber")
    schedule("step_attack_hit", TOY_IMPACT)


func spread_effect(tiles, type):
    for t in tiles:
        for d in DIRS:
            var n = t + d
            if in_grid(n) and not tiles.has(n) and n != player_pos:
                add_effect(n, type, 2)


func attack_anim_reach():
    if attack_anim.empty():
        return 1
    return max(1, int(attack_anim["reach"]))


func step_attack_hit():
    var kind = queued_attack["kind"]
    var tiles = queued_attack["tiles"]
    attack_flash = tiles
    attack_flash_t = 0.4
    if kind == "blaster":
        attack_flash_color = C.DART_TIP
    elif kind == "baseball":
        attack_flash_color = FX_BONE
    else:
        attack_flash_color = C.SABER

    if kind == "blaster":
        for i in range(tiles.size()):
            var cp = tile_center(tiles[i])
            var dl = i * 0.035
            add_ring(cp, 6, 34, 0.26, FX_CYAN, 3.0, "circle", dl)
            add_burst(cp, 4, 130, C.DART_TIP, 0.3, 4, 220, dl)
            add_burst(cp, 3, 90, FX_BONE, 0.34, 3, 120, dl)
        snd("crack", 1.5)
    elif kind == "baseball":
        var ctr = tile_center(queued_attack["target"])
        big_pop(ctr, FX_BONE)
        add_ring(ctr, 14, 120, 0.5, FX_EMBER, 4.0, "circle", 0.05)
        add_cone(ctr, Vector2(0, -1), 18, 1.3, 240, FX_STEEL, 0.6, 5, 420)
        for i in range(tiles.size()):
            tile_pop(tiles[i], FX_BONE, 0.03 + i * 0.03)
        add_wash(FX_BONE, 0.2, 0.22)
        add_hitstop(0.05)
        shake = max(shake, 8.0)
        snd("crack")
    else:
        var dvec = queued_attack["dir"]
        var origin = tile_center(player_pos)
        var tip = origin + dvec * (attack_anim_reach() * C.TILE)
        var ang = atan2(dvec.y, dvec.x)
        add_arc(tip, ang - 1.1, ang + 1.1, 46, 0.3, FX_BONE, 6.0)
        add_arc(tip, ang - 0.9, ang + 0.9, 62, 0.36, FX_MAGENTA, 4.0, 0.04)
        for i in range(tiles.size()):
            var cp2 = tile_center(tiles[i])
            var dl2 = (abs(tiles[i].x - player_pos.x) + abs(tiles[i].y - player_pos.y)) * 0.022
            add_ring(cp2, 6, 38, 0.28, C.SABER, 3.0, "square", dl2)
            add_cone(cp2, Vector2(0, -1), 4, 0.8, 130, FX_MAGENTA, 0.5, 4, -90, dl2)
        add_wash(C.SABER, 0.18, 0.24)
        shake = max(shake, 7.0)
        snd("crack", 0.8)

    var base_dmg = attack_dmg(kind)
    var total = base_dmg
    var parts = []

    if tiles.has(enemy_pos):
        hit_streak += 1
        if has_mod("duct_tape"):
            total += TAPE_DMG
            parts.append({"label": "TAPE +" + str(TAPE_DMG), "color": M.color_of("duct_tape")})
            pulse_mod("duct_tape")
        if has_mod("fixation") and hit_streak > 1:
            var bonus = int(min(FIX_STEP * (hit_streak - 1), FIX_MAX))
            total += bonus
            parts.append({"label": "FIX +" + str(bonus), "color": M.color_of("fixation")})
            pulse_mod("fixation")
        var crit = bullseye_tiles(kind, queued_attack["target"]).has(enemy_pos)
        if crit:
            var mult = crit_mult()
            total = int(round(total * mult))
            if has_mod("lucky"):
                pulse_mod("lucky")
            parts.append({"label": "BULLSEYE x" + str(mult), "color": C.BULLSEYE_COL})
        if parts.size() > 0:
            parts.insert(0, {"label": "BASE " + str(base_dmg), "color": C.TEXT_DIM})
        damage_enemy(total, parts, crit)
    else:
        hit_streak = 0
        float_text("MISS", enemy_pos, C.TEXT_DIM)

    for t in tiles:
        if kind == "blaster":
            add_effect(t, "slow", 2)
        elif kind == "saber":
            add_effect(t, "burn", 2)
    if has_mod("ripple"):
        if kind == "blaster":
            spread_effect(tiles, "slow")
            pulse_mod("ripple")
        elif kind == "saber":
            spread_effect(tiles, "burn")
            pulse_mod("ripple")
    if has_mod("echo"):
        echo = {"tiles": tiles, "dmg": int(total / 2)}
        pulse_mod("echo")

    ammo[kind] = int(max(0, int(ammo.get(kind, 0)) - 1))
    if ammo[kind] <= 0:
        reload[kind] = reload_of(kind) + 1
        snd("reload", 0.85)

    schedule("step_strike", 0.7)


func step_strike():
    if enemy_hp <= 0:
        schedule("step_check", 0.3)
        return
    enemy_lerp = 12.0
    if enemy_type == "bulb":
        if bulb_blasts.size() < 2:
            schedule("step_check", 0.3)
            return
        bulb_phase = 1
        var gb = bulb_blasts[1]
        active_groups = [gb]
        active_swing = gb["tiles"].duplicate()
        active_mult = gb["mult"]
        enemy_anim = {"main": gb["kind"], "groups": [gb], "origin": enemy_pos, "dir": enemy_dir}
        enemy_anim_t = 0.0
        set_banner("SURGE", FX_BULB, 0.7)
        snd("saber", 0.6)
        schedule("step_strike_hit", FOE_IMPACT)
        return
    active_groups = []
    active_swing = swing_tiles.duplicate()
    active_mult = strike_mult
    var main_kind = "none"
    if swing_groups.size() > 0:
        main_kind = swing_groups[0]["kind"]
    var groups = []
    for g in swing_groups:
        var copy = {"kind": g["kind"], "tiles": g["tiles"].duplicate(), "center": g["center"], "fx": g.get("fx", "")}
        groups.append(copy)
        active_groups.append(copy)
    enemy_anim = {"main": main_kind, "groups": groups, "origin": enemy_pos, "dir": enemy_dir}
    enemy_anim_t = 0.0
    if enemy_type == "hanger":
        snd("acid", 0.9)
    else:
        snd("dash", 0.75)
    schedule("step_strike_hit", FOE_IMPACT)


func step_strike_hit():
    for g in active_groups:
        var k = g["kind"]
        if k == "charge":
            for i in range(g["tiles"].size()):
                var cp = tile_center(g["tiles"][i])
                var dl = i * 0.05
                add_ring(cp, 8, 46, 0.3, FX_EMBER, 3.0, "square", dl)
                add_burst(cp, 6, 190, C.RUST, 0.4, 5, 300, dl)
                add_burst(cp, 3, 150, FX_BONE, 0.3, 3, 200, dl)
            shake = max(shake, 7.0)
            snd("crack", 0.7)
        elif k == "sweep":
            var oc = tile_center(g["center"])
            add_ring(oc, 14, 130, 0.44, FX_EMBER, 5.0, "circle")
            add_arc(oc, 0, TAU * 0.75, 96, 0.36, FX_BONE, 4.0, 0.03)
            for tl in g["tiles"]:
                add_burst(tile_center(tl), 5, 180, C.RUST, 0.4, 5, 280, 0.06)
            shake = max(shake, 8.0)
            snd("crack", 0.6)
        elif k == "drip":
            for i in range(g["tiles"].size()):
                var cp2 = tile_center(g["tiles"][i])
                var dl2 = float(i % 5) * 0.05
                add_ring(cp2, 6, 40, 0.3, C.GOO, 3.0, "circle", dl2)
                add_cone(cp2, Vector2(0, -1), 5, 1.0, 140, C.GOO, 0.45, 4, 420, dl2)
            snd("acid", 1.2)
        elif k == "spray":
            for i in range(g["tiles"].size()):
                var cp3 = tile_center(g["tiles"][i])
                add_ring(cp3, 6, 40, 0.28, FX_ACID, 3.0, "square", i * 0.02)
                add_cone(cp3, Vector2(0, -1), 4, 0.9, 150, FX_ACID, 0.5, 4, 300, i * 0.02)
            add_wash(FX_ACID, 0.14, 0.24)
            snd("acid")
        elif k == "splat":
            var cs = tile_center(g["center"])
            big_pop(cs, FX_ACID)
            add_ring(cs, 16, 150, 0.55, FX_ACID, 4.0, "diamond", 0.05)
            add_cone(cs, Vector2(0, -1), 16, 1.4, 220, FX_ACID, 0.6, 5, 420)
            add_wash(FX_ACID, 0.2, 0.26)
            shake = max(shake, 8.0)
            snd("boom", 1.3)
        elif k == "bloom":
            var cb = tile_center(g["center"])
            add_ring(cb, 12, 160, 0.5, C.GOO, 5.0, "diamond")
            add_arc(cb, 0, TAU * 0.8, 110, 0.4, FX_BONE, 3.0, 0.04)
            for tl in g["tiles"]:
                add_burst(tile_center(tl), 4, 160, C.GOO, 0.4, 4, 300, 0.08)
            snd("acid", 0.8)
        elif k == "cross":
            var cc = tile_center(g["center"])
            big_pop(cc, FX_ACID)
            add_ring(cc, 18, 200, 0.6, FX_BONE, 3.0, "circle", 0.06)
            add_wash(FX_ACID, 0.22, 0.28)
            shake = max(shake, 9.0)
            snd("boom", 1.5)
        elif k == "shatter":
            var csh = tile_center(g["center"])
            big_pop(csh, FX_BULB)
            add_ring(csh, 20, 190, 0.55, FX_BONE, 3.0, "circle", 0.05)
            add_burst(csh, 26, 320, FX_BULB, 0.7, 5, 260)
            for tl in g["tiles"]:
                tile_pop(tl, FX_BULB, 0.04)
            add_wash(FX_BULB, 0.32, 0.3)
            add_hitstop(0.07)
            shake = max(shake, 12.0)
            snd("glass")
            snd("boom", 1.2)
        elif k == "surge":
            var csu = tile_center(g["center"])
            big_pop(csu, FX_BULB)
            add_ring(csu, 22, 250, 0.7, FX_BULB, 4.0, "circle", 0.06)
            for d in DIRS8:
                add_cone(csu, d, 7, 0.24, 340, FX_BONE, 0.5, 4, 0, 0.05)
            for tl in g["tiles"]:
                tile_pop(tl, FX_BULB, 0.03)
            add_wash(FX_BULB, 0.36, 0.32)
            add_hitstop(0.07)
            shake = max(shake, 13.0)
            snd("boom")

    resolve_active_hit()

    if enemy_type == "hanger":
        for g in active_groups:
            var fx = g.get("fx", "")
            if fx == "":
                continue
            var pool = g["tiles"].duplicate()
            var placed = 0
            while pool.size() > 0 and placed < RESIDUE_CAP:
                var i = randi() % pool.size()
                var t = pool[i]
                pool.remove(i)
                add_effect(t, fx, 2)
                placed += 1
    elif enemy_type == "bulb":
        # both blasts litter the floor with glass, plus a spray around the centre
        for g in active_groups:
            for t in g["tiles"]:
                add_effect(t, "glass", 2)
            var ctr = g["center"]
            var sprayed = 0
            var tries = 0
            while sprayed < BULB_GLASS_SPRAY and tries < 40:
                tries += 1
                var off = Vector2(randi() % 5 - 2, randi() % 5 - 2)
                var t2 = ctr + off
                if in_grid(t2) and effect_at(t2) != "glass":
                    add_effect(t2, "glass", 2)
                    sprayed += 1
    else:
        for g in active_groups:
            var fx2 = g.get("fx", "")
            if fx2 == "":
                continue
            for t in g["tiles"]:
                add_effect(t, fx2, 2)

    # after the FIRST boss blast, the second dash still has to happen
    if enemy_type == "bulb" and bulb_phase == 0:
        if player_hp <= 0:
            schedule("step_check", 0.9)
        else:
            schedule("bulb_dash_two", 0.5)
        return
    schedule("step_tick", 0.6)


func step_tick():
    phase = PH_TICK
    for pos in effects.keys():
        var e = effects[pos]
        var ty = e["type"]
        if ty == "rust":
            if pos == player_pos:
                damage_player(C.RUST_DMG, [{"label": "RUST", "color": C.RUST}])
        elif ty == "glass":
            if pos == player_pos:
                damage_player(GLASS_DMG, [{"label": "GLASS", "color": FX_GLASS}])
        elif ty == "acid":
            if pos == player_pos:
                damage_player(ACID_DMG, [{"label": "ACID", "color": FX_ACID}])
        elif ty == "burn":
            if pos == player_pos:
                damage_player(C.BURN_DMG, [{"label": "BURN", "color": C.BURN}])
            if pos == enemy_pos and enemy_hp > 0:
                damage_enemy(C.BURN_DMG, [{"label": "BURN", "color": C.BURN}])
        e["turns"] -= 1
        if e["turns"] <= 0:
            effects.erase(pos)

    for k in TOYS:
        if int(reload.get(k, 0)) > 0:
            reload[k] = int(reload[k]) - 1
            if reload[k] <= 0:
                reload[k] = 0
                ammo[k] = uses_of(k)
                snd("reload", 1.15)

    if has_mod("comfort") and not damaged_this_round and player_hp > 0 and player_hp < max_hp:
        var h = int(min(COMFORT_HEAL, max_hp - player_hp))
        player_hp += h
        pulse_mod("comfort")
        float_text("+" + str(h), player_pos, M.color_of("comfort"))
        add_cone(tile_center(player_pos), Vector2(0, -1), 8, 0.9, 110, C.HEAL, 0.6, 3, -50)
        snd("heal", 1.2)

    queued_attack = {}
    update_ui()
    schedule("step_check", 0.55)


func step_check():
    phase = PH_CHECK
    update_ui()
    if enemy_hp <= 0:
        set_banner("VICTORY", C.HEAL)
        snd("win")
        schedule("go_win", 1.5)
    elif player_hp <= 0:
        set_banner("DEFEATED", C.CRUSH)
        schedule("go_lose", 1.2)
    else:
        round_num += 1
        start_round()


func go_win():
    if result != "":
        return
    result = "win"
    run["rounds"] = run.get("rounds", 0) + round_num
    var par = get_parent()
    if par != null and par.has_method("battle_won"):
        par.battle_won(player_hp)
    elif par != null and par.has_method("switch_to"):
        par.switch_to("win")


func go_lose():
    if result != "":
        return
    result = "lose"
    var par = get_parent()
    if par != null and par.has_method("switch_to"):
        par.switch_to("gameover")


# ---------------- input ----------------

func sound_rect():
    return Rect2(PX + PW - 92, 10, 66, 22)


func help_rect():
    return Rect2(PX + PW - 20, 10, 20, 22)


func toggle_sound():
    sound_on = not sound_on
    var par = get_parent()
    if par != null and par.has_method("set_sound"):
        par.set_sound(sound_on)
    elif sfx != null:
        sfx.set_enabled(sound_on)
    update()


func _input(event):
    if event is InputEventKey and event.pressed and not event.echo:
        handle_key(event.scancode)
    elif event is InputEventMouseMotion:
        handle_hover(get_local_mouse_position())
    elif event is InputEventMouseButton and event.pressed:
        if event.button_index == BUTTON_LEFT:
            handle_click(get_local_mouse_position())
        elif event.button_index == BUTTON_RIGHT:
            go_back()


func handle_key(code):
    if code == KEY_M:
        toggle_sound()
        return
    if code == KEY_R:
        var par = get_parent()
        if par != null and par.has_method("restart_run"):
            par.restart_run()
        return
    if code == KEY_H or code == KEY_SLASH or code == KEY_QUESTION:
        toggle_help()
        return
    if help_open:
        if code == KEY_ESCAPE or code == KEY_SPACE or code == KEY_ENTER:
            toggle_help()
        return
    if in_cutscene():
        if code == KEY_SPACE or code == KEY_ENTER or code == KEY_ESCAPE:
            end_cutscene()
        return
    var dvec = Vector2(0, 0)
    if code == KEY_W or code == KEY_UP:
        dvec = Vector2(0, -1)
    elif code == KEY_S or code == KEY_DOWN:
        dvec = Vector2(0, 1)
    elif code == KEY_A or code == KEY_LEFT:
        dvec = Vector2(-1, 0)
    elif code == KEY_D or code == KEY_RIGHT:
        dvec = Vector2(1, 0)
    if dvec != Vector2(0, 0):
        move_cursor(dvec)
    elif code == KEY_SPACE or code == KEY_ENTER:
        confirm()
    elif code == KEY_ESCAPE or code == KEY_BACKSPACE:
        go_back()
    elif code == KEY_0 or code == KEY_Q:
        stay_put()
    elif code >= KEY_1 and code <= KEY_4:
        if sub_state == "action":
            choose_action(code - KEY_1)


func step_in(list, from, dvec):
    var n = from + dvec
    if list.has(n):
        return n
    n = from + dvec * 2
    if list.has(n):
        return n
    return from


func move_cursor(dvec):
    if sub_state == "move":
        cursor = step_in(move_tiles, cursor, dvec)
    elif sub_state == "action":
        if dvec.y != 0:
            action_index = (action_index + int(dvec.y) + ACTIONS.size()) % ACTIONS.size()
            update()
    elif sub_state == "target":
        if current_kind == "baseball":
            cursor = step_in(target_tiles, cursor, dvec)
        else:
            var n = player_pos + dvec
            if target_tiles.has(n):
                cursor = n


func confirm():
    if sub_state == "move":
        if not move_tiles.has(cursor):
            return
        move_origin = player_pos
        last_move = cursor - player_pos
        if cursor != player_pos:
            snd("step", 1.5)
            add_burst(tile_center(player_pos), 5, 90, FX_STEEL, 0.3, 3, 200)
        player_pos = cursor
        move_tiles = []
        enter_action()
    elif sub_state == "action":
        choose_action(action_index)
    elif sub_state == "target":
        if not target_tiles.has(cursor):
            return
        var dvec = Vector2(0, 0)
        if current_kind != "baseball":
            dvec = cursor - player_pos
        queued_attack = {"kind": current_kind, "target": cursor, "dir": dvec, "tiles": attack_tiles(current_kind, cursor)}
        lock_in()


func go_back():
    if in_cutscene() or help_open:
        return
    if sub_state == "target":
        target_tiles = []
        enter_action()
    elif sub_state == "action":
        player_pos = move_origin
        last_move = Vector2(0, 0)
        enter_move()


func pos_to_tile(p):
    var rel = p - C.GRID_OFFSET
    var t = Vector2(floor(rel.x / C.TILE), floor(rel.y / C.TILE))
    if in_grid(t):
        return t
    return null


func resolve_target(t):
    if sub_state == "move":
        if move_tiles.has(t):
            return t
        return null
    if sub_state == "target":
        if current_kind == "saber":
            var sd = t - player_pos
            var ax = abs(sd.x)
            var ay = abs(sd.y)
            var sdir = Vector2(0, 0)
            if ax >= 1 and ay <= 1 and ax >= ay:
                sdir = Vector2(sign(sd.x), 0)
            elif ay >= 1 and ax <= 1:
                sdir = Vector2(0, sign(sd.y))
            if sdir != Vector2(0, 0) and max(ax, ay) <= line_range(current_kind) and target_tiles.has(player_pos + sdir):
                return player_pos + sdir
            return null
        if current_kind != "baseball":
            var d = t - player_pos
            if (d.x == 0) != (d.y == 0) and max(abs(d.x), abs(d.y)) <= line_range(current_kind):
                var first = player_pos + Vector2(sign(d.x), sign(d.y))
                if target_tiles.has(first):
                    return first
            return null
        if target_tiles.has(t):
            return t
    return null


func menu_rect(i):
    return Rect2(PX, 242 + i * 58, PW, 52)


func stay_rect():
    return Rect2(PX, 478, PW, 30)


func menu_index_at(p):
    for i in range(ACTIONS.size()):
        if menu_rect(i).has_point(p):
            return i
    return -1


func gear_spent(id):
    if id == "foam_armor" and armor_used:
        return true
    if id == "echo" and echo.empty():
        return true
    return false


func gear_layout():
    var out = []
    if f8 == null:
        return out
    var bx = PX
    var by = 550
    var row = 0
    for id in mods:
        var w = f8.get_string_size(M.short_of(id)).x + 18
        if bx + w > PX + PW:
            row += 1
            if row >= 2:
                break
            by += 22
            bx = PX
        out.append({"id": id, "rect": Rect2(bx, by, w, 18)})
        bx += w + 6
    return out


func handle_hover(p):
    var prev = hover_mod
    hover_mod = ""
    for g in gear_layout():
        if g["rect"].has_point(p):
            hover_mod = g["id"]
    if prev != hover_mod:
        update()
    if help_open or in_cutscene():
        return
    if p.x >= C.PANEL_X:
        if sub_state == "action":
            var mi = menu_index_at(p)
            if mi >= 0:
                action_index = mi
        return
    var t = pos_to_tile(p)
    if t == null:
        return
    var v = resolve_target(t)
    if v != null:
        cursor = v


func handle_click(p):
    if sound_rect().has_point(p):
        toggle_sound()
        return
    if help_rect().has_point(p):
        toggle_help()
        return
    if help_open:
        toggle_help()
        return
    if in_cutscene():
        end_cutscene()
        return
    if p.x >= C.PANEL_X:
        if sub_state == "action" or sub_state == "target":
            if stay_rect().has_point(p):
                stay_put()
                return
        if sub_state == "action":
            var mi = menu_index_at(p)
            if mi >= 0:
                choose_action(mi)
        return
    var t = pos_to_tile(p)
    if t == null:
        return
    var v = resolve_target(t)
    if v == null:
        return
    cursor = v
    confirm()


# ---------------- per-frame ----------------

func _process(raw_delta):
    if help_open:
        update()
        return

    var delta = raw_delta
    if hitstop > 0.0:
        hitstop -= raw_delta
        delta = raw_delta * 0.14

    anim_t += delta
    if banner_t > 0.0:
        banner_t -= raw_delta
    if deny_t > 0.0:
        deny_t -= raw_delta
    if wash_t > 0.0:
        wash_t -= raw_delta
    if hurt_t > 0.0:
        hurt_t -= raw_delta
    for id in mod_pulse.keys():
        mod_pulse[id] -= raw_delta
        if mod_pulse[id] <= 0.0:
            mod_pulse.erase(id)

    player_hp_vis = lerp(player_hp_vis, float(player_hp), min(1.0, delta * 6.0))
    enemy_hp_vis = lerp(enemy_hp_vis, float(enemy_hp), min(1.0, delta * 6.0))
    show_lunge_t = max(0.0, show_lunge_t - delta)
    show_swing_t = max(0.0, show_swing_t - delta)
    if attack_flash_t > 0.0:
        attack_flash_t -= delta
    if not attack_anim.empty():
        attack_anim_t += delta
        if attack_anim_t > TOY_ANIM:
            attack_anim = {}
    if player_flash > 0.0:
        player_flash -= delta
    if enemy_flash > 0.0:
        enemy_flash -= delta
    if player_dead:
        player_dead_t += delta
    if enemy_dead:
        enemy_dead_t += delta
    if shake > 0.0:
        shake = max(0.0, shake - delta * 28.0)
    if cutscene_flash > 0.0:
        cutscene_flash = max(0.0, cutscene_flash - delta * 2.2)

    player_vis = player_vis.linear_interpolate(player_pos, min(1.0, delta * 16.0))
    enemy_vis = enemy_vis.linear_interpolate(enemy_pos, min(1.0, delta * enemy_lerp))
    if player_vis.distance_to(player_pos) < 0.02:
        player_vis = player_pos
    if enemy_vis.distance_to(enemy_pos) < 0.02:
        enemy_vis = enemy_pos
    if crit_t > 0.0:
        crit_t -= delta
    if not enemy_anim.empty():
        enemy_anim_t += delta
        if enemy_anim_t > FOE_ANIM:
            enemy_anim = {}
    if enemy_vis != enemy_pos and not enemy_dead and boss_revealed:
        trail.append({"pos": enemy_vis, "t": 0.0})
    var keep_trail = []
    for g in trail:
        g["t"] += delta
        if g["t"] < 0.32:
            keep_trail.append(g)
    trail = keep_trail

    idle_t -= delta
    if idle_t <= 0.0 and not enemy_dead and boss_revealed:
        idle_t = 0.45
        spawn_idle()

    var keep = []
    for f in floaters:
        f["t"] += delta * 1.4
        if f["t"] < 1.0:
            keep.append(f)
    floaters = keep
    var keep_pop = []
    for q in popups:
        q["t"] += delta
        if q["t"] < 1.25:
            keep_pop.append(q)
    popups = keep_pop

    var kr = []
    for r in rings:
        if r["delay"] > 0.0:
            r["delay"] -= delta
        else:
            r["t"] += delta
        if r["t"] < r["life"]:
            kr.append(r)
    rings = kr
    var ka = []
    for a in arcs:
        if a["delay"] > 0.0:
            a["delay"] -= delta
        else:
            a["t"] += delta
        if a["t"] < a["life"]:
            ka.append(a)
    arcs = ka
    var ks = []
    for s in sparks:
        if s["delay"] > 0.0:
            s["delay"] -= delta
        else:
            s["t"] += delta
            var v = s["vel"] + Vector2(0, s["grav"] * delta)
            v = v * (1.0 - min(0.9, 1.6 * delta))
            s["vel"] = v
            s["pos"] = s["pos"] + v * delta
        if s["t"] < s["life"]:
            ks.append(s)
    if ks.size() > 300:
        ks.resize(300)
    sparks = ks

    if in_cutscene():
        tick_cutscene(delta)
        update()
        return

    if next_step != "":
        wait_time -= delta
        if wait_time <= 0.0:
            var m = next_step
            next_step = ""
            call(m)
    update()


# ---------------- draw primitives ----------------

func frame(r, col, w):
    draw_rect(Rect2(r.position.x, r.position.y, r.size.x, w), col)
    draw_rect(Rect2(r.position.x, r.position.y + r.size.y - w, r.size.x, w), col)
    draw_rect(Rect2(r.position.x, r.position.y, w, r.size.y), col)
    draw_rect(Rect2(r.position.x + r.size.x - w, r.position.y, w, r.size.y), col)


func draw_rect_rot(cp, w, h, ang, col):
    var ax = Vector2(cos(ang), sin(ang)) * (w * 0.5)
    var ay = Vector2(-sin(ang), cos(ang)) * (h * 0.5)
    var poly = PoolVector2Array([cp - ax - ay, cp + ax - ay, cp + ax + ay, cp - ax + ay])
    draw_colored_polygon(poly, col)


func draw_star(cp, ro, ri, pts, rot, col):
    var poly = PoolVector2Array()
    for i in range(pts * 2):
        var ang = rot + float(i) * PI / float(pts)
        var rad = ro
        if i % 2 == 1:
            rad = ri
        poly.append(cp + Vector2(cos(ang), sin(ang)) * rad)
    draw_colored_polygon(poly, col)


func draw_glow(cp, rad, col, a):
    draw_circle(cp, rad, alpha(col, a * 0.14))
    draw_circle(cp, rad * 0.68, alpha(col, a * 0.24))
    draw_circle(cp, rad * 0.38, alpha(col, a * 0.5))


func draw_flare(cp, rad, col, a):
    draw_rect(Rect2(round(cp.x - rad), round(cp.y - 2), rad * 2, 4), alpha(col, a))
    draw_rect(Rect2(round(cp.x - 2), round(cp.y - rad), 4, rad * 2), alpha(col, a))
    draw_rect_rot(cp, rad * 1.2, 3, PI * 0.25, alpha(col, a * 0.55))
    draw_rect_rot(cp, rad * 1.2, 3, -PI * 0.25, alpha(col, a * 0.55))


func draw_diamond(cp, rad, col, w):
    var pts = PoolVector2Array([
        cp + Vector2(rad, 0), cp + Vector2(0, rad), cp + Vector2(-rad, 0),
        cp + Vector2(0, -rad), cp + Vector2(rad, 0)])
    draw_polyline(pts, col, w, true)


func _draw():
    var sh = Vector2(0, 0)
    if shake > 0.0:
        sh = Vector2(round(rand_range(-shake, shake)), round(rand_range(-shake, shake)))
    draw_set_transform(sh, 0.0, Vector2(1, 1))
    draw_board()
    draw_set_transform(Vector2(0, 0), 0.0, Vector2(1, 1))
    draw_banner()
    draw_panel()
    if help_open:
        draw_help()


func glyph_for(kind):
    if kind == "sweep":
        return "*"
    if kind == "drip":
        return "o"
    if kind == "splat":
        return "#"
    if kind == "spray":
        return "~"
    if kind == "bloom":
        return "O"
    if kind == "cross":
        return "+"
    if kind == "shatter":
        return "#"
    if kind == "surge":
        return "+"
    if kind == "sag":
        return "-"
    return "!"


func draw_banner():
    if banner_text == "" or banner_t <= 0.0 or f16 == null:
        return
    var fade = clamp(banner_t / 0.3, 0.0, 1.0)
    var w = f16.get_string_size(banner_text).x
    var bx = round(C.GRID_OFFSET.x + (C.GRID * C.TILE - w) * 0.5)
    draw_rect(Rect2(bx - 16, 14, w + 32, 36), Color(0.03, 0.03, 0.06, 0.76 * fade))
    draw_rect(Rect2(bx - 16, 14, w + 32, 2), alpha(banner_color, 0.7 * fade))
    draw_rect(Rect2(bx - 16, 48, w + 32, 2), alpha(banner_color, 0.7 * fade))
    draw_string(f16, Vector2(bx + 2, 42), banner_text, Color(0, 0, 0, 0.6 * fade))
    draw_string(f16, Vector2(bx, 40), banner_text, alpha(banner_color, fade))


func draw_effect(r, type):
    var col = effect_color(type)
    var p = r.position
    draw_rect(r, alpha(col, 0.2))
    if type == "rust":
        for s in SPECKS:
            draw_rect(Rect2(p.x + s.x, p.y + s.y, 6, 6), alpha(col, 0.8))
    elif type == "slow":
        draw_rect(Rect2(p.x + 14, p.y + 18, 14, 5), alpha(C.DART_BODY, 0.9))
        draw_rect(Rect2(p.x + 28, p.y + 18, 5, 5), alpha(C.DART_TIP, 0.9))
        draw_rect(Rect2(p.x + 40, p.y + 40, 14, 5), alpha(C.DART_BODY, 0.9))
        draw_rect(Rect2(p.x + 54, p.y + 40, 5, 5), alpha(C.DART_TIP, 0.9))
    elif type == "goo":
        draw_rect(Rect2(p.x + 12, p.y + 42, 32, 12), alpha(C.GOO, 0.75))
        draw_rect(Rect2(p.x + 28, p.y + 28, 26, 16), alpha(C.GOO, 0.75))
    elif type == "acid":
        var bub = int(anim_t * 4.0) % 3
        draw_rect(Rect2(p.x + 10, p.y + 40, 38, 14), alpha(FX_ACID, 0.7))
        draw_rect(Rect2(p.x + 24, p.y + 28, 28, 14), alpha(FX_ACID, 0.65))
        draw_rect(Rect2(p.x + 18, p.y + 22 - bub * 2, 6, 6), alpha(Color(0.85, 1.0, 0.5), 0.8))
    elif type == "glass":
        draw_line(p + Vector2(16, 50), p + Vector2(24, 32), alpha(col, 0.8), 3.0)
        draw_line(p + Vector2(36, 52), p + Vector2(46, 36), alpha(col, 0.8), 3.0)
        draw_line(p + Vector2(52, 50), p + Vector2(58, 40), alpha(col, 0.6), 2.0)
    else:
        for i in range(3):
            var h = 8 + ((int(anim_t * 6.0) + i) % 3) * 5
            var fx = p.x + 14 + i * 18
            draw_rect(Rect2(fx, p.y + C.TILE - 12 - h, 7, h), alpha(C.BURN, 0.8))


func draw_leg_marker(tile, count, col):
    var cp = tile_center(tile)
    var r = Rect2(round(cp.x) - 14, round(cp.y) - 14, 28, 28)
    draw_rect(r, Color(0.04, 0.04, 0.07, 0.85))
    frame(r, col, 2)
    if count == 1:
        draw_rect(Rect2(round(cp.x) - 3, round(cp.y) - 3, 6, 6), col)
    else:
        draw_rect(Rect2(round(cp.x) - 8, round(cp.y) - 3, 6, 6), col)
        draw_rect(Rect2(round(cp.x) + 2, round(cp.y) - 3, 6, 6), col)


func draw_boss_paths():
    if enemy_type != "bulb":
        return
    if phase != PH_TELEGRAPH or show_lunge_t <= 0.0:
        return
    var elapsed = tele_total - show_lunge_t
    var cols = [FX_LEG1, FX_LEG2]
    var start = tele_origin
    for i in range(lunge_legs.size()):
        var leg = lunge_legs[i]
        if leg.empty():
            continue
        var appear = 0.0
        if i == 1:
            appear = 0.34
        var a = clamp((elapsed - appear) / 0.18, 0.0, 1.0)
        if a <= 0.0:
            start = leg[leg.size() - 1]
            continue
        var col = cols[i]
        var prev = tile_center(start)
        for t in leg:
            var nxt = tile_center(t)
            draw_line(prev, nxt, alpha(col, 0.45 * a), 6.0)
            draw_line(prev, nxt, alpha(FX_BONE, 0.25 * a), 2.0)
            prev = nxt
        start = leg[leg.size() - 1]
    for i in range(leg_ends.size()):
        if lunge_legs[i].empty():
            continue
        var appear2 = 0.0
        if i == 1:
            appear2 = 0.34
        if clamp((elapsed - appear2) / 0.18, 0.0, 1.0) > 0.5:
            draw_leg_marker(leg_ends[i], i + 1, cols[i])


func tele_boost(t, sweep):
    var axis = (t.x + t.y) / float((C.GRID - 1) * 2)
    var d = abs(axis - sweep)
    return clamp(1.0 - d * 7.0, 0.0, 1.0)


func draw_board():
    var gsize = C.GRID * C.TILE
    var org = C.GRID_OFFSET
    var bcol = C.BORDER_DIM
    if phase == PH_TELEGRAPH and show_lunge_t > 0.0:
        bcol = Color(0.62, 0.24, 0.32)
    draw_rect(Rect2(org.x - 8, org.y - 8, gsize + 16, gsize + 16), bcol)
    draw_rect(Rect2(org.x - 5, org.y - 5, gsize + 10, gsize + 10), C.BG)

    for x in range(C.GRID):
        for y in range(C.GRID):
            var r = tile_rect(Vector2(x, y))
            var tcol = C.TILE_A
            if (x + y) % 2 == 1:
                tcol = C.TILE_B
            draw_rect(r, tcol)
            frame(r, C.GRID_LINE, 1)

    for pos in effects.keys():
        draw_effect(tile_rect(pos), effects[pos]["type"])

    if cutscene_dark > 0.0:
        var flick = 1.0
        if int(anim_t * 15.0) % 11 == 0:
            flick = 0.78
        draw_rect(Rect2(org.x - 8, org.y - 8, gsize + 16, gsize + 16), Color(0, 0, 0, 0.9 * cutscene_dark * flick))

    if sub_state == "move":
        for t in move_tiles:
            var rm = tile_rect(t)
            draw_rect(rm, alpha(C.MOVE_COL, 0.18))
            frame(rm, alpha(C.MOVE_COL, 0.65), 2)
    if sub_state == "target":
        for t in target_tiles:
            draw_rect(tile_rect(t), alpha(C.TARGET_COL, 0.1))
        for t in attack_tiles(current_kind, cursor):
            var ra = tile_rect(t)
            draw_rect(ra, alpha(C.PREVIEW_COL, 0.4))
            frame(ra, C.PREVIEW_COL, 3)
        for t in bullseye_tiles(current_kind, cursor):
            draw_crosshair(tile_center(t), tile_rect(t))

    # THE FLASH: the only time the enemy plan is drawn
    var pulse = 0.64 + 0.1 * sin(anim_t * 7.0)
    if show_lunge_t > 0.0 or show_swing_t > 0.0:
        var elapsed = tele_total - show_lunge_t
        var sweep = clamp(elapsed / max(0.001, tele_total), 0.0, 1.0)
        if show_lunge_t > 0.0:
            if enemy_type == "bulb" and lunge_legs.size() > 0:
                var cols = [FX_LEG1, FX_LEG2]
                for i in range(lunge_legs.size()):
                    var appear = 0.0
                    if i == 1:
                        appear = 0.34
                    var a = clamp((elapsed - appear) / 0.18, 0.0, 1.0)
                    if a <= 0.0:
                        continue
                    for t in lunge_legs[i]:
                        var rl = tile_rect(t)
                        var boost = tele_boost(t, sweep)
                        draw_rect(rl, alpha(cols[i], (pulse + boost * 0.3) * a))
                        frame(rl, alpha(cols[i], a), 3)
                        if boost > 0.05:
                            frame(rl.grow(-6), alpha(FX_BONE, boost * 0.7 * a), 2)
                        if f16 != null:
                            draw_string(f16, rl.position + Vector2(C.TILE * 0.5 - 8, 44), "X", alpha(FX_BONE, 0.9 * a))
            else:
                for t in lunge_tiles:
                    var rl2 = tile_rect(t)
                    var boost2 = tele_boost(t, sweep)
                    draw_rect(rl2, alpha(C.CRUSH, pulse + boost2 * 0.3))
                    frame(rl2, C.CRUSH, 3)
                    if boost2 > 0.05:
                        frame(rl2.grow(-6), alpha(FX_BONE, boost2 * 0.7), 2)
                    if f16 != null:
                        draw_string(f16, rl2.position + Vector2(C.TILE * 0.5 - 8, 44), "X", alpha(FX_BONE, 0.9))
        if show_swing_t > 0.0:
            for g in swing_groups:
                for t in g["tiles"]:
                    var rs = tile_rect(t)
                    var boost3 = tele_boost(t, sweep)
                    draw_rect(rs, alpha(C.DANGER, pulse + boost3 * 0.3))
                    frame(rs, C.DANGER, 3)
                    if boost3 > 0.05:
                        frame(rs.grow(-6), alpha(FX_BONE, boost3 * 0.7), 2)
                var mark = g["center"]
                if not g["tiles"].has(mark) and g["tiles"].size() > 0:
                    mark = g["tiles"][0]
                if g["tiles"].has(mark) and f16 != null:
                    var gl = glyph_for(g["kind"])
                    var gw = f16.get_string_size(gl).x
                    var mc = tile_center(mark)
                    draw_string(f16, Vector2(round(mc.x - gw * 0.5), round(mc.y + 6)), gl, C.BG)
        draw_boss_paths()

    if attack_flash_t > 0.0:
        var a3 = clamp(attack_flash_t / 0.4, 0.0, 1.0)
        for t in attack_flash:
            var rf = tile_rect(t)
            draw_rect(rf, alpha(attack_flash_color, 0.5 * a3))
            frame(rf, alpha(FX_BONE, 0.8 * a3), 3)

    var espr = SPRITE_PIPE
    var epal = pal_pipe
    if enemy_type == "hanger":
        espr = SPRITE_HANGER
        epal = pal_hanger
    elif enemy_type == "bulb":
        espr = SPRITE_BULB
        epal = pal_bulb
    for g in trail:
        var ta = 1.0 - g["t"] / 0.32
        draw_rect(tile_rect(g["pos"]).grow(-12), alpha(enemy_hit_color(), 0.3 * ta))
        frame(tile_rect(g["pos"]).grow(-12), alpha(FX_BONE, 0.16 * ta), 2)

    draw_actor(player_vis, SPRITE_PLAYER, pal_player, player_flash > 0.0, 0.0, player_dead, player_dead_t, player_pose())
    if boss_revealed:
        draw_actor(enemy_vis, espr, epal, enemy_flash > 0.0, 0.5, enemy_dead, enemy_dead_t, enemy_pose())

    draw_enemy_anim()
    draw_attack_anim()
    draw_effects()

    if cutscene_flash > 0.0:
        draw_rect(board_rect(), Color(1, 1, 0.92, 0.5 * cutscene_flash))

    if crit_t > 0.0:
        var q = 1.0 - crit_t / 0.6
        var cc = tile_center(crit_tile)
        draw_star(cc, 60 * (0.4 + q), 16 * (0.4 + q), 8, q * 2.0, alpha(C.BULLSEYE_COL, (1.0 - q) * 0.5))
        frame(tile_rect(crit_tile).grow(q * 34.0), alpha(C.BULLSEYE_COL, 1.0 - q), 3)

    if sub_state == "move" or sub_state == "target":
        draw_cursor(tile_rect(cursor), C.ACCENT)

    if wash_t > 0.0:
        var wa = wash_amt * (wash_t / max(0.001, wash_dur))
        draw_rect(board_rect(), alpha(wash_col, wa))
    if hurt_t > 0.0:
        var va = hurt_t / 0.42
        var br = board_rect()
        for i in range(4):
            frame(br.grow(-i * 7), alpha(C.CRUSH, 0.16 * va * (1.0 - i * 0.2)), 7)

    if f12 != null:
        for f in floaters:
            var fa = 1.0 - clamp((f["t"] - 0.55) / 0.45, 0.0, 1.0)
            var fp = f["pos"] + Vector2(0, -round(f["t"] * 30.0))
            var fw = f12.get_string_size(f["text"]).x
            fp.x = round(fp.x - fw * 0.5)
            draw_string(f12, fp + Vector2(1, 1), f["text"], Color(0, 0, 0, 0.6 * fa))
            draw_string(f12, fp, f["text"], alpha(f["color"], fa))

    draw_popups()


func draw_effects():
    for a in arcs:
        if a["delay"] > 0.0:
            continue
        var p = a["t"] / a["life"]
        var al = 1.0 - p
        var a1 = lerp(a["a0"], a["a1"], ease_out(p))
        draw_arc(a["pos"], a["rad"], a["a0"], a1, 40, alpha(a["col"], al * 0.85), a["w"], true)
        draw_arc(a["pos"], a["rad"], a["a0"], a1, 40, alpha(FX_BONE, al * 0.4), max(1.0, a["w"] * 0.35), true)
    for r in rings:
        if r["delay"] > 0.0:
            continue
        var p2 = r["t"] / r["life"]
        var al2 = 1.0 - p2
        var rad = lerp(r["r0"], r["r1"], ease_out(p2))
        var w = max(1.0, r["w"] * (1.0 - p2 * 0.6))
        if r["shape"] == "circle":
            draw_arc(r["pos"], rad, 0, TAU, 44, alpha(r["col"], al2 * 0.9), w, true)
        elif r["shape"] == "diamond":
            draw_diamond(r["pos"], rad, alpha(r["col"], al2 * 0.9), w)
        else:
            frame(Rect2(r["pos"].x - rad, r["pos"].y - rad, rad * 2, rad * 2), alpha(r["col"], al2 * 0.85), w)
    for s in sparks:
        if s["delay"] > 0.0:
            continue
        var p3 = s["t"] / s["life"]
        var al3 = 1.0 - p3
        var sz = max(1.0, s["sz"] * (1.0 - p3 * 0.55))
        if s["tail"]:
            draw_line(s["pos"], s["pos"] - s["vel"] * 0.028, alpha(s["col"], al3 * 0.4), max(1.0, sz * 0.7))
        draw_rect(Rect2(round(s["pos"].x - sz * 0.5), round(s["pos"].y - sz * 0.5), sz, sz), alpha(s["col"], al3))


func draw_popups():
    if f16 == null or f8 == null:
        return
    for q in popups:
        var t = q["t"]
        var a = 1.0 - clamp((t - 0.85) / 0.4, 0.0, 1.0)
        var rise = -round(min(t, 1.0) * 24.0)
        var parts = q["parts"]
        var wmax = f16.get_string_size(q["head"]).x
        for l in parts:
            wmax = max(wmax, f8.get_string_size(l["label"]).x)
        var h = 24 + parts.size() * 11
        var x = round(q["pos"].x - wmax * 0.5)
        var y = round(q["pos"].y + rise)
        x = clamp(x, C.GRID_OFFSET.x, C.GRID_OFFSET.x + C.GRID * C.TILE - wmax)
        draw_rect(Rect2(x - 8, y - 19, wmax + 16, h), Color(0.03, 0.03, 0.06, 0.82 * a))
        frame(Rect2(x - 8, y - 19, wmax + 16, h), alpha(q["color"], 0.45 * a), 1)
        draw_string(f16, Vector2(x + 2, y + 2), q["head"], Color(0, 0, 0, 0.7 * a))
        draw_string(f16, Vector2(x, y), q["head"], alpha(q["color"], a))
        var ly = y + 14
        for l in parts:
            draw_string(f8, Vector2(x, ly), l["label"], alpha(l["color"], a))
            ly += 11


func draw_crosshair(cp, r):
    var col = C.BULLSEYE_COL
    var pulse = 0.7 + 0.2 * sin(anim_t * 6.0)
    frame(r.grow(-8), alpha(col, pulse), 2)
    draw_rect(Rect2(round(cp.x) - 12, round(cp.y) - 2, 24, 4), col)
    draw_rect(Rect2(round(cp.x) - 2, round(cp.y) - 12, 4, 24), col)
    draw_glow(cp, 16, col, 0.4 * pulse)


# ---------------- YOUR TOYS ----------------

func draw_attack_anim():
    if attack_anim.empty():
        return
    var t = attack_anim_t
    var kind = attack_anim["kind"]
    var from_c = tile_center(attack_anim["from"])
    var dvec = attack_anim["dir"]
    if kind == "blaster":
        draw_blaster(t, from_c, dvec, attack_anim["tiles"])
    elif kind == "baseball":
        draw_baseball(t, from_c, tile_center(attack_anim["target"]))
    else:
        draw_saber(t, from_c, dvec, attack_anim["reach"], attack_anim["from"])


func draw_blaster(t, from_c, dvec, tiles):
    var full = max(1, tiles.size()) * C.TILE
    var muzzle = from_c + dvec * 30.0
    var perp = Vector2(-dvec.y, dvec.x)

    var mf = 1.0 - clamp(t / 0.13, 0.0, 1.0)
    if mf > 0.0:
        draw_glow(muzzle, 40 * mf + 12, FX_CYAN, mf)
        draw_star(muzzle, 34 * mf, 9 * mf, 5, t * 14.0, alpha(FX_BONE, mf * 0.95))
        var cone = PoolVector2Array([
            muzzle,
            muzzle + dvec * (70 * mf) + perp * (26 * mf),
            muzzle + dvec * (96 * mf),
            muzzle + dvec * (70 * mf) - perp * (26 * mf)])
        draw_colored_polygon(cone, alpha(FX_CYAN, mf * 0.35))

    for i in range(3):
        var p = clamp((t - i * 0.075) / 0.30, 0.0, 1.0)
        if p <= 0.0 or p >= 1.0:
            continue
        var pos = from_c + dvec * (34 + p * (full - 34))
        var start = from_c + dvec * 34
        draw_line(start, pos, alpha(FX_CYAN, 0.20 * (1.0 - p)), 7.0)
        draw_line(start, pos, alpha(FX_BONE, 0.30 * (1.0 - p)), 2.0)
        for g in range(1, 4):
            var gp = clamp(p - g * 0.055, 0.0, 1.0)
            if gp <= 0.0:
                continue
            draw_dart(from_c + dvec * (34 + gp * (full - 34)), dvec, 0.34 / g)
        draw_dart(pos, dvec, 1.0)
        for b in range(3):
            var bp = clamp(p - b * 0.09, 0.0, 1.0)
            if bp <= 0.0:
                continue
            var bpos = from_c + dvec * (34 + bp * (full - 34)) + perp * (7 + b * 4) * sin(bp * 9.0 + i)
            draw_circle(bpos, 3.0 - b * 0.6, alpha(FX_BONE, 0.4 * (1.0 - bp)))


func draw_dart(pos, dvec, a):
    var px = round(pos.x)
    var py = round(pos.y)
    if dvec.x != 0:
        draw_rect(Rect2(px - 10 - dvec.x * 2, py - 4, 18, 8), alpha(C.DART_BODY, a))
        draw_rect(Rect2(px - 10 - dvec.x * 2, py - 4, 18, 2), alpha(FX_CYAN, a * 0.8))
        draw_rect(Rect2(px + dvec.x * 9 - 4, py - 4, 8, 8), alpha(C.DART_TIP, a))
        draw_rect(Rect2(px + dvec.x * 9 - 2, py - 2, 3, 3), alpha(FX_BONE, a))
    else:
        draw_rect(Rect2(px - 4, py - 10 - dvec.y * 2, 8, 18), alpha(C.DART_BODY, a))
        draw_rect(Rect2(px - 4, py - 10 - dvec.y * 2, 2, 18), alpha(FX_CYAN, a * 0.8))
        draw_rect(Rect2(px - 4, py + dvec.y * 9 - 4, 8, 8), alpha(C.DART_TIP, a))
        draw_rect(Rect2(px - 2, py + dvec.y * 9 - 2, 3, 3), alpha(FX_BONE, a))


func draw_baseball(t, from_c, to_c):
    var wf = 1.0 - clamp(t / 0.12, 0.0, 1.0)
    if wf > 0.0:
        draw_glow(from_c, 30 * wf + 8, FX_BONE, wf * 0.8)
        draw_star(from_c, 26 * wf, 7 * wf, 4, t * 10.0, alpha(FX_BONE, wf * 0.7))

    var p = clamp(t / 0.44, 0.0, 1.0)
    if p >= 1.0:
        return
    var ground = from_c.linear_interpolate(to_c, p)
    var arc_h = sin(p * PI) * 104.0
    var air = Vector2(round(ground.x), round(ground.y - arc_h))

    var sh = 1.0 - sin(p * PI) * 0.55
    draw_rect(Rect2(round(ground.x) - 10 * sh, round(ground.y) + 6, 20 * sh, 5), Color(0, 0, 0, 0.4 * sh))

    for g in range(1, 7):
        var gp = clamp(p - g * 0.035, 0.0, 1.0)
        if gp <= 0.0:
            continue
        var ggr = from_c.linear_interpolate(to_c, gp)
        var ga = sin(gp * PI) * 104.0
        var gpos = Vector2(round(ggr.x), round(ggr.y - ga))
        var al = (1.0 - float(g) / 7.0) * 0.5
        draw_circle(gpos, 9.0 - g * 0.9, alpha(FX_BONE, al * 0.5))
        draw_circle(gpos, 5.0 - g * 0.5, alpha(FX_EMBER, al * 0.4))

    draw_glow(air, 24, FX_BONE, 0.5)
    draw_rect(Rect2(air.x - 7, air.y - 9, 14, 18), FX_BONE)
    draw_rect(Rect2(air.x - 9, air.y - 7, 18, 14), FX_BONE)
    draw_rect(Rect2(air.x - 7, air.y - 9, 14, 4), Color(1, 1, 1))
    var rot = p * TAU * 2.2
    for s in range(2):
        var sa = rot + s * PI
        draw_rect_rot(air + Vector2(cos(sa), sin(sa)) * 5.0, 3, 11, sa + PI * 0.5, alpha(C.CRUSH, 0.9))
    draw_rect(Rect2(air.x - 5, air.y - 6, 3, 3), Color(1, 1, 1))


func draw_saber(t, from_c, dvec, reach, from_tile):
    var full = max(1, reach) * C.TILE
    var e = 1.0
    if t < 0.14:
        e = ease_out(t / 0.14)
    elif t > 0.46:
        e = clamp(1.0 - (t - 0.46) / 0.22, 0.0, 1.0)
    if e <= 0.0:
        return
    var perp = Vector2(-dvec.y, dvec.x)
    var half = int(C.SABER_WIDTH / 2)
    var start = from_c + dvec * 26.0
    var blen = full * e
    var tip = start + dvec * blen
    var ang = atan2(dvec.y, dvec.x)

    for w in range(-half, half + 1):
        if not in_grid(from_tile + perp * w):
            continue
        var lc = from_c + perp * w * C.TILE + dvec * 26.0
        var strength = 0.20
        if w == 0:
            strength = 0.30
        draw_beam(lc, dvec, blen, 74, C.SABER, strength * e)
        draw_beam(lc, dvec, blen, 42, FX_MAGENTA, strength * 0.8 * e)

    var ig = 1.0 - clamp(t / 0.2, 0.0, 1.0)
    if ig > 0.0:
        draw_glow(start, 52 * ig + 14, FX_MAGENTA, ig)
        draw_star(start, 40 * ig, 11 * ig, 6, t * 18.0, alpha(FX_BONE, ig * 0.9))

    draw_beam(start + perp * 3, dvec, blen, 22, FX_CYAN, 0.45 * e)
    draw_beam(start - perp * 3, dvec, blen, 22, FX_MAGENTA, 0.45 * e)
    draw_beam(start, dvec, blen, 20, C.SABER, 0.95 * e)
    draw_beam(start, dvec, blen, 9, FX_BONE, 0.98 * e)

    draw_circle(tip, 11, alpha(C.SABER, 0.9 * e))
    draw_circle(tip, 6, alpha(FX_BONE, 0.95 * e))
    draw_glow(tip, 40, FX_MAGENTA, 0.7 * e)
    if t > 0.10 and t < 0.46:
        var sp = clamp((t - 0.10) / 0.26, 0.0, 1.0)
        var a0 = ang - 1.25
        var a1 = lerp(ang - 1.25, ang + 1.25, ease_out(sp))
        draw_arc(tip, 52, a0, a1, 36, alpha(FX_MAGENTA, 0.6 * (1.0 - sp)), 9.0, true)
        draw_arc(tip, 52, a0, a1, 36, alpha(FX_BONE, 0.7 * (1.0 - sp)), 3.0, true)

    for i in range(7):
        var f = float(i) / 7.0
        if f > e:
            continue
        var ep = start + dvec * (blen * f)
        var wob = sin(anim_t * 9.0 + i * 1.7) * 9.0
        var rise = fmod(anim_t * 46.0 + i * 13.0, 34.0)
        draw_rect(Rect2(round(ep.x + perp.x * wob), round(ep.y + perp.y * wob - rise), 3, 3), alpha(FX_MAGENTA, 0.6 * (1.0 - rise / 34.0)))

    draw_rect_rot(start - dvec * 13, 12, 16, ang, alpha(FX_STEEL, 0.95))
    draw_rect_rot(start - dvec * 13, 5, 16, ang, alpha(FX_BONE, 0.5))


func draw_beam(start, dvec, blen, thick, col, a):
    if blen <= 0.0 or a <= 0.0:
        return
    if dvec.x != 0:
        var x0 = min(start.x, start.x + dvec.x * blen)
        draw_rect(Rect2(x0, start.y - thick * 0.5, blen, thick), alpha(col, a))
    else:
        var y0 = min(start.y, start.y + dvec.y * blen)
        draw_rect(Rect2(start.x - thick * 0.5, y0, thick, blen), alpha(col, a))


# ---------------- THEIR ATTACKS ----------------

func reveal(t, delay, dur):
    return clamp((t - delay) / dur, 0.0, 1.0)


func draw_enemy_anim():
    if enemy_anim.empty():
        return
    var t = enemy_anim_t
    var fade = clamp((FOE_ANIM - t) / 0.26, 0.0, 1.0)
    var oc = tile_center(enemy_anim["origin"])
    var dvec = enemy_anim["dir"]
    for g in enemy_anim["groups"]:
        var kind = g["kind"]
        var tiles = g["tiles"]
        if kind == "charge":
            anim_charge(t, fade, tiles, dvec, oc)
        elif kind == "sweep":
            anim_sweep(t, fade, tiles, oc)
        elif kind == "drip":
            anim_drip(t, fade, tiles)
        elif kind == "spray":
            anim_spray(t, fade, tiles)
        elif kind == "splat":
            anim_splat(t, fade, tiles, g["center"])
        elif kind == "bloom":
            anim_bloom(t, fade, tiles, g["center"])
        elif kind == "cross":
            anim_cross(t, fade, g["center"])
        elif kind == "shatter":
            anim_shatter(t, fade, tiles, g["center"])
        elif kind == "surge":
            anim_surge(t, fade, tiles, g["center"])


func anim_charge(t, fade, tiles, dvec, oc):
    draw_glow(oc, 46, FX_EMBER, 0.5 * fade)
    for i in range(tiles.size()):
        var p = reveal(t, i * 0.055, 0.11)
        if p <= 0.0:
            continue
        var cp = tile_center(tiles[i])
        var w = C.TILE * p
        var lead = 1.0 - clamp((t - i * 0.055 - 0.11) / 0.16, 0.0, 1.0)
        if dvec.x != 0:
            var x0 = cp.x - C.TILE * 0.5
            draw_rect(Rect2(x0, cp.y - 20, w, 40), alpha(C.RUST, 0.35 * fade))
            draw_rect(Rect2(x0, cp.y - 14, w, 28), alpha(C.RUST, 0.95 * fade))
            draw_rect(Rect2(x0, cp.y - 5, w, 10), alpha(FX_EMBER, 0.95 * fade))
            draw_rect(Rect2(x0 + w - 7, cp.y - 18, 7, 36), alpha(FX_BONE, lead * fade))
            draw_rect(Rect2(x0, cp.y - 14, w, 3), alpha(FX_BONE, 0.35 * fade))
        else:
            var y0 = cp.y - C.TILE * 0.5
            draw_rect(Rect2(cp.x - 20, y0, 40, w), alpha(C.RUST, 0.35 * fade))
            draw_rect(Rect2(cp.x - 14, y0, 28, w), alpha(C.RUST, 0.95 * fade))
            draw_rect(Rect2(cp.x - 5, y0, 10, w), alpha(FX_EMBER, 0.95 * fade))
            draw_rect(Rect2(cp.x - 18, y0 + w - 7, 36, 7), alpha(FX_BONE, lead * fade))
            draw_rect(Rect2(cp.x - 14, y0, 3, w), alpha(FX_BONE, 0.35 * fade))
        if lead > 0.1:
            draw_star(cp, 26 * lead, 8 * lead, 4, t * 12.0 + i, alpha(FX_BONE, lead * 0.8 * fade))


func anim_sweep(t, fade, tiles, oc):
    var a2 = t * 19.0
    for k in range(5):
        var trail_a = a2 - k * 0.26
        var al = (1.0 - float(k) / 5.0) * fade
        for s in range(2):
            var ang = trail_a + s * PI
            var arm = oc + Vector2(cos(ang), sin(ang)) * C.TILE * 1.42
            draw_line(oc, arm, alpha(C.RUST, al * 0.55), 15.0 - k * 2.0)
            if k == 0:
                draw_line(oc, arm, alpha(FX_EMBER, al * 0.9), 7.0)
                draw_line(oc, arm, alpha(FX_BONE, al), 3.0)
                draw_glow(arm, 26, FX_EMBER, al * 0.8)
    draw_arc(oc, C.TILE * 1.42, a2 - 1.3, a2, 30, alpha(FX_EMBER, 0.4 * fade), 12.0, true)
    draw_arc(oc, C.TILE * 1.42, a2 + PI - 1.3, a2 + PI, 30, alpha(FX_EMBER, 0.4 * fade), 12.0, true)
    draw_glow(oc, 56, FX_EMBER, 0.7 * fade)
    for tl in tiles:
        var cp = tile_center(tl)
        var ang2 = atan2(cp.y - oc.y, cp.x - oc.x) + PI
        var p2 = reveal(t, ang2 / TAU * 0.36, 0.09)
        if p2 <= 0.0:
            continue
        var hit = 1.0 - clamp((t - ang2 / TAU * 0.36 - 0.09) / 0.2, 0.0, 1.0)
        draw_rect(tile_rect(tl).grow(-4), alpha(C.RUST, 0.8 * fade))
        draw_rect(tile_rect(tl).grow(-16), alpha(FX_EMBER, 0.85 * fade))
        if hit > 0.05:
            draw_star(cp, 34 * hit, 10 * hit, 4, ang2, alpha(FX_BONE, hit * fade))
            frame(tile_rect(tl).grow(-2), alpha(FX_BONE, hit * 0.8 * fade), 3)


func anim_drip(t, fade, tiles):
    for i in range(tiles.size()):
        var cp = tile_center(tiles[i])
        var delay = float(i % 5) * 0.05
        var fp = reveal(t, delay, 0.24)
        if fp > 0.0 and fp < 1.0:
            var y = cp.y - 150.0 * (1.0 - fp)
            var stretch = 1.0 + fp * 0.9
            for g in range(1, 5):
                draw_circle(Vector2(cp.x, y - g * 15.0), 6.0 - g, alpha(C.GOO, 0.3 / g))
            draw_rect(Rect2(round(cp.x) - 6, round(y) - 12 * stretch, 12, 20 * stretch), C.GOO)
            draw_circle(Vector2(round(cp.x), round(y) + 8 * stretch), 7, C.GOO)
            draw_rect(Rect2(round(cp.x) - 2, round(y) - 9 * stretch, 4, 8), alpha(FX_BONE, 0.9))
            draw_glow(Vector2(cp.x, y), 22, C.GOO, 0.6)
        elif fp >= 1.0:
            var sp = reveal(t, delay + 0.24, 0.24)
            var sz = 18.0 + 40.0 * ease_out(sp)
            draw_rect(Rect2(round(cp.x - sz * 0.5), round(cp.y - sz * 0.22), sz, sz * 0.44), alpha(C.GOO, 0.9 * fade))
            draw_rect(Rect2(round(cp.x - sz * 0.26), round(cp.y - sz * 0.14), sz * 0.52, sz * 0.28), alpha(FX_BONE, 0.6 * fade * (1.0 - sp)))
            for k in range(5):
                var ang = -PI * 0.5 + (k - 2) * 0.42
                var dp = cp + Vector2(cos(ang), sin(ang)) * (40.0 * sp) + Vector2(0, 34 * sp * sp)
                draw_circle(dp, 4.0 * (1.0 - sp) + 1.0, alpha(C.GOO, fade * (1.0 - sp)))


func anim_spray(t, fade, tiles):
    for i in range(tiles.size()):
        var ps = reveal(t, i * 0.022, 0.13)
        if ps <= 0.0:
            continue
        var r = tile_rect(tiles[i])
        var cp = tile_center(tiles[i])
        var ins = 3 + (1.0 - ps) * 24.0
        draw_rect(r.grow(-ins), alpha(FX_ACID, 0.85 * fade))
        draw_rect(r.grow(-ins - 13), alpha(Color(0.88, 1.0, 0.55), 0.85 * fade))
        draw_rect(r.grow(-ins - 24), alpha(FX_BONE, 0.7 * fade * ps))
        var hit = 1.0 - clamp((t - i * 0.022 - 0.13) / 0.22, 0.0, 1.0)
        if hit > 0.05:
            draw_glow(cp, 34, FX_ACID, hit * 0.8 * fade)
            for k in range(3):
                var rise = (1.0 - hit) * 40.0 + k * 7.0
                var wob = sin(anim_t * 11.0 + i + k) * 8.0
                draw_circle(Vector2(cp.x + wob, cp.y - rise), 3.5 - k * 0.7, alpha(FX_ACID, hit * fade))


func anim_splat(t, fade, tiles, center):
    var cc = tile_center(center)
    var core = 1.0 - reveal(t, 0.0, 0.3)
    if core > 0.0:
        draw_glow(cc, 110 * (1.0 - core) + 30, FX_ACID, core)
        draw_star(cc, 78 * core, 20 * core, 6, t * 6.0, alpha(FX_BONE, core * 0.8))
    for tl in tiles:
        var ring = abs(tl.x - center.x) + abs(tl.y - center.y)
        var p3 = reveal(t, ring * 0.075, 0.13)
        if p3 <= 0.0:
            continue
        var inset = 3 + (1.0 - p3) * 26.0
        draw_rect(tile_rect(tl).grow(-inset), alpha(FX_ACID, 0.9 * fade))
        draw_rect(tile_rect(tl).grow(-inset - 12), alpha(Color(0.9, 1.0, 0.6), 0.8 * fade))
        var lead = 1.0 - clamp((t - ring * 0.075 - 0.13) / 0.18, 0.0, 1.0)
        if lead > 0.05:
            frame(tile_rect(tl).grow(-inset), alpha(FX_BONE, lead * fade), 3)
    var rp = reveal(t, 0.0, 0.4)
    if rp > 0.0 and rp < 1.0:
        draw_diamond(cc, 30 + 150 * ease_out(rp), alpha(FX_BONE, (1.0 - rp) * 0.6 * fade), 4.0)


func anim_bloom(t, fade, tiles, center):
    var cb = tile_center(center)
    var gr = reveal(t, 0.0, 0.32)
    var rad = C.TILE * BLOOM_RADIUS * ease_out(gr)
    draw_diamond(cb, rad, alpha(C.GOO, 0.85 * fade), 12.0)
    draw_diamond(cb, rad, alpha(FX_BONE, 0.5 * fade), 3.0)
    var spin = t * 5.0
    for k in range(4):
        var a0 = spin + k * PI * 0.5
        draw_arc(cb, rad * 0.78, a0, a0 + 0.8, 22, alpha(C.GOO, 0.55 * fade), 9.0, true)
    draw_glow(cb, 60, C.GOO, 0.6 * fade * (1.0 - gr * 0.5))
    for i in range(tiles.size()):
        var p = reveal(t, 0.16 + i * 0.014, 0.16)
        if p <= 0.0:
            continue
        var r = tile_rect(tiles[i])
        draw_rect(r.grow(-6 - (1.0 - p) * 18), alpha(C.GOO, 0.85 * fade))
        draw_rect(r.grow(-20 - (1.0 - p) * 12), alpha(FX_BONE, 0.45 * fade * p))


func anim_cross(t, fade, center):
    var cc = tile_center(center)
    var gc = reveal(t, 0.0, 0.28)
    var span = C.GRID * C.TILE * ease_out(gc)
    if span <= 0.0:
        return
    var half = span * 0.5
    draw_rect(Rect2(cc.x - half, cc.y - 26, span, 52), alpha(FX_ACID, 0.32 * fade))
    draw_rect(Rect2(cc.x - 26, cc.y - half, 52, span), alpha(FX_ACID, 0.32 * fade))
    draw_rect(Rect2(cc.x - half, cc.y - 15, span, 30), alpha(FX_ACID, 0.8 * fade))
    draw_rect(Rect2(cc.x - 15, cc.y - half, 30, span), alpha(FX_ACID, 0.8 * fade))
    draw_rect(Rect2(cc.x - half, cc.y - 5, span, 10), alpha(FX_BONE, 0.95 * fade))
    draw_rect(Rect2(cc.x - 5, cc.y - half, 10, span), alpha(FX_BONE, 0.95 * fade))
    for d in DIRS:
        var head = cc + d * half
        draw_glow(head, 34, FX_ACID, 0.85 * fade)
        draw_star(head, 22, 7, 4, t * 9.0, alpha(FX_BONE, 0.8 * fade))
    draw_glow(cc, 90, FX_ACID, 0.8 * fade)
    draw_flare(cc, 96 * gc, FX_BONE, 0.7 * fade)


func anim_shatter(t, fade, tiles, center):
    var cs = tile_center(center)
    var core = 1.0 - reveal(t, 0.0, 0.26)
    if core > 0.0:
        draw_glow(cs, 130 * (1.0 - core) + 34, FX_BULB, core)
        draw_star(cs, 96 * core, 24 * core, 8, t * 7.0, alpha(FX_BONE, core))
        draw_flare(cs, 120 * core, FX_BONE, core * 0.8)
    for tl in tiles:
        var ring = max(abs(tl.x - center.x), abs(tl.y - center.y))
        var p4 = reveal(t, ring * 0.07, 0.13)
        if p4 <= 0.0:
            continue
        var ins = 3 + (1.0 - p4) * 24.0
        draw_rect(tile_rect(tl).grow(-ins), alpha(FX_BULB, 0.85 * fade))
        draw_rect(tile_rect(tl).grow(-ins - 14), alpha(FX_BONE, 0.8 * fade))
        var lead = 1.0 - clamp((t - ring * 0.07 - 0.13) / 0.2, 0.0, 1.0)
        if lead > 0.05:
            frame(tile_rect(tl).grow(-ins), alpha(FX_BONE, lead * fade), 3)
        var off = tile_center(tl) - cs
        if off.length() > 1.0:
            var fly = reveal(t, ring * 0.07, 0.36)
            var sp = cs + off.normalized() * (C.TILE * 0.35 + fly * C.TILE * 0.9)
            var ang = fly * 7.0 + ring
            draw_rect_rot(sp, 16, 6, ang, alpha(FX_BULB, fade * (1.0 - fly * 0.4)))
            draw_rect_rot(sp, 16, 2, ang, alpha(FX_BONE, fade * (1.0 - fly * 0.4)))
    var rp = reveal(t, 0.0, 0.45)
    if rp > 0.0 and rp < 1.0:
        draw_arc(cs, 24 + 190 * ease_out(rp), 0, TAU, 44, alpha(FX_BONE, (1.0 - rp) * 0.55 * fade), 4.0, true)


func anim_surge(t, fade, tiles, center):
    var cg = tile_center(center)
    var grow = reveal(t, 0.0, 0.24)
    # every armed direction gets a beam, straight or diagonal
    for dd in DIRS8:
        var n = 0
        for tl in tiles:
            var off = tl - center
            if off == Vector2(0, 0):
                continue
            var along = 0
            if dd.x != 0 and dd.y != 0:
                if sign(off.x) == dd.x and sign(off.y) == dd.y and abs(off.x) == abs(off.y):
                    along = int(abs(off.x))
            elif dd.x != 0:
                if off.y == 0 and sign(off.x) == dd.x:
                    along = int(abs(off.x))
            else:
                if off.x == 0 and sign(off.y) == dd.y:
                    along = int(abs(off.y))
            if along > n:
                n = along
        if n <= 0:
            continue
        var dv = dd.normalized()
        var blen = n * C.TILE * ease_out(grow)
        if dd.x != 0 and dd.y != 0:
            blen = n * C.TILE * 1.414 * ease_out(grow)
        if blen <= 0.0:
            continue
        draw_beam(cg, dv, blen, 50, FX_BULB, 0.28 * fade)
        draw_beam(cg, dv, blen, 28, FX_BULB, 0.72 * fade)
        draw_beam(cg, dv, blen, 11, FX_BONE, 0.95 * fade)
        var head = cg + dv * blen
        draw_glow(head, 38, FX_BULB, 0.9 * fade)
        draw_star(head, 24, 8, 4, t * 11.0, alpha(FX_BONE, 0.85 * fade))
        var pts = PoolVector2Array()
        var perp = Vector2(-dv.y, dv.x)
        for i in range(10):
            var f = float(i) / 9.0
            var wob = sin(f * 15.0 + anim_t * 26.0) * 11.0 * (1.0 - abs(f - 0.5) * 1.2)
            pts.append(cg + dv * (blen * f) + perp * wob)
        draw_polyline(pts, alpha(FX_CYAN, 0.55 * fade), 2.0, true)
    var core = 1.0 - reveal(t, 0.0, 0.34)
    draw_glow(cg, 100, FX_BULB, 0.85 * fade)
    draw_star(cg, 60 + 26 * core, 18, 8, t * 4.0, alpha(FX_BONE, 0.75 * fade))
    draw_flare(cg, 130 * grow, FX_BONE, 0.8 * fade)
    if reveal(t, 0.14, 0.16) > 0.0:
        for tl in tiles:
            draw_rect(tile_rect(tl).grow(-12), alpha(FX_BULB, 0.28 * fade))


# ---------------- poses & sprites ----------------

func player_pose():
    var pose = {"off": Vector2(0, 0), "xs": 1.0, "ys": 1.0, "sway": 0.0}
    if player_dead:
        return pose
    if not attack_anim.empty():
        var a = attack_anim_t
        var k = attack_anim["kind"]
        var d = attack_anim["dir"]
        if k == "blaster":
            var q = sin(clamp(a / 0.2, 0.0, 1.0) * PI)
            pose["off"] = -d * 9.0 * q
            pose["xs"] = 1.0 + 0.08 * q
        elif k == "baseball":
            var q2 = sin(clamp(a / 0.44, 0.0, 1.0) * PI)
            pose["off"] = d * 11.0 * q2 + Vector2(0, -6.0 * q2)
            pose["ys"] = 1.0 + 0.1 * q2
        else:
            var q3 = sin(clamp(a / 0.32, 0.0, 1.0) * PI)
            pose["off"] = d * 14.0 * q3
            if d.x != 0:
                pose["xs"] = 1.0 + 0.16 * q3
            else:
                pose["ys"] = 1.0 + 0.16 * q3
    return pose


func enemy_pose():
    var pose = {"off": Vector2(0, 0), "xs": 1.0, "ys": 1.0, "sway": 0.0}
    if enemy_dead:
        return pose
    var d = enemy_dir
    if enemy_type == "hanger":
        pose["sway"] = 3.0
    elif enemy_type == "bulb":
        pose["sway"] = 3.5

    if phase == PH_TELEGRAPH and show_lunge_t > 0.0:
        var jit = sin(anim_t * 52.0) * 1.8
        if enemy_type == "hanger":
            pose["sway"] = 8.0
            pose["off"] = Vector2(jit, 0)
        elif enemy_type == "bulb":
            pose["off"] = Vector2(jit, jit * 0.5)
            pose["xs"] = 1.0 + 0.05 * sin(anim_t * 30.0)
        else:
            pose["off"] = Vector2(-d.x * 9 + jit, -d.y * 9)
            pose["ys"] = 0.92

    if not enemy_anim.empty():
        var a = enemy_anim_t
        var k = enemy_anim["main"]
        if k == "charge" or k == "spray":
            pose["off"] = d * 17.0 * sin(clamp(a / 0.3, 0.0, 1.0) * PI)
        elif k == "sweep":
            pose["xs"] = max(abs(cos(a * 22.0)), 0.2)
        elif k == "drip":
            pose["off"] = Vector2(sin(a * 62.0) * 2.5, 0)
        elif k == "splat":
            var q = sin(clamp(a / 0.35, 0.0, 1.0) * PI)
            pose["ys"] = 1.0 - 0.28 * q
            pose["xs"] = 1.0 + 0.24 * q
        elif k == "bloom":
            var q2 = sin(clamp(a / 0.4, 0.0, 1.0) * PI)
            pose["xs"] = 1.0 + 0.26 * q2
        elif k == "cross":
            pose["off"] = Vector2(sin(a * 44.0) * 3.5, 0)
            pose["ys"] = 1.08
        elif k == "shatter":
            var qb = sin(clamp(a / 0.3, 0.0, 1.0) * PI)
            pose["xs"] = 1.0 + 0.3 * qb
            pose["ys"] = 1.0 + 0.3 * qb
        elif k == "surge":
            pose["ys"] = 1.14
            pose["off"] = Vector2(sin(a * 50.0) * 2.5, 0)
    return pose


func draw_actor(vis, rows, pal, flash, phase_off, dead, dead_t, pose = null):
    if dead and dead_t > 1.3:
        return
    var xs = 1.0
    var ys = 1.0
    var sway = 0.0
    var off = Vector2(0, 0)
    if pose != null:
        xs = pose["xs"]
        ys = pose["ys"]
        sway = pose["sway"]
        off = pose["off"]
    var p = tile_px(vis)
    p = Vector2(round(p.x) + off.x, round(p.y) + off.y)
    var bob = 0
    if dead:
        var sa = clamp(1.0 - dead_t / 0.8, 0.0, 1.0)
        draw_rect(Rect2(p.x + 14, p.y + 60, 44, 5), Color(0, 0, 0, 0.4 * sa))
    else:
        bob = (int(anim_t * 2.5 + phase_off) % 2) * 3
        draw_rect(Rect2(p.x + 14, p.y + 60, 44, 5), Color(0, 0, 0, 0.4))
    var white = flash and (int(anim_t * 26.0) % 2 == 0)
    if dead and dead_t < 0.3 and int(dead_t * 26.0) % 2 == 0:
        white = true
    var cx = p.x + 36.0
    var base_y = p.y + 68.0 - bob
    for y in range(rows.size()):
        var row = rows[y]
        var row_sway = 0.0
        if sway > 0.0:
            row_sway = sin(anim_t * 3.0 + phase_off) * sway * (float(y) / 7.0)
        for x in range(row.length()):
            var ch = row[x]
            if ch == ".":
                continue
            if not pal.has(ch):
                continue
            var col = pal[ch]
            if white:
                col = Color(1, 1, 1)
            var ox = 0.0
            var oy = 0.0
            var a = 1.0
            if dead:
                var th = float((x * 7 + y * 13) % 8) / 8.0
                var k = clamp((dead_t - 0.3 - th * 0.5) / 0.5, 0.0, 1.0)
                if k >= 1.0:
                    continue
                ox = (th - 0.5) * 26.0 * k
                oy = k * 30.0
                a = 1.0 - k
            var px = cx + (x * 8.0 - 32.0) * xs + ox + row_sway
            var py = base_y + (y * 8.0 - 64.0) * ys + oy
            draw_rect(Rect2(round(px), round(py), ceil(8.0 * xs) + 1, ceil(8.0 * ys) + 1), alpha(col, a))


func draw_cursor(r, col):
    var i = 3
    var l = 16
    var t = 3
    var x = r.position.x
    var y = r.position.y
    var w = r.size.x
    var h = r.size.y
    draw_rect(Rect2(x + i, y + i, l, t), col)
    draw_rect(Rect2(x + i, y + i, t, l), col)
    draw_rect(Rect2(x + w - i - l, y + i, l, t), col)
    draw_rect(Rect2(x + w - i - t, y + i, t, l), col)
    draw_rect(Rect2(x + i, y + h - i - t, l, t), col)
    draw_rect(Rect2(x + i, y + h - i - l, t, l), col)
    draw_rect(Rect2(x + w - i - l, y + h - i - t, l, t), col)
    draw_rect(Rect2(x + w - i - t, y + h - i - l, t, l), col)


# ---------------- the calm panel ----------------

func hp_color(frac):
    if frac > 0.5:
        return C.HP_GOOD
    if frac > 0.25:
        return C.HP_MID
    return C.HP_LOW


func draw_hp_bar(x, y, w, h, frac):
    frac = clamp(frac, 0.0, 1.0)
    draw_rect(Rect2(x, y, w, h), C.BAR_BG)
    var fw = int(round((w - 4) * frac))
    draw_rect(Rect2(x + 2, y + 2, fw, h - 4), hp_color(frac))
    frame(Rect2(x, y, w, h), C.BORDER_DIM, 1)


func draw_text_right(font, right, y, text, col):
    if font == null:
        return
    var w = font.get_string_size(text).x
    draw_string(font, Vector2(round(right - w), y), text, col)


func draw_card(r, name, hp, hp_max, hp_vis, name_color):
    draw_rect(r, C.CARD_BG)
    frame(r, C.BORDER_DIM, 1)
    if f12 != null:
        draw_string(f12, Vector2(r.position.x + 14, r.position.y + 26), name, name_color)
    draw_text_right(f8, r.position.x + r.size.x - 14, r.position.y + 26, str(hp) + "/" + str(hp_max), C.TEXT_DIM)
    draw_hp_bar(r.position.x + 14, r.position.y + 38, r.size.x - 28, 12, hp_vis / float(max(1, hp_max)))


func draw_status():
    var mine = effect_at(player_pos)
    if mine == "" or f8 == null:
        return
    var label = "SLOWED"
    if mine == "rust":
        label = "RUST"
    elif mine == "glass":
        label = "GLASS"
    elif mine == "acid":
        label = "ACID"
    elif mine == "burn":
        label = "BURN"
    var col = effect_color(mine)
    var w = f8.get_string_size(label).x + 16
    draw_rect(Rect2(PX, 188, w, 18), alpha(col, 0.16))
    frame(Rect2(PX, 188, w, 18), alpha(col, 0.6), 1)
    draw_string(f8, Vector2(PX + 8, 201), label, col)


func draw_gear():
    var badges = gear_layout()
    if badges.empty() or f8 == null:
        return
    draw_string(f8, Vector2(PX, 542), "GEAR", C.TEXT_DIM)
    for b in badges:
        var id = b["id"]
        var r = b["rect"]
        var col = M.color_of(id)
        var pulse = 0.0
        if mod_pulse.has(id):
            pulse = clamp(mod_pulse[id] / 0.7, 0.0, 1.0)
        var strength = 0.5
        if not gear_spent(id):
            strength = 1.0
        draw_rect(r, alpha(col, (0.1 + 0.3 * pulse) * strength))
        frame(r, alpha(col, (0.4 + 0.5 * pulse) * strength), 1)
        var tc = alpha(col, strength)
        if hover_mod == id:
            tc = C.TEXT
        draw_string(f8, Vector2(r.position.x + 9, r.position.y + 13), M.short_of(id), tc)


func toy_color(kind):
    if kind == "blaster":
        return C.DART_TIP
    if kind == "baseball":
        return FX_BONE
    if kind == "saber":
        return C.SABER
    return C.HEAL


func draw_shots(r, kind, fade):
    var maxu = uses_of(kind)
    var left = int(ammo.get(kind, 0))
    var rl = int(reload.get(kind, 0))
    if kind == "item":
        maxu = SHOTS_JUICE
        left = juice_left
        rl = 0
    var col = toy_color(kind)
    var pip_x = r.position.x + 16
    var pip_y = r.position.y + 34
    for i in range(maxu):
        var pr = Rect2(pip_x + i * 14, pip_y, 10, 8)
        if i < left:
            draw_rect(pr, alpha(col, fade))
        else:
            frame(pr, alpha(col, 0.35 * fade), 1)
    if rl > 0:
        draw_text_right(f8, r.position.x + r.size.x - 14, r.position.y + 42, str(rl), alpha(C.DANGER, fade))


func draw_row(i):
    var r = menu_rect(i)
    var kind = KINDS[i]
    var ready = toy_ready(kind)
    var live = (sub_state == "action" or sub_state == "target")
    var selected = live and i == action_index
    var fade = 1.0
    if not live:
        fade = 0.45
    elif not ready:
        fade = 0.55
    var bg = C.ROW_BG
    if selected:
        bg = C.ROW_SEL
    draw_rect(r, alpha(bg, fade))
    var border = C.BORDER_DIM
    if selected:
        border = C.ACCENT
    if deny_t > 0.0 and deny_index == i:
        border = C.CRUSH
    frame(r, alpha(border, fade), 1)
    draw_rect(Rect2(r.position.x + 2, r.position.y + 2, 5, r.size.y - 4), alpha(toy_color(kind), fade))
    var name_col = C.TEXT
    if selected:
        name_col = C.ACCENT
    if f12 != null:
        draw_string(f12, Vector2(r.position.x + 16, r.position.y + 22), ACTIONS[i], alpha(name_col, fade))
    var stat = str(attack_dmg(kind))
    if kind == "item":
        stat = "+" + str(C.ITEM_HEAL)
    draw_text_right(f12, r.position.x + r.size.x - 14, r.position.y + 22, stat, alpha(C.TEXT_DIM, fade))
    draw_shots(r, kind, fade)


func draw_stay():
    var r = stay_rect()
    var live = (sub_state == "action" or sub_state == "target")
    var fade = 0.5
    if live:
        fade = 1.0
    var urgent = live and not any_toy_ready() and juice_left <= 0
    var border = C.BORDER_DIM
    if urgent:
        border = C.ACCENT
    draw_rect(r, alpha(C.BTN_OFF, fade))
    frame(r, alpha(border, fade), 1)
    if f8 != null:
        draw_string(f8, Vector2(r.position.x + 16, r.position.y + 19), "STAY PUT", alpha(C.TEXT_DIM, fade))


func draw_panel():
    draw_rect(Rect2(C.PANEL_X, 0, C.SCREEN_W - C.PANEL_X, C.SCREEN_H), C.PANEL_BG)
    draw_rect(Rect2(C.PANEL_X, 0, 2, C.SCREEN_H), C.BORDER_DIM)
    if f8 != null:
        draw_string(f8, Vector2(PX, 26), "ROUND " + str(round_num), C.TEXT_DIM)

    var hr = help_rect()
    draw_rect(hr, C.BTN)
    frame(hr, C.BORDER_DIM, 1)
    if f8 != null:
        draw_string(f8, Vector2(hr.position.x + 6, hr.position.y + 15), "?", C.ACCENT)

    var sr = sound_rect()
    draw_rect(sr, C.BTN)
    frame(sr, C.BORDER_DIM, 1)
    var sl = "SOUND"
    var sc = C.TEXT_DIM
    if sound_on:
        sc = C.HP_GOOD
    else:
        sl = "MUTED"
    if f8 != null:
        draw_string(f8, Vector2(sr.position.x + 9, sr.position.y + 15), sl, sc)

    draw_card(Rect2(PX, 40, PW, 64), enemy_title(), enemy_hp, enemy_max, enemy_hp_vis, enemy_color())
    draw_card(Rect2(PX, 114, PW, 64), "YOU", player_hp, max_hp, player_hp_vis, C.PLAYER)
    draw_status()

    var head = ""
    if sub_state == "move":
        head = "MOVE"
    elif sub_state == "action":
        head = "FIGHT"
    elif sub_state == "target":
        head = "AIM"
    if head != "" and f12 != null:
        draw_string(f12, Vector2(PX, 232), head, C.ACCENT)
    for i in range(ACTIONS.size()):
        draw_row(i)
    draw_stay()

    draw_rect(Rect2(PX, 524, PW, 1), C.BORDER_DIM)
    draw_gear()

    if hover_mod != "" and f8 != null:
        draw_string(f8, Vector2(PX, 608), M.name_of(hover_mod), M.color_of(hover_mod))
        draw_string(f8, Vector2(PX, 624), fit_text(f8, M.desc_of(hover_mod), PW), C.TEXT_DIM)