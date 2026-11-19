extends Control
# Between battle 1 and battle 2: one RANDOM event (chest / shop / two doors).
# This is where the player finds modifiers (see Mods.gd). Set C.FORCE_ENCOUNTER to demo one on purpose.

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")
const M = preload("res://scripts/Mods.gd")

const SPRITE_CHEST = [
	"........",
	".oooooo.",
	"obbbbbbo",
	"obbbbbbo",
	"oooyyooo",
	"obbyybbo",
	"obbbbbbo",
	".oooooo.",
]
const SPRITE_CONE = [
	"..pppp..",
	".pppppp.",
	".pwppwp.",
	"..pppp..",
	"..cccc..",
	"...cc...",
	"...cc...",
	"....c...",
]
const SPRITE_DOORS = [
	"ooooo.ooooo",
	"obbbo.oaaao",
	"obbbo.oaaao",
	"obbyo.oaaao",
	"obbbo.oayao",
	"obbbo.oaaao",
	"obbbo.oaaao",
	"ooooo.ooooo",
]

var kind = ""
var run = {}
var f8 = null
var f12 = null
var f16 = null
var anim_t = 0.0
var title_label = null
var text_label = null
var info_label = null
var box = null
var shop_offers = []
var sold = {}
var shop_msg = ""
var sprite = []
var palette = {}
var caption = ""

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
	var par = get_parent()
	var carried = null
	if par != null:
		carried = par.get("run")
	if carried != null and not carried.empty():
		run = carried
	else:
		run = {"hp": C.PLAYER_HP, "max_hp": C.PLAYER_HP, "coins": C.COIN_REWARD, "mods": []}
	kind = pick_kind()
	setup_art()
	title_label = make_label("", Vector2(400, 56), Vector2(520, 24), f16, C.ACCENT)
	text_label = make_label("", Vector2(400, 100), Vector2(520, 110), f12, C.TEXT)
	text_label.autowrap = true
	info_label = make_label("", Vector2(400, 590), Vector2(520, 30), f8, C.TEXT_DIM)
	info_label.autowrap = true
	show_intro()

func pick_kind():
	if C.FORCE_ENCOUNTER == "chest" or C.FORCE_ENCOUNTER == "shop" or C.FORCE_ENCOUNTER == "chance":
		return C.FORCE_ENCOUNTER
	var all = ["chest", "shop", "chance"]
	return all[randi() % all.size()]

func setup_art():
	if kind == "chest":
		sprite = SPRITE_CHEST
		palette = {"o": Color(0.15, 0.08, 0.04), "b": Color(0.65, 0.40, 0.18), "y": Color(1.0, 0.85, 0.25)}
		caption = "TOY CHEST"
	elif kind == "shop":
		sprite = SPRITE_CONE
		palette = {"p": Color(1.0, 0.65, 0.80), "w": Color(1, 1, 1), "c": Color(0.85, 0.60, 0.30)}
		caption = "ICE CREAM MAN"
	else:
		sprite = SPRITE_DOORS
		palette = {"o": Color(0.08, 0.08, 0.12), "b": Color(0.30, 0.55, 0.95), "a": Color(0.95, 0.45, 0.25), "y": Color(1.0, 0.85, 0.25)}
		caption = "TWO DOORS"

func make_label(text, pos, size, font, color):
	var l = Label.new()
	l.text = text
	l.rect_position = pos
	l.rect_size = size
	l.add_font_override("font", font)
	l.add_color_override("font_color", color)
	add_child(l)
	return l

func clear_box():
	if box != null:
		box.queue_free()
	box = Control.new()
	box.rect_position = Vector2(400, 220)
	add_child(box)
	refresh_info()

func add_button(text, y, method, args, h, disabled):
	var b = Button.new()
	b.text = text
	b.rect_position = Vector2(0, y)
	b.rect_size = Vector2(520, h)
	b.align = Button.ALIGN_LEFT
	b.add_font_override("font", f12)
	b.disabled = disabled
	b.connect("pressed", self, method, args)
	box.add_child(b)
	return b

func add_note(text, y):
	var l = Label.new()
	l.text = text
	l.rect_position = Vector2(8, y)
	l.rect_size = Vector2(504, 24)
	l.autowrap = true
	l.add_font_override("font", f8)
	l.add_color_override("font_color", C.TEXT_DIM)
	box.add_child(l)

func refresh_info():
	var names = ""
	for id in run["mods"]:
		if names != "":
			names += ", "
		names += M.name_of(id)
	if names == "":
		names = "NONE"
	info_label.text = "HP " + str(run["hp"]) + "/" + str(run["max_hp"]) + "     COINS " + str(run["coins"]) + "\nMODS: " + names

# ---------------- helpers ----------------
func owned(id):
	return run["mods"].has(id)

# n random modifiers you do not own yet
func pick_offers(n):
	var pool = []
	for m in M.LIST:
		if not owned(m["id"]):
			pool.append(m["id"])
	var out = []
	while out.size() < n and pool.size() > 0:
		var i = randi() % pool.size()
		out.append(pool[i])
		pool.remove(i)
	return out

func add_mod(id):
	run["mods"].append(id)
	if id == "big_heart":
		run["max_hp"] += 20
		run["hp"] = int(min(run["max_hp"], run["hp"] + 20))

func hurt(n):
	run["hp"] = int(max(1, run["hp"] - n))

func heal(n):
	run["hp"] = int(min(run["max_hp"], run["hp"] + n))

func finish():
	get_parent().switch_to("ready2")

