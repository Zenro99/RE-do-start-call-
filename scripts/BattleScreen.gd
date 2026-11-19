extends Control

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")
const M = preload("res://scripts/Mods.gd")

const ACTIONS = ["NERF BLASTER", "BASEBALL THROW", "LIGHTSABER THRUST", "JUICE BOX", "WAIT"]
const KINDS = ["blaster", "baseball", "saber", "item", "wait"]
const PHASE_NAMES = ["TELEGRAPH", "MOVE", "ENEMY MOVE", "RESOLVE", "TICK", "CHECK"]

# Right panel geometry (panel starts at C.PANEL_X = 600)
const PX = 616
const PW = 328

# 8x8 pixel sprites ('.' = empty), drawn at 8px per pixel
const SPRITE_PLAYER = [
	"..oooo..",
	".obbbbo.",
	".owbbwo.",
	".obbbbo.",
	"oobbbboo",
	"oblbbbbo",
	".obbbbo.",
	".oo..oo.",
]
const SPRITE_ENEMY = [
	".oooooo.",
	"osgggggo",
	"orggggro",
	"ogeggego",
	"ogggggro",
	"odddddgo",
	"orRddRro",
	".oooooo.",
]
# The Melted Hanger: a coat hanger left out in the sun. Hook on top, molten drips below.
const SPRITE_HANGER = [
	"...oo...",
	"..oggo..",
	"...og...",
	"...og...",
	"..ogggo.",
	".ogmmggo",
	"ogmmmmgo",
	"o.d.md.o",
]

# ---------------- state ----------------
var player_pos = Vector2(3, 6)
var enemy_pos = Vector2(3, 0)
var player_vis = Vector2(3, 6)   # smoothed draw positions (tile units)
var enemy_vis = Vector2(3, 0)
var player_hp = C.PLAYER_HP
var enemy_hp = C.ENEMY_HP
var round_num = 1
var phase = C.Phase.TELEGRAPH
var sub_state = "busy"           # move, action, target, busy
var lunge_tiles = []             # tiles the Pipe slides through (touching you = KO)
var swing_tiles = []             # tiles the Pipe's swing hits (10-25 damage)
var effects = {}                 # Vector2 -> {"type": String, "turns": int}
var queued_attack = {}
var item_used = false
var cursor = Vector2(3, 6)
var move_origin = Vector2(3, 6)
var current_kind = ""
var action_index = 0
var move_tiles = []
var target_tiles = []
var result = ""

# which enemy this battle is against ("pipe" or "hanger"), set by Main before the screen is added
# smooth HP bars, attack cooldowns, "can't use that" flash, banner timer
var player_hp_vis = 100.0
var enemy_hp_vis = 100.0
var cooldowns = {"blaster": 0, "baseball": 0, "saber": 0}
var deny_index = -1
var deny_t = 0.0
var banner_t = 0.0
var f12 = null

var enemy_type = "pipe"
var run = {}                     # carried between battles: hp, max_hp, coins, mods
var mods = []                    # ids of the modifiers you own (see Mods.gd)
var max_hp = C.PLAYER_HP
var enemy_max = C.ENEMY_HP
var player_dead = false
var enemy_dead = false
var player_dead_t = 0.0
var enemy_dead_t = 0.0
var streak = 0                   # FIXATION: consecutive rounds you hit the enemy
var echo = {}                    # ECHO: last attack, repeated next round
var armor_used = false           # FOAM ARMOR: used up this battle?
var damaged_this_round = false   # COMFORT OBJECT: heal only if you took no damage
var drip_tiles = []              # Hanger: tiles that turn to goo after its attack
var last_pattern = ""
var enraged = false
var pattern_label = ""
var enemy_dir = Vector2(0, 1)
var mods_label = null
var pal_hanger = {}
var swing_groups = []            # [{"kind": "charge"/"sweep"/"drip"/"slash"/"splat"/"sag", "tiles": [...], "center": Vector2}]
var strike_mult = 1.0            # damage multiplier of the current enemy attack
var last_pipe_variant = ""
var last_move = Vector2(0, 0)    # your last walk, the Pipe remembers your habits
var enemy_anim = {}              # the enemy's own attack animation
var enemy_anim_t = 0.0
var enemy_lerp = 12.0
var trail = []
var idle_t = 0.0
var crit_t = 0.0
var crit_tile = Vector2(0, 0)

# timers / effects
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
var particles = []
var banner_text = ""
var banner_color = Color(1, 1, 1)

# ui
var f8 = null
var f16 = null
var pal_player = {}
var pal_enemy = {}
var player_label = null
var enemy_label = null
var round_label = null
var phase_label = null
var hint_label = null
var action_buttons = []
var DIRS = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
var DIRS8 = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
var SPECKS = [Vector2(10, 12), Vector2(44, 20), Vector2(24, 46), Vector2(54, 52)]

# ---------------- setup ----------------
func _ready():
	randomize()
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
	pal_enemy = {"o": Color(0.16, 0.08, 0.05), "s": Color(0.82, 0.86, 0.92), "g": Color(0.55, 0.58, 0.65), "r": C.RUST, "R": Color(1.0, 0.55, 0.2), "e": Color(1.0, 0.9, 0.2), "d": Color(0.10, 0.03, 0.03)}
	pal_hanger = {"o": Color(0.10, 0.08, 0.10), "g": Color(0.66, 0.69, 0.76), "m": Color(1.0, 0.55, 0.15), "d": Color(1.0, 0.85, 0.30)}
	# pick up what you carried over from the last battle (hp, coins, modifiers)
	var par = get_parent()
	var carried = null
	if par != null:
		carried = par.get("run")
	if carried != null and not carried.empty():
		run = carried
	else:
		run = {"hp": C.PLAYER_HP, "max_hp": C.PLAYER_HP, "coins": 0, "mods": []}
	mods = run["mods"]
	max_hp = run["max_hp"]
	player_hp = run["hp"]
	if enemy_type == "hanger":
		enemy_max = C.HANGER_HP
	else:
		enemy_max = C.ENEMY_HP
	enemy_hp = enemy_max
	player_hp_vis = float(player_hp)
	enemy_hp_vis = float(enemy_hp)
	build_ui()
	start_round()

func make_label(text, y, font, color):
	var l = Label.new()
	l.text = text
	l.rect_position = Vector2(PX, y)
	l.rect_size = Vector2(PW, 20)
	l.add_font_override("font", font)
	l.add_color_override("font_color", color)
	add_child(l)
	return l

func build_ui():
	# The side panel is drawn in _draw() (see draw_panel). The only real buttons are
	# optional developer shortcuts, hidden unless C.DEBUG_BUTTONS is true.
	if C.DEBUG_BUTTONS:
		var win_btn = Button.new()
		win_btn.text = "WIN"
		win_btn.rect_position = Vector2(PX, 600)
		win_btn.rect_size = Vector2(64, 28)
		win_btn.focus_mode = Control.FOCUS_NONE
		win_btn.add_font_override("font", f8)
		win_btn.connect("pressed", self, "go_win")
		add_child(win_btn)
		var lose_btn = Button.new()
		lose_btn.text = "LOSE"
		lose_btn.rect_position = Vector2(PX + 72, 600)
		lose_btn.rect_size = Vector2(64, 28)
		lose_btn.focus_mode = Control.FOCUS_NONE
		lose_btn.add_font_override("font", f8)
		lose_btn.connect("pressed", self, "go_lose")
		add_child(lose_btn)
	update_ui()

# ---------------- helpers ----------------
func in_grid(t):
	return t.x >= 0 and t.x < C.GRID and t.y >= 0 and t.y < C.GRID

func tile_px(t):
	return C.GRID_OFFSET + t * C.TILE

func tile_center(t):
	return tile_px(t) + Vector2(C.TILE * 0.5, C.TILE * 0.5)

func tile_rect(t):
	return Rect2(tile_px(t), Vector2(C.TILE, C.TILE))

func alpha(c, a):
	return Color(c.r, c.g, c.b, a)

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
	return C.BURN

func set_hint(text):
	# (narration removed on purpose: feedback comes from banners, floating numbers and effects)
	pass

# a short title card over the board (attack names, VICTORY, ...); fades out by itself
func set_banner(text, color, dur = 1.3):
	banner_text = text
	banner_color = color
	banner_t = dur

func enemy_short():
	if enemy_type == "hanger":
		return "HANGER"
	return "PIPE"

