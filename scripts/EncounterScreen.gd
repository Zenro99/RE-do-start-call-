extends Control

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")
const M = preload("res://scripts/Mods.gd")
const SFX = preload("res://scripts/Sfx.gd")

# local tuning: independent of Constants.gd version
const KINDS_ALL = ["chest", "shop", "doors", "vending", "lostfound", "shrine"]
const HEART_HP = 20
const SODA_HEAL = 22
const VENDING_HP_COST = 15
const KICK_DMG = 8
const BIN_HEAL = 30
const BIN_MAXHP = 10
const BIN_COINS = 3
const SHRINE_MAXHP_COST = 15
const SHRINE_HEAL = 15
const SFX_VOL = -8.0

const SPRITE_CHEST = [
    "........", ".oooooo.", "obbbbbbo", "obbbbbbo",
    "oooyyooo", "obbyybbo", "obbbbbbo", ".oooooo.",
]
const SPRITE_CONE = [
    "..pppp..", ".pppppp.", ".pwppwp.", "..pppp..",
    "..cccc..", "...cc...", "...cc...", "....c...",
]
const SPRITE_DOORS = [
    "ooooo.ooooo", "obbbo.oaaao", "obbbo.oaaao", "obbyo.oaaao",
    "obbbo.oayao", "obbbo.oaaao", "obbbo.oaaao", "ooooo.ooooo",
]
const SPRITE_VENDING = [
    "ooooooooo", "obbbbbbbo", "obrrggbyo", "obbbbbbbo",
    "obggrbbbo", "obbbbbbbo", "oyyyyyyyo", "ooooooooo",
]
const SPRITE_BIN = [
    ".........", "..ooooo..", ".obbbbbo.", "obbbbbbbo",
    "obrrggbbo", "obbbbbbbo", ".obbbbbo.", "..ooooo..",
]
const SPRITE_SHRINE = [
    "...ooo...", "..oyyyo..", ".oywwwyo.", ".oywwwyo.",
    "..oyyyo..", "...obo...", "..obbbo..", ".ooooooo.",
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
var gear_label = null
var box = null
var shop_offers = []
var sold = {}
var shop_msg = ""
var sprite = []
var palette = {}
var caption = ""
var flavor = ""
var sfx = null
var motes = []


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

    var par = get_parent()
    var carried = null
    if par != null:
        carried = par.get("run")
    if carried != null and not carried.empty():
        run = carried
    else:
        run = {"hp": C.PLAYER_HP, "max_hp": C.PLAYER_HP, "coins": C.COIN_REWARD, "mods": []}

    if par != null and par.get("sfx") != null:
        sfx = par.get("sfx")
    else:
        sfx = SFX.new()
        sfx.setup(self, true, SFX_VOL)

    kind = "chest"
    if par != null and par.has_method("next_event_kind"):
        kind = par.next_event_kind()
    else:
        kind = KINDS_ALL[randi() % KINDS_ALL.size()]

    for i in range(16):
        motes.append({
            "p": Vector2(rand_range(56, 344), rand_range(76, 524)),
            "v": Vector2(rand_range(-6, 6), rand_range(-16, -5)),
            "s": rand_range(2, 4),
            "a": rand_range(0.15, 0.5),
        })

    setup_art()
    title_label = make_label("", Vector2(400, 56), Vector2(520, 24), f16, C.ACCENT)
    text_label = make_label("", Vector2(400, 96), Vector2(520, 110), f12, C.TEXT)
    text_label.autowrap = true
    gear_label = make_label("", Vector2(400, 566), Vector2(520, 32), f8, C.TEXT_DIM)
    gear_label.autowrap = true
    info_label = make_label("", Vector2(400, 606), Vector2(520, 24), f8, C.TEXT_DIM)
    show_intro()


func stage_num():
    var par = get_parent()
    if par != null:
        var v = par.get("stage")
        if v != null:
            return int(v)
    return 2


func next_screen():
    if stage_num() >= 3:
        return "ready3"
    return "ready2"


func setup_art():
    var halls = ["by the stairwell", "under the broken clock", "past the trophy case", "beside the fire exit", "in the long corridor", "outside the staff room"]
    flavor = halls[randi() % halls.size()]
    if kind == "chest":
        sprite = SPRITE_CHEST
        palette = {"o": Color(0.15, 0.08, 0.04), "b": Color(0.65, 0.40, 0.18), "y": Color(1.0, 0.85, 0.25)}
        caption = "TOY CHEST"
    elif kind == "shop":
        sprite = SPRITE_CONE
        palette = {"p": Color(1.0, 0.65, 0.80), "w": Color(1, 1, 1), "c": Color(0.85, 0.60, 0.30)}
        caption = "ICE CREAM MAN"
    elif kind == "vending":
        sprite = SPRITE_VENDING
        palette = {"o": Color(0.08, 0.08, 0.12), "b": Color(0.22, 0.35, 0.62), "r": Color(0.95, 0.30, 0.30), "g": Color(0.35, 0.85, 0.45), "y": Color(1.0, 0.85, 0.25)}
        caption = "VENDING MACHINE"
    elif kind == "lostfound":
        sprite = SPRITE_BIN
        palette = {"o": Color(0.10, 0.10, 0.14), "b": Color(0.45, 0.48, 0.58), "r": Color(0.95, 0.45, 0.35), "g": Color(0.40, 0.85, 0.60)}
        caption = "LOST & FOUND"
    elif kind == "shrine":
        sprite = SPRITE_SHRINE
        palette = {"o": Color(0.12, 0.10, 0.16), "y": Color(1.0, 0.85, 0.35), "w": Color(1, 1, 1), "b": Color(0.40, 0.35, 0.55)}
        caption = "NIGHTLIGHT SHRINE"
    else:
        sprite = SPRITE_DOORS
        palette = {"o": Color(0.08, 0.08, 0.12), "b": Color(0.30, 0.55, 0.95), "a": Color(0.95, 0.45, 0.25), "y": Color(1.0, 0.85, 0.25)}
        caption = "TWO DOORS"


func make_label(text, pos, sz, font, color):
    var l = Label.new()
    l.text = text
    l.rect_position = pos
    l.rect_size = sz
    if font != null:
        l.add_font_override("font", font)
    l.add_color_override("font_color", color)
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(l)
    return l


func clear_box():
    if box != null and is_instance_valid(box):
        box.queue_free()
    box = Control.new()
    box.rect_position = Vector2(400, 232)
    add_child(box)
    refresh_info()


func add_button(text, y, method, args, h, disabled):
    var b = Button.new()
    b.text = text
    b.rect_position = Vector2(0, y)
    b.rect_size = Vector2(520, h)
    b.align = Button.ALIGN_LEFT
    if f12 != null:
        b.add_font_override("font", f12)
    b.disabled = disabled
    b.connect("pressed", self, method, args)
    box.add_child(b)
    return b


func add_note(text, y, color = C.TEXT_DIM):
    var l = Label.new()
    l.text = text
    l.rect_position = Vector2(10, y)
    l.rect_size = Vector2(500, 22)
    l.autowrap = true
    if f8 != null:
        l.add_font_override("font", f8)
    l.add_color_override("font_color", color)
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_child(l)


func refresh_info():
    var names = ""
    for id in run.get("mods", []):
        if names != "":
            names += "   "
        names += M.short_of(id)
    if names == "":
        names = "none"
    gear_label.text = "GEAR   " + names
    info_label.text = "HEALTH " + str(run["hp"]) + "/" + str(run["max_hp"]) + "     COINS " + str(run["coins"])


func owned(id):
    return run["mods"].has(id)


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
        run["max_hp"] += HEART_HP
        run["hp"] = int(min(run["max_hp"], run["hp"] + HEART_HP))
    if sfx != null:
        sfx.play("coin")


func hurt(n):
    run["hp"] = int(max(1, run["hp"] - n))
    if sfx != null:
        sfx.play("trap")


func heal(n):
    var before = run["hp"]
    run["hp"] = int(min(run["max_hp"], run["hp"] + n))
    if run["hp"] > before and sfx != null:
        sfx.play("heal")
    return run["hp"] - before


func finish():
    if sfx != null:
        sfx.play("ui")
    get_parent().switch_to(next_screen())


func show_result(msg):
    clear_box()
    text_label.text = msg
    add_button("CONTINUE", 0, "finish", [], 46, false)


func show_offers(msg, ids):
    clear_box()
    text_label.text = msg
    if ids.empty():
        text_label.text = msg + "\n\nNothing here you don't already have."
        add_button("CONTINUE", 0, "finish", [], 46, false)
        return
    for i in range(ids.size()):
        var id = ids[i]
        add_button(M.name_of(id), i * 76, "take_mod", [id], 42, false)
        add_note(M.desc_of(id), i * 76 + 46, M.color_of(id))


func take_mod(id):
    add_mod(id)
    show_result(M.name_of(id) + "\n" + M.desc_of(id))


func show_intro():
    clear_box()
    if kind == "chest":
        title_label.text = "TOY CHEST"
        text_label.text = "A dusty chest sits " + flavor + ". Something rattles inside."
        add_button("OPEN IT", 0, "open_chest", [], 46, false)
        add_button("WALK PAST", 58, "finish", [], 46, false)
    elif kind == "shop":
        title_label.text = "ICE CREAM MAN"
        text_label.text = "A cart jingles out of nowhere " + flavor + "."
        show_shop()
    elif kind == "vending":
        title_label.text = "VENDING MACHINE"
        text_label.text = "It hums " + flavor + ". The coin slot is jammed shut."
        add_button("FREE SODA", 0, "vend_soda", [], 40, run["hp"] >= run["max_hp"])
        add_note("Heal " + str(SODA_HEAL), 44)
        add_button("PAY IN BLOOD", 78, "vend_pay", [], 40, run["hp"] <= VENDING_HP_COST)
        add_note("Lose " + str(VENDING_HP_COST) + " health, take a toy", 122)
        add_button("KICK THE GLASS", 156, "vend_kick", [], 40, false)
        add_note("Even odds: a free toy, or a bruise", 200)
        add_button("WALK AWAY", 234, "finish", [], 40, false)
    elif kind == "lostfound":
        title_label.text = "LOST & FOUND"
        text_label.text = "A cardboard bin " + flavor + ", full of things nobody came back for."
        add_button("JUICE BOX", 0, "bin_heal", [], 40, run["hp"] >= run["max_hp"])
        add_note("Heal " + str(BIN_HEAL), 44)
        add_button("JUMBO LUNCHBOX", 78, "bin_max", [], 40, false)
        add_note("+" + str(BIN_MAXHP) + " max health, permanently", 122)
        add_button("POCKET CHANGE", 156, "bin_coins", [], 40, false)
        add_note("+" + str(BIN_COINS) + " coins", 200)
        add_button("LEAVE IT", 234, "finish", [], 40, false)
    elif kind == "shrine":
        title_label.text = "NIGHTLIGHT SHRINE"
        text_label.text = "Someone plugged a nightlight into the wall " + flavor + ". It asks for something back."
        add_button("MAKE AN OFFERING", 0, "shrine_offer", [], 40, run["max_hp"] <= 45)
        add_note("Lose " + str(SHRINE_MAXHP_COST) + " max health, take a toy", 44)
        add_button("WARM YOUR HANDS", 78, "shrine_pray", [], 40, run["hp"] >= run["max_hp"])
        add_note("Heal " + str(SHRINE_HEAL), 122)
        add_button("BACK AWAY", 156, "finish", [], 40, false)
    else:
        title_label.text = "TWO DOORS"
        text_label.text = "Two doors stand side by side " + flavor + ". One hums. One buzzes."
        add_button("THE QUIET DOOR", 0, "door_a", [], 44, false)
        add_note("Heal " + str(C.DOOR_HEAL), 48)
        add_button("THE BUZZING DOOR", 84, "door_b", [], 44, false)
        add_note("Even odds: a free toy, or a trap", 132)


func open_chest():
    var msg = "Three toys glow inside. Take one."
    if randf() < C.CHEST_TRAP_CHANCE:
        hurt(C.CHEST_TRAP_DMG)
        msg = "Springs fire out. Lost " + str(C.CHEST_TRAP_DMG) + " health.\nThe toys are still yours."
    elif sfx != null:
        sfx.play("reload")
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
        var label = M.name_of(id) + "   " + str(price)
        var off = run["coins"] < price
        if sold.has(id):
            label = M.name_of(id) + "   SOLD"
            off = true
        add_button(label, i * 72, "buy_mod", [id], 40, off)
        add_note(M.desc_of(id), i * 72 + 44, M.color_of(id))
    var y = shop_offers.size() * 72
    var full = run["hp"] >= run["max_hp"]
    add_button("ICE CREAM   " + str(C.ICE_CREAM_PRICE), y, "buy_ice", [], 40, run["coins"] < C.ICE_CREAM_PRICE or full)
    add_note("Heal " + str(C.ICE_CREAM_HEAL), y + 44)
    add_button("LEAVE", y + 78, "finish", [], 40, false)


func buy_mod(id):
    if sold.has(id) or run["coins"] < M.price_of(id):
        if sfx != null:
            sfx.play("deny")
        return
    run["coins"] -= M.price_of(id)
    add_mod(id)
    sold[id] = true
    shop_msg = M.name_of(id) + ". " + M.desc_of(id)
    show_shop()


func buy_ice():
    if run["coins"] < C.ICE_CREAM_PRICE:
        if sfx != null:
            sfx.play("deny")
        return
    run["coins"] -= C.ICE_CREAM_PRICE
    var h = heal(C.ICE_CREAM_HEAL)
    shop_msg = "Brain freeze. Healed " + str(h) + "."
    show_shop()


func vend_soda():
    var h = heal(SODA_HEAL)
    show_result("Warm and flat. Healed " + str(h) + ".")


func vend_pay():
    hurt(VENDING_HP_COST)
    show_offers("The coil turns. Take one.", pick_offers(3))


func vend_kick():
    if sfx != null:
        sfx.play("glass")
    if randf() < 0.5:
        var ids = pick_offers(1)
        if ids.empty():
            show_result("The glass caves in. Nothing you need.")
        else:
            show_offers("One toy tumbles out.", ids)
    else:
        hurt(KICK_DMG)
        show_result("The machine tips. Lost " + str(KICK_DMG) + " health.")


func bin_heal():
    var h = heal(BIN_HEAL)
    show_result("Still sealed. Healed " + str(h) + ".")


func bin_max():
    run["max_hp"] += BIN_MAXHP
    run["hp"] += BIN_MAXHP
    if sfx != null:
        sfx.play("heal")
    show_result("A bigger lunchbox. +" + str(BIN_MAXHP) + " max health.")


func bin_coins():
    run["coins"] += BIN_COINS
    if sfx != null:
        sfx.play("coin")
    show_result("+" + str(BIN_COINS) + " coins.")


func shrine_offer():
    run["max_hp"] = int(max(30, run["max_hp"] - SHRINE_MAXHP_COST))
    run["hp"] = int(min(run["hp"], run["max_hp"]))
    if sfx != null:
        sfx.play("boss", 1.4)
    show_offers("The nightlight flares. Take one.", pick_offers(3))


func shrine_pray():
    var h = heal(SHRINE_HEAL)
    show_result("Healed " + str(h) + ".")


func door_a():
    var h = heal(C.DOOR_HEAL)
    show_result("A warm room with a nightlight. Healed " + str(h) + ".")


func door_b():
    if randf() < 0.5:
        show_offers("A glowing shelf. Take one.", pick_offers(3))
    else:
        hurt(C.DOOR_GAMBLE_DMG)
        show_result("The floor tilts. Lost " + str(C.DOOR_GAMBLE_DMG) + " health.")


func _process(delta):
    anim_t += delta
    for m in motes:
        m["p"] = m["p"] + m["v"] * delta
        if m["p"].y < 72:
            m["p"] = Vector2(rand_range(56, 344), 528)
    update()


func _draw():
    var r = Rect2(40, 60, 320, 480)
    draw_rect(Rect2(r.position.x - 6, r.position.y - 6, r.size.x + 12, r.size.y + 12), C.BORDER_DIM)
    draw_rect(r, C.PANEL_BG)

    var glow_a = 0.05 + 0.02 * sin(anim_t * 1.6)
    draw_rect(Rect2(96, 68, 208, 464), Color(1.0, 0.88, 0.5, glow_a))
    draw_rect(Rect2(136, 68, 128, 464), Color(1.0, 0.9, 0.6, glow_a))
    for m in motes:
        draw_rect(Rect2(round(m["p"].x), round(m["p"].y), m["s"], m["s"]), Color(1.0, 0.92, 0.65, m["a"]))

    if sprite.empty() or f16 == null:
        return
    var bob = (int(anim_t * 2.0) % 2) * 6
    var px = 24
    var cols = sprite[0].length()
    var ox = 200 - int(cols * px / 2)
    var oy = 250 - 4 * px - bob
    draw_rect(Rect2(100, 372, 200, 12), Color(0, 0, 0, 0.4))
    for y in range(sprite.size()):
        var row = sprite[y]
        for x in range(row.length()):
            var ch = row[x]
            if ch == ".":
                continue
            if not palette.has(ch):
                continue
            draw_rect(Rect2(ox + x * px, oy + y * px, px, px), palette[ch])
    var w = f16.get_string_size(caption).x
    draw_string(f16, Vector2(round(200 - w * 0.5), 452), caption, C.ACCENT)