func show_result(msg):
	clear_box()
	text_label.text = msg
	add_button("CONTINUE TO BATTLE 2", 0, "finish", [], 44, false)

# a pick-one-of-three screen (chest or lucky door)
func show_offers(msg, ids):
	clear_box()
	text_label.text = msg
	if ids.empty():
		add_button("CONTINUE TO BATTLE 2", 0, "finish", [], 44, false)
		return
	for i in range(ids.size()):
		var id = ids[i]
		add_button(M.name_of(id), i * 84, "take_mod", [id], 40, false)
		add_note(M.desc_of(id), i * 84 + 44)

func take_mod(id):
	add_mod(id)
	show_result("You take the " + M.name_of(id) + "!\n" + M.desc_of(id))

# ---------------- the three encounters ----------------
func show_intro():
	clear_box()
	if kind == "chest":
		title_label.text = "A TOY CHEST"
		text_label.text = "A dusty toy chest sits alone in the hallway. Something rattles inside. Old chests can be trapped..."
		add_button("OPEN THE CHEST", 0, "open_chest", [], 44, false)
		add_button("WALK PAST IT", 56, "finish", [], 44, false)
	elif kind == "shop":
		title_label.text = "THE ICE CREAM MAN"
		text_label.text = "A cart jingles out of nowhere. \"Everything is two coins, kid. Ice cream is one.\""
		show_shop()
	else:
		title_label.text = "TWO DOORS"
		text_label.text = "Two doors stand side by side. Door A hums softly. Door B flickers and buzzes. You can only open one."
		add_button("DOOR A: a quiet rest", 0, "door_a", [], 40, false)
		add_note("Safe. A warm room with a nightlight. Heal " + str(C.DOOR_HEAL) + " HP.", 44)
		add_button("DOOR B: a gamble", 84, "door_b", [], 40, false)
		add_note("50%: a free toy (pick 1 of 3). 50%: a TRAP, -" + str(C.DOOR_GAMBLE_DMG) + " HP.", 128)

func open_chest():
	var msg = "It creaks open. Three toys glow inside. Take ONE."
	if randf() < C.CHEST_TRAP_CHANCE:
		hurt(C.CHEST_TRAP_DMG)
		msg = "TRAP! Springs fire out of the chest: -" + str(C.CHEST_TRAP_DMG) + " HP. The toys inside are still yours. Take ONE."
	show_offers(msg, pick_offers(3))

func show_shop():
	clear_box()
	if shop_msg != "":
		text_label.text = shop_msg
	if shop_offers.empty():
		shop_offers = pick_offers(3)
	for i in range(shop_offers.size()):
		var id = shop_offers[i]
		var price = M.price_of(id)
		var label = M.name_of(id) + "  -  " + str(price) + " COINS"
		var off = run["coins"] < price
		if sold.has(id):
			label = M.name_of(id) + "  -  SOLD"
			off = true
		add_button(label, i * 78, "buy_mod", [id], 36, off)
		add_note(M.desc_of(id), i * 78 + 40)
	var y = shop_offers.size() * 78
	var full = run["hp"] >= run["max_hp"]
	add_button("ICE CREAM: heal " + str(C.ICE_CREAM_HEAL) + " HP  -  " + str(C.ICE_CREAM_PRICE) + " COIN", y, "buy_ice", [], 36, run["coins"] < C.ICE_CREAM_PRICE or full)
	add_button("LEAVE THE CART", y + 48, "finish", [], 36, false)

func buy_mod(id):
	if sold.has(id) or run["coins"] < M.price_of(id):
		return
	run["coins"] -= M.price_of(id)
	add_mod(id)
	sold[id] = true
	shop_msg = "Sold! You got " + M.name_of(id) + ". " + M.desc_of(id)
	show_shop()

func buy_ice():
	if run["coins"] < C.ICE_CREAM_PRICE:
		return
	run["coins"] -= C.ICE_CREAM_PRICE
	heal(C.ICE_CREAM_HEAL)
	shop_msg = "Brain freeze! +" + str(C.ICE_CREAM_HEAL) + " HP."
	show_shop()

func door_a():
	heal(C.DOOR_HEAL)
	show_result("You rest in the warm room. +" + str(C.DOOR_HEAL) + " HP.")

func door_b():
	if randf() < 0.5:
		show_offers("The door opens on a glowing shelf. Take ONE.", pick_offers(3))
	else:
		hurt(C.DOOR_GAMBLE_DMG)
		show_result("TRAP! The floor tilts and you tumble out: -" + str(C.DOOR_GAMBLE_DMG) + " HP. Nothing here.")

# ---------------- drawing ----------------
func _process(delta):
	anim_t += delta
	update()

func _draw():
	var r = Rect2(40, 60, 320, 480)
	draw_rect(Rect2(r.position.x - 8, r.position.y - 8, r.size.x + 16, r.size.y + 16), C.BORDER_DIM)
	draw_rect(r, C.PANEL_BG)
	var bob = (int(anim_t * 2.0) % 2) * 6
	var px = 24
	var cols = sprite[0].length()
	var ox = 200 - int(cols * px / 2)
	var oy = 250 - 4 * px - bob
	draw_rect(Rect2(100, 372, 200, 12), Color(0, 0, 0, 0.45))
	for y in range(sprite.size()):
		var row = sprite[y]
		for x in range(row.length()):
			var ch = row[x]
			if ch == ".":
				continue
			draw_rect(Rect2(ox + x * px, oy + y * px, px, px), palette[ch])
	var w = f16.get_string_size(caption).x
	draw_string(f16, Vector2(round(200 - w * 0.5), 450), caption, C.ACCENT)