func enemy_name():
	return "THE " + enemy_short()

func enemy_title():
	if enemy_type == "hanger":
		return "The Hanger"
	return "The Pipe"

func enemy_color():
	if enemy_type == "hanger":
		return C.DANGER
	return C.ENEMY

func hit_min():
	if enemy_type == "hanger":
		return C.HANGER_HIT_MIN
	return C.ENEMY_HIT_MIN

func hit_max():
	if enemy_type == "hanger":
		return C.HANGER_HIT_MAX
	return C.ENEMY_HIT_MAX

func has_mod(id):
	return mods.has(id)

# slow tiles (dart foam) and goo (Hanger drips) both slow whoever stands on them
func is_slow(pos):
	var e = effect_at(pos)
	return e == "slow" or e == "goo"

func player_steps():
	var steps = C.PLAYER_MOVE
	if is_slow(player_pos):
		steps = C.SLOWED_MOVE
	if has_mod("extra_step"):
		steps += 1
	return steps

func telegraph_time():
	var t = C.TELEGRAPH_TIME
	if enemy_type == "hanger":
		t = C.HANGER_TELEGRAPH
	if has_mod("static_trade"):
		t = t * 0.55
	return t

func schedule(method, delay):
	next_step = method
	wait_time = delay

func update_ui():
	update()

func refresh_buttons():
	update()

func float_text(text, tile, color, dy = 0):
	var p = tile_px(tile) + Vector2(C.TILE * 0.5, 20 + dy)
	floaters.append({"text": text, "pos": p, "t": 0.0, "color": color})

func spawn_burst(px, color, count):
	for i in range(count):
		var ang = rand_range(0.0, TAU)
		var sp = rand_range(50.0, 170.0)
		particles.append({"pos": px, "vel": Vector2(cos(ang), sin(ang)) * sp, "t": 0.0, "life": rand_range(0.3, 0.6), "color": color})

# little ambient life: the Pipe steams, the Hanger drips
func spawn_idle():
	var c = tile_center(enemy_vis)
	if enemy_type == "hanger":
		particles.append({"pos": c + Vector2(rand_range(-14, 14), 22), "vel": Vector2(0, 70), "t": 0.0, "life": 0.45, "color": C.GOO})
	else:
		particles.append({"pos": c + Vector2(rand_range(-16, 16), -26), "vel": Vector2(rand_range(-10, 10), -45), "t": 0.0, "life": 0.7, "color": Color(0.75, 0.78, 0.85)})

func damage_player(n):
	player_hp = int(max(0, player_hp - n))
	damaged_this_round = true
	player_flash = 0.25
	shake = max(shake, 6.0)
	float_text("-" + str(n), player_pos, C.DMG)
	spawn_burst(tile_center(player_pos), C.PLAYER, 8)
	if player_hp <= 0:
		kill_player()
	update_ui()

func damage_enemy(n, crit = false):
	enemy_hp = int(max(0, enemy_hp - n))
	enemy_flash = 0.25
	shake = max(shake, 4.0)
	if crit:
		shake = 9.0
		crit_t = 0.6
		crit_tile = enemy_pos
		float_text("-" + str(n), enemy_pos, C.BULLSEYE_COL)
		float_text("BULLSEYE! x" + str(C.CRIT_MULT), enemy_pos, C.BULLSEYE_COL, 26)
		spawn_burst(tile_center(enemy_pos), C.BULLSEYE_COL, 26)
		set_banner("BULLSEYE!", C.BULLSEYE_COL, 1.0)
	else:
		float_text("-" + str(n), enemy_pos, C.TEXT)
	spawn_burst(tile_center(enemy_pos), enemy_color(), 10)
	if enemy_hp <= 0 and not enemy_dead:
		enemy_dead = true
		enemy_dead_t = 0.0
		spawn_burst(tile_center(enemy_pos), enemy_color(), 26)
	update_ui()

# Only YOUR sprite dies when you lose. The enemy stays on the board.
func kill_player():
	if player_dead:
		return
	player_dead = true
	player_dead_t = 0.0
	spawn_burst(tile_center(player_pos), C.PLAYER, 26)

func kind_name(kind):
	return ACTIONS[KINDS.find(kind)]

func attack_dmg(kind):
	var base = C.SABER_DMG
	if kind == "blaster":
		base = C.BLASTER_DMG
	elif kind == "baseball":
		base = C.BASEBALL_DMG
	if has_mod("static_trade"):
		base = int(round(base * 1.3))
	return base

func line_range(kind):
	if kind == "blaster":
		return C.BLASTER_RANGE
	return C.SABER_RANGE

# ---------------- round flow ----------------
func start_round():
	phase = C.Phase.TELEGRAPH
	sub_state = "busy"
	move_tiles = []
	target_tiles = []
	queued_attack = {}
	damaged_this_round = false
	compute_enemy_attack()
	var tt = telegraph_time()
	show_lunge_t = tt
	show_swing_t = tt
	if enemy_type == "hanger":
		var title = pattern_label
		if enraged:
			title = "MELTDOWN! " + pattern_label
		set_banner(title, C.CRUSH, tt + 0.3)
	else:
		var ptitle = pattern_label
		if enraged:
			ptitle = "ENRAGED! " + pattern_label
		set_banner(ptitle, C.CRUSH, tt + 0.3)
	update_ui()
	schedule("end_telegraph", tt + 0.1)

func compute_enemy_attack():
	strike_mult = 1.0
	swing_groups = []
	if enemy_type == "hanger":
		compute_hanger_attack()
	else:
		compute_pipe_attack()

# The Melted Hanger moves in ALL 8 directions (diagonals too). Each round it:
#  1. slides 1-2 tiles in one direction (red X, instant KO), usually toward you, sometimes erratically
#  2. then uses a RANDOM pattern for its orange attack tiles:
#       DRIP RAIN   - scattered drips, spaced out across the board (they turn to goo afterwards)
#       SLASH       - a long line past its slide, straight or diagonal
#       MELT SPLAT  - a 3x3 puddle where you were standing; it sags and rests next round
#     Below half HP it MELTS DOWN: two patterns at once and no resting.
func compute_hanger_attack():
	enraged = enemy_hp * 2 <= enemy_max
	var dir = best_dir8()
	if randf() < 0.25:
		var rnd = DIRS8[randi() % DIRS8.size()]
		if in_grid(enemy_pos + rnd):
			dir = rnd
	enemy_dir = dir
	var lunge_len = C.HANGER_LUNGE
	if is_slow(enemy_pos):
		lunge_len = C.SLOWED_LUNGE
	lunge_tiles = []
	for i in range(1, lunge_len + 1):
		var t = enemy_pos + dir * i
		if not in_grid(t):
			break
		lunge_tiles.append(t)
	var patterns = []
	if last_pattern == "splat" and not enraged:
		patterns = ["sag"]
	else:
		var first = pick_pattern()
		patterns.append(first)
		if enraged:
			var second = first
			while second == first:
				second = pick_pattern()
			patterns.append(second)
	last_pattern = "other"
	if patterns.has("splat"):
		last_pattern = "splat"
	swing_tiles = []
	drip_tiles = []
	var names = []
	for p in patterns:
		var g = []
		var center = player_pos
		if p == "drip":
			names.append("DRIP RAIN")
			var n = C.DRIP_COUNT
			if enraged:
				n += 2
			for t in random_drips(n):
				g.append(t)
				add_unique(drip_tiles, t)
		elif p == "slash":
			names.append("SLASH")
			for i in range(lunge_len + 1, lunge_len + C.HANGER_SWING_LEN + 1):
				var t = enemy_pos + dir * i
				if not in_grid(t):
					break
				g.append(t)
		elif p == "splat":
			names.append("MELT SPLAT")
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var t = player_pos + Vector2(dx, dy)
					if in_grid(t):
						g.append(t)
		else:
			names.append("SAGGING...")
		for t in g:
			add_unique(swing_tiles, t)
		swing_groups.append({"kind": p, "tiles": g, "center": center})
	pattern_label = ""
	for nm in names:
		if pattern_label != "":
			pattern_label += " + "
		pattern_label += nm
	# a tile is either the lethal slide (red) or an attack tile (orange), never both
	for t in lunge_tiles:
		unmark(t)
	ensure_escape()

func unmark(t):
	swing_tiles.erase(t)
	drip_tiles.erase(t)
	for g in swing_groups:
		g["tiles"].erase(t)

func add_unique(list, t):
	if not list.has(t):
		list.append(t)

func pick_pattern():
	var r = randi() % 100
	if r < 40:
		return "drip"
	if r < 75:
		return "slash"
	return "splat"

# the direction (out of 8) that points most toward the player, staying on the board
func best_dir8():
	var d = player_pos - enemy_pos
	var options = []
	for v in DIRS8:
		if in_grid(enemy_pos + v):
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

# scattered tiles with at least one empty tile between each pair
func random_drips(n):
	var tiles = []
	var tries = 0
	while tiles.size() < n and tries < 400:
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

# fairness: there is always at least one tile you can reach that is not marked
func ensure_escape():
	var reach = reachable_tiles()
	for t in reach:
		if not swing_tiles.has(t) and not lunge_tiles.has(t):
			return
	var cand = []
	for t in reach:
		if swing_tiles.has(t):
			cand.append(t)
	if cand.size() > 0:
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

# ---------------- THE RUSTED PIPE: a hunter ----------------
# Every round it builds every attack it could do (2 attacks x 4 directions x every slide length),
# then scores each one by how much of YOUR possible next positions it covers:
#   - the tile you are standing on (stand still and you get punished)
#   - the tiles that are far from it (the retreat tiles)
#   - the tiles lined up with it (where your blaster wants to be)
#   - the tile that repeats your last walk (it remembers your habits)
# It also wants to END its slide close to you, and mixes its two attacks so it is never predictable.
# Fairness: it will never mark so much that fewer than ~35% of your reachable tiles stay safe.
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
		for dir in DIRS:
			for n in range(1, max_n + 1):
				var cand = build_pipe_candidate(variant, dir, n)
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
	lunge_tiles = best["lunge"]
	swing_tiles = best["swing"]
	enemy_dir = best["dir"]
	last_pipe_variant = best["variant"]
	swing_groups = [{"kind": best["variant"], "tiles": best["swing"], "center": best["end"]}]
	if best["variant"] == "sweep":
		pattern_label = "SPIN SWEEP!"
		strike_mult = C.SWEEP_DMG_MULT
	else:
		pattern_label = "RUST CHARGE!"

# one possible attack, or {} if it does not fit on the board
func build_pipe_candidate(variant, dir, n):
	var lunge = []
	for i in range(1, n + 1):
		var t = enemy_pos + dir * i
		if not in_grid(t):
			return {}
		lunge.append(t)
	var end = lunge[lunge.size() - 1]
	var swing = []
	if variant == "charge":
		for i in range(1, C.SWING_LEN + 1):
			var t = end + dir * i
			if not in_grid(t):
				break
			swing.append(t)
	else:
		var ring = []
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx != 0 or dy != 0:
					ring.append(Vector2(dx, dy))
		if enraged:
			ring.append(Vector2(2, 0))
			ring.append(Vector2(-2, 0))
			ring.append(Vector2(0, 2))
			ring.append(Vector2(0, -2))
		for o in ring:
			var t = end + o
			if in_grid(t) and t != enemy_pos and not lunge.has(t):
				swing.append(t)
	if swing.empty():
		return {}
	return {"variant": variant, "dir": dir, "lunge": lunge, "swing": swing, "end": end}

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

func end_telegraph():
	show_lunge_t = 0.0
	show_swing_t = 0.0
	phase = C.Phase.MOVE
	enter_move()

func enter_move():
	sub_state = "move"
	calc_move_tiles()
	cursor = player_pos
	set_hint("MOVE up to " + str(player_steps()) + " tiles. Click a green tile, or WASD + SPACE. Your own tile = stay put. Stay OFF the Pipe's line!")
	update_ui()

func enter_action():
	sub_state = "action"
	target_tiles = []
	set_hint("ACTION: click a toy, or W/S + SPACE, or press 1-5. ESC undoes your move.")
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
		var offsets = [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
		for o in offsets:
			var t = target + o
			if in_grid(t):
				tiles.append(t)
	elif kind == "saber":
		# a wide thrust: SABER_WIDTH lanes side by side, SABER_RANGE tiles long
		var dir = target - player_pos
		var perp = Vector2(dir.y, dir.x)
		var half = int(C.SABER_WIDTH / 2)
		for i in range(1, line_range(kind) + 1):
			for w in range(-half, half + 1):
				var t = player_pos + dir * i + perp * w
				if in_grid(t):
					tiles.append(t)
	else:
		var dir = target - player_pos
		for i in range(1, line_range(kind) + 1):
			var t = player_pos + dir * i
			if in_grid(t):
				tiles.append(t)
	return tiles

# The exact middle of each attack's hitbox. Hit the enemy here for a crit (x1.5).
#  blaster : the first tile of the line (point blank)
#  baseball: the center of the plus
#  saber   : the middle of the center lane (tiles 2-3 of a 4-long thrust)
func bullseye_tiles(kind, target):
	var out = []
	if kind == "baseball":
		out.append(target)
	else:
		var dir = target - player_pos
		if kind == "blaster":
			out.append(player_pos + dir)
		else:
			var n = line_range(kind)
			var lo = int(ceil(n / 2.0))
			var hi = int(floor(n / 2.0)) + 1
			for i in range(lo, hi + 1):
				out.append(player_pos + dir * i)
	var res = []
	for t in out:
		if in_grid(t):
			res.append(t)
	return res

func nearest_to_enemy(list):
	var best = list[0]
	var best_d = 999
	for t in list:
		var dist = abs(t.x - enemy_pos.x) + abs(t.y - enemy_pos.y)
		if dist < best_d:
			best_d = dist
			best = t
	return best

func cd_for(kind):
	if kind == "blaster":
		return C.BLASTER_CD
	if kind == "baseball":
		return C.BASEBALL_CD
	if kind == "saber":
		return C.SABER_CD
	return 0

func choose_action(i):
	action_index = i
	var kind = KINDS[i]
	if int(cooldowns.get(kind, 0)) > 0:
		deny_index = i
		deny_t = 0.35
		return
	if kind == "wait":
		queued_attack = {}
		lock_in()
		set_hint("You hold still and brace...")
	elif kind == "item":
		if item_used:
			set_hint("The juice box is empty. One per battle!")
			return
		item_used = true
		var healed = int(min(C.ITEM_HEAL, max_hp - player_hp))
		player_hp += healed
		float_text("+" + str(healed), player_pos, C.HEAL)
		spawn_burst(tile_center(player_pos), C.HEAL, 10)
		queued_attack = {}
		lock_in()
		set_hint("Glug glug! Juice box: +" + str(healed) + " HP.")
	else:
		current_kind = kind
		target_tiles = compute_targets(kind)
		cursor = nearest_to_enemy(target_tiles)
		sub_state = "target"
		if kind == "blaster":
			set_hint("NERF BLASTER (" + str(C.BLASTER_DMG) + " dmg, range " + str(C.BLASTER_RANGE) + "): a line of foam darts. Slows what it hits. Pick a direction. ESC = back.")
		elif kind == "baseball":
			set_hint("BASEBALL THROW (" + str(C.BASEBALL_DMG) + " dmg, range " + str(C.BASEBALL_MIN) + "-" + str(C.BASEBALL_RANGE) + "): a lob that lands in a plus shape. Pick any tile. ESC = back.")
		else:
			set_hint("LIGHTSABER THRUST (" + str(C.SABER_DMG) + " dmg, " + str(C.SABER_WIDTH) + " wide x " + str(C.SABER_RANGE) + " long): a wide thrust. Burns the floor. Pick a direction. ESC = back.")
		update_ui()

func lock_in():
	sub_state = "busy"
	target_tiles = []
	move_tiles = []
	update_ui()
	schedule("step_enemy_move", 0.35)

# ---- step 3: the enemy lunges along its telegraphed line ----
func step_enemy_move():
	phase = C.Phase.ENEMY_MOVE
	show_lunge_t = 0.7
	update_ui()
	if lunge_tiles.has(player_pos):
		# it catches you: ONLY your sprite dies, the enemy stays standing on top of the spot
		enemy_pos = player_pos
		player_hp = 0
		player_flash = 0.6
		shake = 12.0
		float_text("CRUSHED!", player_pos, C.CRUSH)
		kill_player()
		set_hint("CRUSHED! " + enemy_title() + " caught you. If it touches you, it is over.")
		update_ui()
		schedule("step_check", 1.4)
		return
	var cur = enemy_pos
	var floor_fx = "rust"
	enemy_lerp = 22.0
	if enemy_type == "hanger":
		floor_fx = "goo"
		enemy_lerp = 9.0
	for t in lunge_tiles:
		add_effect(cur, floor_fx, 3)
		cur = t
	enemy_pos = cur
	if lunge_tiles.size() > 0:
		if enemy_type == "hanger":
			set_hint("The Hanger slides across the floor, leaving sticky goo behind. You were out of the way!")
		else:
			set_hint("The Pipe slides down its line, leaving rust behind. You were out of the way!")
	else:
		set_hint(enemy_title() + " is stuck against the wall.")
	schedule("step_attack", 0.8)

# ECHO: last round's attack repeats for half damage
func apply_echo():
	if echo.empty():
		return
	var tiles = echo["tiles"]
	attack_flash = tiles
	attack_flash_t = 0.45
	attack_flash_color = Color(0.8, 0.85, 1.0)
	if tiles.has(enemy_pos) and enemy_hp > 0:
		float_text("ECHO", player_pos, C.ACCENT)
		damage_enemy(echo["dmg"])
	echo = {}

# ---- step 4a: your toy fires ----
func step_attack():
	phase = C.Phase.RESOLVE
	update_ui()
	apply_echo()
	if queued_attack.empty():
		streak = 0
		set_hint("No toy this round.")
		schedule("step_strike", 0.4)
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
	set_banner(kind_name(kind) + "!", C.ACCENT)
	if kind == "blaster":
		set_hint("Pew pew pew! Foam darts fly.")
	elif kind == "baseball":
		set_hint("Wind up... and the pitch!")
	else:
		set_hint("Vwoom! The blade thrusts forward.")
	schedule("step_attack_hit", 0.45)

func spread_effect(tiles, type):
	for t in tiles:
		for d in DIRS:
			var n = t + d
			if in_grid(n) and not tiles.has(n) and n != player_pos:
				add_effect(n, type, 2)

func step_attack_hit():
	var kind = queued_attack["kind"]
	var tiles = queued_attack["tiles"]
	attack_flash = tiles
	attack_flash_t = 0.45
	if kind == "blaster":
		attack_flash_color = C.DART_TIP
	elif kind == "baseball":
		attack_flash_color = Color(1, 1, 1)
	else:
		attack_flash_color = C.SABER
	var dmg = attack_dmg(kind)
	var msg = kind_name(kind) + " missed. " + enemy_title() + " was not there."
	if tiles.has(enemy_pos):
		streak += 1
		if has_mod("fixation") and streak > 1:
			var bonus = int(min(4 * (streak - 1), 16))
			dmg += bonus
			float_text("FIXATION +" + str(bonus), player_pos, C.ACCENT)
		var crit = bullseye_tiles(kind, queued_attack["target"]).has(enemy_pos)
		if crit:
			dmg = int(round(dmg * C.CRIT_MULT))
		damage_enemy(dmg, crit)
		msg = kind_name(kind) + " hit for " + str(dmg) + "!"
	else:
		streak = 0
	for t in tiles:
		spawn_burst(tile_center(t), attack_flash_color, 3)
		if kind == "blaster":
			add_effect(t, "slow", 2)
		elif kind == "saber":
			add_effect(t, "burn", 2)
	if has_mod("ripple"):
		if kind == "blaster":
			spread_effect(tiles, "slow")
		elif kind == "saber":
			spread_effect(tiles, "burn")
	if has_mod("echo"):
		echo = {"tiles": tiles, "dmg": int(dmg / 2)}
	shake = max(shake, 3.0)
	var cd = cd_for(kind)
	if cd > 0:
		cooldowns[kind] = cd + 1
	set_hint(msg)
	attack_anim = {}
	schedule("step_strike", 0.9)

# ---- step 4b: the enemy's attack tiles land ----
func step_strike():
	if enemy_hp <= 0:
		schedule("step_check", 0.3)
		return
	enemy_lerp = 12.0
	show_swing_t = 0.3
	var main_kind = "none"
	if swing_groups.size() > 0:
		main_kind = swing_groups[0]["kind"]
	var groups = []
	for g in swing_groups:
		groups.append({"kind": g["kind"], "tiles": g["tiles"].duplicate(), "center": g["center"]})
	enemy_anim = {"main": main_kind, "groups": groups, "origin": enemy_pos, "dir": enemy_dir}
	enemy_anim_t = 0.0
	schedule("step_strike_hit", 0.35)

func step_strike_hit():
	if swing_tiles.has(player_pos):
		if has_mod("foam_armor") and not armor_used:
			armor_used = true
			float_text("BLOCKED!", player_pos, C.HEAL)
			spawn_burst(tile_center(player_pos), C.HEAL, 14)
			set_hint("FOAM ARMOR soaks up the hit! It is used up for this battle.")
		else:
			var dmg = int(round((hit_min() + randi() % (hit_max() - hit_min() + 1)) * strike_mult))
			damage_player(dmg)
			set_hint(enemy_title() + "'s attack connects! -" + str(dmg) + " HP")
	elif swing_tiles.empty():
		set_hint(enemy_title() + " droops and rests. Free turn!")
	else:
		set_hint(enemy_title() + " attacks empty air.")
	for t in swing_tiles:
		spawn_burst(tile_center(t), enemy_hit_color(), 3)
	shake = max(shake, 5.0)
	if enemy_type == "hanger":
		for t in drip_tiles:
			add_effect(t, "goo", 2)
	schedule("step_tick", 0.6)

func enemy_hit_color():
	if enemy_type == "hanger":
		return C.GOO
	return C.RUST

# ---- step 5: tile effects tick ----
func step_tick():
	phase = C.Phase.TICK
	set_hint("Rust and burn hurt whoever stands on them. Slow and goo cut movement and lunges.")
	for pos in effects.keys():
		var e = effects[pos]
		if e["type"] == "rust":
			if pos == player_pos:
				damage_player(C.RUST_DMG)
		elif e["type"] == "burn":
			if pos == player_pos:
				damage_player(C.BURN_DMG)
			if pos == enemy_pos:
				damage_enemy(C.BURN_DMG)
		e["turns"] -= 1
		if e["turns"] <= 0:
			effects.erase(pos)
	for k in cooldowns.keys():
		if cooldowns[k] > 0:
			cooldowns[k] -= 1
	if has_mod("comfort") and not damaged_this_round and player_hp > 0 and player_hp < max_hp:
		var h = int(min(6, max_hp - player_hp))
		player_hp += h
		float_text("+" + str(h), player_pos, C.HEAL)
		spawn_burst(tile_center(player_pos), C.HEAL, 6)
	queued_attack = {}
	update_ui()
	schedule("step_check", 0.7)

# ---- step 6: win or lose ----
func step_check():
	phase = C.Phase.CHECK
	update_ui()
	if enemy_hp <= 0:
		set_banner("VICTORY!", C.HEAL)
		set_hint(enemy_title() + " falls apart!")
		schedule("go_win", 1.3)
	elif player_hp <= 0:
		set_banner("DEFEATED", C.CRUSH)
		schedule("go_lose", 1.2)
	else:
		round_num += 1
		start_round()

func go_win():
	result = "win"
	var par = get_parent()
	if par.has_method("battle_won"):
		par.battle_won(player_hp)
	else:
		par.switch_to("win")

func go_lose():
	result = "lose"
	get_parent().switch_to("gameover")

# ---------------- input ----------------
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
	var dir = Vector2(0, 0)
	if code == KEY_W or code == KEY_UP:
		dir = Vector2(0, -1)
	elif code == KEY_S or code == KEY_DOWN:
		dir = Vector2(0, 1)
	elif code == KEY_A or code == KEY_LEFT:
		dir = Vector2(-1, 0)
	elif code == KEY_D or code == KEY_RIGHT:
		dir = Vector2(1, 0)
	if dir != Vector2(0, 0):
		move_cursor(dir)
	elif code == KEY_SPACE or code == KEY_ENTER:
		confirm()
	elif code == KEY_ESCAPE or code == KEY_BACKSPACE:
		go_back()
	elif code >= KEY_1 and code <= KEY_5:
		if sub_state == "action":
			choose_action(code - KEY_1)

# one step in a direction inside a set of valid tiles (hops over small gaps)
func step_in(list, from, dir):
	var n = from + dir
	if list.has(n):
		return n
	n = from + dir * 2
	if list.has(n):
		return n
	return from

func move_cursor(dir):
	if sub_state == "move":
		cursor = step_in(move_tiles, cursor, dir)
	elif sub_state == "action":
		if dir.y != 0:
			action_index = (action_index + int(dir.y) + ACTIONS.size()) % ACTIONS.size()
			refresh_buttons()
	elif sub_state == "target":
		if current_kind == "baseball":
			cursor = step_in(target_tiles, cursor, dir)
		else:
			var n = player_pos + dir
			if target_tiles.has(n):
				cursor = n

func confirm():
	if sub_state == "move":
		if not move_tiles.has(cursor):
			return
		move_origin = player_pos
		last_move = cursor - player_pos
		player_pos = cursor
		move_tiles = []
		enter_action()
	elif sub_state == "action":
		choose_action(action_index)
	elif sub_state == "target":
		if not target_tiles.has(cursor):
			return
		var dir = Vector2(0, 0)
		if current_kind != "baseball":
			dir = cursor - player_pos
		queued_attack = {"kind": current_kind, "target": cursor, "dir": dir, "tiles": attack_tiles(current_kind, cursor)}
		lock_in()

func go_back():
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

# Turns a hovered/clicked tile into a valid target for the current state (or null).
func resolve_target(t):
	if sub_state == "move":
		if move_tiles.has(t):
			return t
		return null
	if sub_state == "target":
		if current_kind == "saber":
			# the wide thrust: any tile inside the 3-wide corridor picks that direction
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

func menu_index_at(p):
	for i in range(ACTIONS.size()):
		if menu_rect(i).has_point(p):
			return i
	return -1

func handle_hover(p):
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
	if p.x >= C.PANEL_X:
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
func _process(delta):
	anim_t += delta
	if banner_t > 0.0:
		banner_t -= delta
	if deny_t > 0.0:
		deny_t -= delta
	player_hp_vis = lerp(player_hp_vis, float(player_hp), min(1.0, delta * 6.0))
	enemy_hp_vis = lerp(enemy_hp_vis, float(enemy_hp), min(1.0, delta * 6.0))
	show_lunge_t = max(0.0, show_lunge_t - delta)
	show_swing_t = max(0.0, show_swing_t - delta)
	if attack_flash_t > 0.0:
		attack_flash_t -= delta
	if not attack_anim.empty():
		attack_anim_t += delta
	if player_flash > 0.0:
		player_flash -= delta
	if enemy_flash > 0.0:
		enemy_flash -= delta
	if player_dead:
		player_dead_t += delta
	if enemy_dead:
		enemy_dead_t += delta
	if shake > 0.0:
		shake = max(0.0, shake - delta * 30.0)
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
		if enemy_anim_t > 0.75:
			enemy_anim = {}
	if enemy_vis != enemy_pos and not enemy_dead:
		trail.append({"pos": enemy_vis, "t": 0.0})
	var keep_trail = []
	for g in trail:
		g["t"] += delta
		if g["t"] < 0.35:
			keep_trail.append(g)
	trail = keep_trail
	idle_t -= delta
	if idle_t <= 0.0 and not enemy_dead:
		idle_t = 0.2
		spawn_idle()
	var keep = []
	for f in floaters:
		f["t"] += delta * 1.3
		if f["t"] < 1.0:
			keep.append(f)
	floaters = keep
	var keep_p = []
	for p in particles:
		p["t"] += delta
		p["pos"] = p["pos"] + p["vel"] * delta
		if p["t"] < p["life"]:
			keep_p.append(p)
	particles = keep_p
	if next_step != "":
		wait_time -= delta
		if wait_time <= 0.0:
			var m = next_step
			next_step = ""
			call(m)
	update()

# ---------------- drawing ----------------
func frame(r, color, w):
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, w), color)
	draw_rect(Rect2(r.position.x, r.position.y + r.size.y - w, r.size.x, w), color)
	draw_rect(Rect2(r.position.x, r.position.y, w, r.size.y), color)
	draw_rect(Rect2(r.position.x + r.size.x - w, r.position.y, w, r.size.y), color)

func _draw():
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))
	var sh = Vector2(0, 0)
	if shake > 0.0:
		sh = Vector2(round(rand_range(-shake, shake)), round(rand_range(-shake, shake)))
	draw_set_transform(sh, 0, Vector2(1, 1))
	draw_board()
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))
	draw_banner()
	draw_panel()

func glyph_for(kind):
	if kind == "sweep":
		return "*"
	if kind == "drip":
		return "o"
	if kind == "splat":
		return "#"
	return "!"

func draw_banner():
	if banner_text == "" or banner_t <= 0.0:
		return
	var fade = clamp(banner_t / 0.35, 0.0, 1.0)
	var w = f16.get_string_size(banner_text).x
	var bx = round(C.GRID_OFFSET.x + (C.GRID * C.TILE - w) * 0.5)
	# a soft dark plate behind the text so it is easy to read on any tile
	draw_rect(Rect2(bx - 14, 14, w + 28, 36), Color(0.03, 0.03, 0.06, 0.72 * fade))
	draw_string(f16, Vector2(bx + 2, 42), banner_text, Color(0, 0, 0, fade))
	draw_string(f16, Vector2(bx, 40), banner_text, alpha(banner_color, fade))

func draw_effect(r, type, turns):
	var col = effect_color(type)
	var p = r.position
	draw_rect(r, alpha(col, 0.35))
	if type == "rust":
		for s in SPECKS:
			draw_rect(Rect2(p.x + s.x, p.y + s.y, 6, 6), alpha(col, 0.95))
	elif type == "slow":
		# foam darts littering the floor
		draw_rect(Rect2(p.x + 10, p.y + 14, 14, 5), C.DART_BODY)
		draw_rect(Rect2(p.x + 24, p.y + 14, 5, 5), C.DART_TIP)
		draw_rect(Rect2(p.x + 44, p.y + 24, 5, 14), C.DART_BODY)
		draw_rect(Rect2(p.x + 44, p.y + 38, 5, 5), C.DART_TIP)
		draw_rect(Rect2(p.x + 14, p.y + 44, 14, 5), C.DART_BODY)
		draw_rect(Rect2(p.x + 28, p.y + 44, 5, 5), C.DART_TIP)
	elif type == "goo":
		# sticky melted-metal puddles
		draw_rect(Rect2(p.x + 10, p.y + 42, 32, 14), alpha(C.GOO, 0.9))
		draw_rect(Rect2(p.x + 24, p.y + 26, 30, 18), alpha(C.GOO, 0.9))
		draw_rect(Rect2(p.x + 40, p.y + 44, 22, 12), alpha(C.GOO, 0.9))
		draw_rect(Rect2(p.x + 30, p.y + 30, 8, 6), Color(1.0, 0.95, 0.6))
	else:
		# flickering flames
		for i in range(4):
			var h = 8 + ((int(anim_t * 8.0) + i) % 3) * 6
			var fx = p.x + 8 + i * 16
			draw_rect(Rect2(fx, p.y + C.TILE - 8 - h, 8, h), alpha(C.BURN, 0.9))
			draw_rect(Rect2(fx + 2, p.y + C.TILE - 8 - h * 0.5, 4, h * 0.5), alpha(C.ACCENT, 0.9))
	draw_string(f8, p + Vector2(r.size.x - 14, r.size.y - 6), str(turns), C.TEXT)

func draw_board():
	var gsize = C.GRID * C.TILE
	var org = C.GRID_OFFSET
	var bcol = C.BORDER_DIM
	if phase == C.Phase.TELEGRAPH and show_lunge_t > 0.0:
		bcol = Color(0.85, 0.28, 0.34)
	draw_rect(Rect2(org.x - 12, org.y - 12, gsize + 24, gsize + 24), bcol)
	draw_rect(Rect2(org.x - 8, org.y - 8, gsize + 16, gsize + 16), C.BG)

	# checkerboard tiles
	for x in range(C.GRID):
		for y in range(C.GRID):
			var r = tile_rect(Vector2(x, y))
			var col = C.TILE_A
			if (x + y) % 2 == 1:
				col = C.TILE_B
			draw_rect(r, col)
			frame(r, C.GRID_LINE, 2)

	# tile effects
	for pos in effects.keys():
		draw_effect(tile_rect(pos), effects[pos]["type"], effects[pos]["turns"])

	# move / target highlights
	if sub_state == "move":
		for t in move_tiles:
			var r = tile_rect(t)
			draw_rect(r, alpha(C.MOVE_COL, 0.28))
			frame(r, alpha(C.MOVE_COL, 0.85), 2)
	if sub_state == "target":
		for t in target_tiles:
			var r = tile_rect(t)
			draw_rect(r, alpha(C.TARGET_COL, 0.18))
			frame(r, alpha(C.TARGET_COL, 0.7), 2)
		for t in attack_tiles(current_kind, cursor):
			var r = tile_rect(t)
			draw_rect(r, alpha(C.PREVIEW_COL, 0.5))
			frame(r, C.PREVIEW_COL, 4)
		for t in bullseye_tiles(current_kind, cursor):
			draw_crosshair(tile_center(t), tile_rect(t))

	# the Pipe's attack: lunge (red X) and swing (orange !)
	var pulse = 0.72 + 0.12 * sin(anim_t * 9.0)
	if show_lunge_t > 0.0:
		for t in lunge_tiles:
			var r = tile_rect(t)
			draw_rect(r, alpha(C.CRUSH, pulse))
			frame(r, C.CRUSH, 4)
			draw_string(f16, r.position + Vector2(28, 44), "X", C.TEXT)
	if show_swing_t > 0.0:
		if phase == C.Phase.TELEGRAPH or enemy_anim.empty():
			for g in swing_groups:
				for t in g["tiles"]:
					var r = tile_rect(t)
					draw_rect(r, alpha(C.DANGER, pulse))
					frame(r, C.DANGER, 4)
					draw_string(f16, r.position + Vector2(28, 44), glyph_for(g["kind"]), C.BG)

	# attack landing flash
	if attack_flash_t > 0.0:
		var a = clamp(attack_flash_t / 0.45, 0.0, 1.0)
		for t in attack_flash:
			var r = tile_rect(t)
			draw_rect(r, alpha(attack_flash_color, 0.7 * a))
			frame(r, Color(1, 1, 1, a), 4)

	# actors
	# (you are drawn first, so if the enemy ends up on your tile it stays visible on top)
	var espr = SPRITE_ENEMY
	var epal = pal_enemy
	if enemy_type == "hanger":
		espr = SPRITE_HANGER
		epal = pal_hanger
	for g in trail:
		var a = 1.0 - g["t"] / 0.35
		draw_rect(tile_rect(g["pos"]).grow(-12), alpha(enemy_hit_color(), 0.4 * a))
	draw_actor(player_vis, SPRITE_PLAYER, pal_player, player_flash > 0.0, 0.0, player_dead, player_dead_t)
	draw_actor(enemy_vis, espr, epal, enemy_flash > 0.0, 0.5, enemy_dead, enemy_dead_t, enemy_pose())
	draw_enemy_anim()

	# toy animations on top of the actors
	draw_attack_anim()

	# bullseye ring
	if crit_t > 0.0:
		var q = 1.0 - crit_t / 0.6
		var cr = tile_rect(crit_tile).grow(q * 40.0)
		frame(cr, alpha(C.BULLSEYE_COL, 1.0 - q), 4)
		draw_crosshair(tile_center(crit_tile), tile_rect(crit_tile))

	# cursor
	if sub_state == "move" or sub_state == "target":
		draw_cursor(tile_rect(cursor), C.ACCENT)

	# particles
	for p in particles:
		var a = 1.0 - p["t"] / p["life"]
		draw_rect(Rect2(round(p["pos"].x) - 3, round(p["pos"].y) - 3, 6, 6), alpha(p["color"], a))

	# floating numbers
	for f in floaters:
		var a = 1.0 - clamp((f["t"] - 0.6) / 0.4, 0.0, 1.0)
		var p = f["pos"] + Vector2(0, -round(f["t"] * 36.0))
		var w = f16.get_string_size(f["text"]).x
		p.x = round(p.x - w * 0.5)
		draw_string(f16, p + Vector2(2, 2), f["text"], Color(0, 0, 0, a))
		draw_string(f16, p, f["text"], alpha(f["color"], a))

func draw_crosshair(c, r):
	var col = C.BULLSEYE_COL
	var pulse = 0.75 + 0.25 * sin(anim_t * 8.0)
	draw_rect(r.grow(-6), alpha(col, 0.25 * pulse))
	frame(r.grow(-6), alpha(col, pulse), 3)
	draw_rect(Rect2(round(c.x) - 14, round(c.y) - 2, 28, 4), col)
	draw_rect(Rect2(round(c.x) - 2, round(c.y) - 14, 4, 28), col)

func draw_attack_anim():
	if attack_anim.empty():
		return
	var t = attack_anim_t
	var kind = attack_anim["kind"]
	var from_c = tile_center(attack_anim["from"])
	var dir = attack_anim["dir"]
	var tiles = attack_anim["tiles"]
	if kind == "blaster":
		var full = tiles.size() * C.TILE
		if t < 0.12:
			draw_rect(Rect2(round(from_c.x + dir.x * 34) - 10, round(from_c.y + dir.y * 34) - 10, 20, 20), C.TARGET_COL)
		for i in range(3):
			var p = clamp((t - i * 0.08) / 0.3, 0.0, 1.0)
			if p > 0.0 and p < 1.0:
				draw_dart(from_c + dir * (34 + p * (full - 34)), dir)
	elif kind == "baseball":
		var to_c = tile_center(attack_anim["target"])
		var p = clamp(t / 0.42, 0.0, 1.0)
		var ground = from_c.linear_interpolate(to_c, p)
		var arc = sin(p * PI) * 90.0
		if p < 1.0:
			draw_rect(Rect2(round(ground.x) - 8, round(ground.y) + 6, 16, 6), Color(0, 0, 0, 0.4))
			draw_ball(Vector2(round(ground.x), round(ground.y - arc)))
	else:
		var full = attack_anim["reach"] * C.TILE
		var e = 1.0
		if t < 0.15:
			e = t / 0.15
		elif t > 0.4:
			e = clamp(1.0 - (t - 0.4) / 0.2, 0.0, 1.0)
		# the thrust is SABER_WIDTH lanes wide: a glow over each lane, the blade down the middle
		var perp = Vector2(dir.y, dir.x)
		var half = int(C.SABER_WIDTH / 2)
		for w in range(-half, half + 1):
			if in_grid(attack_anim["from"] + perp * w):
				draw_glow(from_c + perp * w * C.TILE + dir * 26, dir, full * e)
		draw_blade(from_c + dir * 26, dir, full * e)

func draw_glow(start, dir, blade_len):
	var sx = round(start.x)
	var sy = round(start.y)
	if dir.x != 0:
		var x0 = min(sx, sx + dir.x * blade_len)
		draw_rect(Rect2(x0, sy - 34, abs(blade_len), 68), alpha(C.SABER, 0.22))
	else:
		var y0 = min(sy, sy + dir.y * blade_len)
		draw_rect(Rect2(sx - 34, y0, 68, abs(blade_len)), alpha(C.SABER, 0.22))

func draw_dart(pos, dir):
	var px = round(pos.x)
	var py = round(pos.y)
	if dir.x != 0:
		draw_rect(Rect2(px - 8 - dir.x * 2, py - 3, 14, 6), C.DART_BODY)
		draw_rect(Rect2(px + dir.x * 8 - 3, py - 3, 6, 6), C.DART_TIP)
	else:
		draw_rect(Rect2(px - 3, py - 8 - dir.y * 2, 6, 14), C.DART_BODY)
		draw_rect(Rect2(px - 3, py + dir.y * 8 - 3, 6, 6), C.DART_TIP)

func draw_ball(c):
	draw_rect(Rect2(c.x - 6, c.y - 8, 12, 16), Color(1, 1, 1))
	draw_rect(Rect2(c.x - 8, c.y - 6, 16, 12), Color(1, 1, 1))
	draw_rect(Rect2(c.x - 2, c.y - 6, 2, 4), Color(0.9, 0.2, 0.2))
	draw_rect(Rect2(c.x - 2, c.y + 2, 2, 4), Color(0.9, 0.2, 0.2))

func draw_blade(start, dir, blade_len):
	var sx = round(start.x)
	var sy = round(start.y)
	if dir.x != 0:
		var x0 = min(sx, sx + dir.x * blade_len)
		draw_rect(Rect2(x0, sy - 13, abs(blade_len), 26), alpha(C.SABER, 0.35))
		draw_rect(Rect2(x0, sy - 8, abs(blade_len), 16), C.SABER)
		draw_rect(Rect2(x0, sy - 3, abs(blade_len), 6), Color(1, 1, 1))
		draw_rect(Rect2(sx - dir.x * 14 - 5, sy - 7, 10, 14), Color(0.6, 0.62, 0.7))
	else:
		var y0 = min(sy, sy + dir.y * blade_len)
		draw_rect(Rect2(sx - 13, y0, 26, abs(blade_len)), alpha(C.SABER, 0.35))
		draw_rect(Rect2(sx - 8, y0, 16, abs(blade_len)), C.SABER)
		draw_rect(Rect2(sx - 3, y0, 6, abs(blade_len)), Color(1, 1, 1))
		draw_rect(Rect2(sx - 7, sy - dir.y * 14 - 5, 14, 10), Color(0.6, 0.62, 0.7))

# how the enemy's body moves: windup before it attacks, a unique motion for each attack
func enemy_pose():
	var pose = {"off": Vector2(0, 0), "xs": 1.0, "ys": 1.0, "sway": 0.0}
	if enemy_dead:
		return pose
	var d = enemy_dir
	if enemy_type == "hanger":
		pose["sway"] = 3.0
		if enraged:
			pose["sway"] = 5.0
	if phase == C.Phase.TELEGRAPH and show_lunge_t > 0.0:
		# windup: the Pipe coils back and rattles, the Hanger swings wildly
		var jit = sin(anim_t * 70.0) * 2.0
		if enemy_type == "hanger":
			pose["sway"] = 9.0
			pose["off"] = Vector2(jit, 0)
		else:
			pose["off"] = Vector2(-d.x * 8 + jit, -d.y * 8)
			pose["ys"] = 0.92
	if not enemy_anim.empty():
		var a = enemy_anim_t
		var k = enemy_anim["main"]
		if k == "charge":
			pose["off"] = d * 16.0 * sin(clamp(a / 0.3, 0.0, 1.0) * PI)
		elif k == "sweep":
			pose["xs"] = max(abs(cos(a * 26.0)), 0.15)
		elif k == "slash":
			pose["off"] = d * 18.0 * sin(clamp(a / 0.3, 0.0, 1.0) * PI)
		elif k == "drip":
			pose["off"] = Vector2(sin(a * 80.0) * 3.0, 0)
		elif k == "splat":
			var q = sin(clamp(a / 0.35, 0.0, 1.0) * PI)
			pose["ys"] = 1.0 - 0.3 * q
			pose["xs"] = 1.0 + 0.25 * q
		elif k == "sag":
			pose["ys"] = 0.8
	return pose

func draw_actor(vis, rows, pal, flash, phase_off, dead, dead_t, pose = null):
	if dead and dead_t > 1.4:
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
		draw_rect(Rect2(p.x + 12, p.y + 60, 48, 6), Color(0, 0, 0, 0.45 * sa))
	else:
		bob = (int(anim_t * 2.5 + phase_off) % 2) * 3
		draw_rect(Rect2(p.x + 12, p.y + 60, 48, 6), Color(0, 0, 0, 0.45))
	var white = flash and (int(anim_t * 30.0) % 2 == 0)
	if dead and dead_t < 0.3 and int(dead_t * 30.0) % 2 == 0:
		white = true
	var cx = p.x + 36.0
	var base_y = p.y + 68.0 - bob
	for y in range(rows.size()):
		var row = rows[y]
		var row_sway = 0.0
		if sway > 0.0:
			# hangs from the top: the bottom swings the most
			row_sway = sin(anim_t * 3.0 + phase_off) * sway * (float(y) / 7.0)
		for x in range(row.length()):
			var ch = row[x]
			if ch == ".":
				continue
			var col = pal[ch]
			if white:
				col = Color(1, 1, 1)
			var ox = 0.0
			var oy = 0.0
			var a = 1.0
			if dead:
				# each pixel breaks off at its own moment, drifts sideways and falls
				var th = float((x * 7 + y * 13) % 8) / 8.0
				var k = clamp((dead_t - 0.3 - th * 0.5) / 0.5, 0.0, 1.0)
				if k >= 1.0:
					continue
				ox = (th - 0.5) * 24.0 * k
				oy = k * 30.0
				a = 1.0 - k
			var px = cx + (x * 8.0 - 32.0) * xs + ox + row_sway
			var py = base_y + (y * 8.0 - 64.0) * ys + oy
			draw_rect(Rect2(round(px), round(py), ceil(8.0 * xs) + 1, ceil(8.0 * ys) + 1), alpha(col, a))

# ---------------- each enemy's attack animation ----------------
func reveal(t, delay, dur):
	return clamp((t - delay) / dur, 0.0, 1.0)

func draw_enemy_anim():
	if enemy_anim.empty():
		return
	var t = enemy_anim_t
	var fade = clamp((0.75 - t) / 0.25, 0.0, 1.0)
	var origin = enemy_anim["origin"]
	var oc = tile_center(origin)
	var d = enemy_anim["dir"]
	for g in enemy_anim["groups"]:
		var kind = g["kind"]
		var tiles = g["tiles"]
		if kind == "charge":
			# a rusty bar whips outward from the Pipe, tile by tile, with a white clang edge
			for i in range(tiles.size()):
				var p = reveal(t, i * 0.05, 0.1)
				if p <= 0.0:
					continue
				var c = tile_center(tiles[i])
				var w = C.TILE * p
				if d.x != 0:
					draw_rect(Rect2(c.x - C.TILE * 0.5, c.y - 15, w, 30), alpha(C.RUST, 0.95 * fade))
					draw_rect(Rect2(c.x - C.TILE * 0.5, c.y - 4, w, 8), alpha(Color(1.0, 0.8, 0.5), fade))
				else:
					draw_rect(Rect2(c.x - 15, c.y - C.TILE * 0.5, 30, w), alpha(C.RUST, 0.95 * fade))
					draw_rect(Rect2(c.x - 4, c.y - C.TILE * 0.5, 8, w), alpha(Color(1.0, 0.8, 0.5), fade))
		elif kind == "sweep":
			# the Pipe spins: an arm whirls around it and each tile of the ring gets smacked in turn
			for tl in tiles:
				var c2 = tile_center(tl)
				var ang = atan2(c2.y - oc.y, c2.x - oc.x) + PI
				var p2 = reveal(t, ang / TAU * 0.35, 0.08)
				if p2 > 0.0:
					draw_rect(tile_rect(tl).grow(-4), alpha(C.RUST, 0.8 * fade))
					draw_rect(tile_rect(tl).grow(-18), alpha(Color(1.0, 0.85, 0.55), 0.9 * fade))
			var a2 = t * 18.0
			var arm = oc + Vector2(cos(a2), sin(a2)) * C.TILE * 1.35
			draw_line(oc, arm, alpha(C.RUST, fade), 12.0)
			draw_line(oc, arm, alpha(Color(1, 1, 1), fade), 4.0)
			draw_line(oc, oc - (arm - oc), alpha(C.RUST, fade), 12.0)
		elif kind == "drip":
			# globs of molten metal fall from the ceiling and splash
			for i in range(tiles.size()):
				var c3 = tile_center(tiles[i])
				var delay = float(i % 4) * 0.06
				var fp = reveal(t, delay, 0.22)
				if fp > 0.0 and fp < 1.0:
					draw_rect(Rect2(round(c3.x) - 6, round(c3.y - 120 * (1.0 - fp)) - 9, 12, 18), C.GOO)
					draw_rect(Rect2(round(c3.x) - 2, round(c3.y - 120 * (1.0 - fp)) - 7, 4, 6), Color(1, 0.95, 0.6))
				elif fp >= 1.0:
					var sp = reveal(t, delay + 0.22, 0.2)
					var sz = 18.0 + 34.0 * sp
					draw_rect(Rect2(round(c3.x - sz * 0.5), round(c3.y - sz * 0.25), sz, sz * 0.5), alpha(C.GOO, 0.9 * fade))
		elif kind == "slash":
			# one bright metal slash, straight or diagonal, from the Hanger through the tiles
			if tiles.size() > 0:
				var last = tile_center(tiles[tiles.size() - 1])
				var sp2 = reveal(t, 0.0, 0.22)
				var tip = oc.linear_interpolate(last, sp2)
				for i in range(tiles.size()):
					if reveal(t, i * 0.04, 0.1) > 0.0:
						draw_rect(tile_rect(tiles[i]).grow(-6), alpha(Color(0.75, 0.8, 0.95), 0.45 * fade))
				draw_line(oc, tip, alpha(Color(0.75, 0.8, 0.95), fade), 16.0)
				draw_line(oc, tip, alpha(Color(1, 1, 1), fade), 5.0)
		elif kind == "splat":
			# the melted blob slaps down: center first, then it spreads outward
			var ctr = g["center"]
			for tl in tiles:
				var ring = max(abs(tl.x - ctr.x), abs(tl.y - ctr.y))
				var p3 = reveal(t, ring * 0.1, 0.12)
				if p3 > 0.0:
					var inset = 4 + (1.0 - p3) * 26.0
					draw_rect(tile_rect(tl).grow(-inset), alpha(C.GOO, 0.9 * fade))
					draw_rect(tile_rect(tl).grow(-inset - 14), alpha(Color(1, 0.95, 0.6), 0.8 * fade))

func draw_cursor(r, color):
	var pulse = (int(anim_t * 4.0) % 2) * 3
	var i = 2 - pulse
	var l = 18
	var t = 4
	var x = r.position.x
	var y = r.position.y
	var w = r.size.x
	var h = r.size.y
	draw_rect(Rect2(x + i, y + i, l, t), color)
	draw_rect(Rect2(x + i, y + i, t, l), color)
	draw_rect(Rect2(x + w - i - l, y + i, l, t), color)
	draw_rect(Rect2(x + w - i - t, y + i, t, l), color)
	draw_rect(Rect2(x + i, y + h - i - t, l, t), color)
	draw_rect(Rect2(x + i, y + h - i - l, t, l), color)
	draw_rect(Rect2(x + w - i - l, y + h - i - t, l, t), color)
	draw_rect(Rect2(x + w - i - t, y + h - i - l, t, l), color)

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
	var col = hp_color(frac)
	draw_rect(Rect2(x + 2, y + 2, fw, h - 4), col)
	# a lighter strip along the top of the fill gives it a soft, rounded look
	draw_rect(Rect2(x + 2, y + 2, fw, 3), Color(1, 1, 1, 0.22))
	frame(Rect2(x, y, w, h), C.BORDER_DIM, 2)

func draw_text_right(font, right, y, text, color):
	var w = font.get_string_size(text).x
	draw_string(font, Vector2(round(right - w), y), text, color)

func draw_card(r, name, hp, hp_max, hp_vis, name_color):
	draw_rect(r, C.CARD_BG)
	frame(r, C.BORDER_DIM, 2)
	draw_string(f12, Vector2(r.position.x + 14, r.position.y + 24), name, name_color)
	draw_text_right(f12, r.position.x + r.size.x - 14, r.position.y + 24, str(hp) + " / " + str(hp_max), C.TEXT)
	draw_hp_bar(r.position.x + 14, r.position.y + 34, r.size.x - 28, 14, hp_vis / float(hp_max))

func enemy_full_name():
	if enemy_type == "hanger":
		return "MELTED HANGER"
	return "RUSTED PIPE"

func menu_rect(i):
	return Rect2(PX, 252 + i * 56, PW, 50)

# what each row of the fight menu shows: name, big stat, small tag, accent color
func menu_info(i):
	var kind = KINDS[i]
	if kind == "blaster":
		return {"stat": "DMG " + str(attack_dmg(kind)), "tag": "LONG LINE  -  SLOWS", "col": C.DART_TIP}
	if kind == "baseball":
		return {"stat": "DMG " + str(attack_dmg(kind)), "tag": "LOB  -  SPLASH", "col": Color(0.92, 0.94, 1.0)}
	if kind == "saber":
		return {"stat": "DMG " + str(attack_dmg(kind)), "tag": "WIDE  -  BURNS", "col": C.SABER}
	if kind == "item":
		return {"stat": "HEAL " + str(C.ITEM_HEAL), "tag": "ONE PER BATTLE", "col": C.HEAL}
	return {"stat": "SKIP", "tag": "HOLD POSITION", "col": C.TEXT_DIM}

func draw_row(i):
	var r = menu_rect(i)
	var info = menu_info(i)
	var kind = KINDS[i]
	var cd = int(cooldowns.get(kind, 0))
	var used = (kind == "item" and item_used)
	var unavailable = cd > 0 or used
	var live = (sub_state == "action" or sub_state == "target")
	var selected = live and i == action_index
	var fade = 1.0
	if not live:
		fade = 0.5
	elif unavailable:
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
	frame(r, alpha(border, fade), 2)
	# color strip on the left, like a move "type"
	draw_rect(Rect2(r.position.x + 2, r.position.y + 2, 8, r.size.y - 4), alpha(info["col"], fade))
	var name_col = C.TEXT
	if selected:
		name_col = C.ACCENT
	draw_string(f12, Vector2(r.position.x + 22, r.position.y + 22), ACTIONS[i], alpha(name_col, fade))
	draw_text_right(f12, r.position.x + r.size.x - 12, r.position.y + 22, info["stat"], alpha(C.TEXT, fade))
	draw_string(f8, Vector2(r.position.x + 22, r.position.y + 40), info["tag"], alpha(C.TEXT_DIM, fade))
	var state = "READY"
	var state_col = C.HP_GOOD
	if used:
		state = "EMPTY"
		state_col = C.TEXT_DIM
	elif cd > 0:
		state = "RECHARGING " + str(cd)
		state_col = C.DANGER
	elif kind == "wait":
		state = ""
	if state != "":
		draw_text_right(f8, r.position.x + r.size.x - 12, r.position.y + 40, state, alpha(state_col, fade))

func draw_panel():
	draw_rect(Rect2(C.PANEL_X, 0, C.SCREEN_W - C.PANEL_X, C.SCREEN_H), C.PANEL_BG)
	draw_rect(Rect2(C.PANEL_X, 0, 4, C.SCREEN_H), C.BORDER_DIM)
	draw_string(f8, Vector2(PX, 22), "ROUND " + str(round_num), C.TEXT_DIM)
	draw_card(Rect2(PX, 32, PW, 60), enemy_full_name(), enemy_hp, enemy_max, enemy_hp_vis, enemy_color())
	draw_card(Rect2(PX, 102, PW, 60), "YOU", player_hp, max_hp, player_hp_vis, C.PLAYER)

	# modifiers you own, as small badges
	var bx = PX
	var by = 172
	for id in mods:
		var label = M.short_of(id)
		var w = f8.get_string_size(label).x + 16
		if bx + w > PX + PW:
			bx = PX
			by += 22
		draw_rect(Rect2(bx, by, w, 18), alpha(C.ACCENT, 0.16))
		frame(Rect2(bx, by, w, 18), alpha(C.ACCENT, 0.6), 2)
		draw_string(f8, Vector2(bx + 8, by + 13), label, C.ACCENT)
		bx += w + 6

	# fight menu header: one short word, like a game menu
	var head = ""
	if sub_state == "move":
		head = "MOVE"
	elif sub_state == "action":
		head = "FIGHT"
	elif sub_state == "target":
		head = "AIM"
	if head != "":
		draw_string(f12, Vector2(PX, 242), head, C.ACCENT)
	for i in range(ACTIONS.size()):
		draw_row(i)
	draw_bullseye_legend()

# tells you where each attack's gold bullseye is
func draw_bullseye_legend():
	var kind = KINDS[action_index]
	if sub_state == "target":
		kind = current_kind
	elif sub_state != "action":
		return
	var line1 = ""
	if kind == "blaster":
		line1 = "POINT BLANK: first tile of the line"
	elif kind == "baseball":
		line1 = "DEAD CENTER of the plus"
	elif kind == "saber":
		line1 = "MIDDLE of the center lane (tiles 2-3)"
	else:
		return
	var y = 548
	draw_rect(Rect2(PX, y, PW, 56), C.CARD_BG)
	frame(Rect2(PX, y, PW, 56), alpha(C.BULLSEYE_COL, 0.6), 2)
	draw_crosshair(Vector2(PX + 28, y + 28), Rect2(PX + 8, y + 8, 40, 40))
	draw_string(f8, Vector2(PX + 60, y + 22), "BULLSEYE  x" + str(C.CRIT_MULT), C.BULLSEYE_COL)
	draw_string(f8, Vector2(PX + 60, y + 42), line1, C.TEXT_DIM)
