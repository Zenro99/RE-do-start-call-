extends Node2D

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")
const M = preload("res://scripts/Mods.gd")
const SFX = preload("res://scripts/Sfx.gd")

const DEBUG_START_STAGE = 1
const SOUND_DEFAULT = true
const SFX_VOL = -8.0
const SCAVENGER_COINS = 1
const EVENT_KINDS = ["chest", "shop", "doors", "vending", "lostfound", "shrine"]

const HELP_TEXT = "Each round the enemy flashes its plan, you move, then you throw a toy.\nThe flash happens once. Remember it.\nYour toy lands after it moves, so aim where it will end up.\n\nRED is the slide. Being there is fatal.\nORANGE is the blast. It costs health.\nGOLD is a bullseye. It hits much harder.\n\nThe pips under a toy are its shots. Empty it and it reloads.\n\nRust, glass and acid hurt you. Only foam and goo slow you.\nAcid burns but never holds you in place.\n\nThe bulb dashes twice and BLASTS AFTER BOTH DASHES.\nCrimson path first, violet second. Two hits every round.\n\nWASD or arrows to move, SPACE to confirm, ESC to step back.\n1-4 pick a toy, 0 stays put, H help, M sound, R restart."

const SCREENS = {
    "title": {"text": "RE:(do)(start)(call)", "button": "START", "next": "lore"},
    "lore": {"text": "You ran. You cried.\nThen you opened your eyes... and nothing here was familiar.\n\nThe halls remember everything.\nKeep moving.", "button": "CONTINUE", "next": "ready"},
    "help": {"text": HELP_TEXT, "button": "BACK", "next": "title"},
    "ready": {"text": "THE RUSTED PIPE\n\nIt hunts, and it remembers where you like to walk.\nIt slides down a line, then swings.\n\nAim where it will stop.", "button": "BEGIN", "next": "battle"},
    "ready2": {"text": "THE MELTED HANGER\n\nIt slides in every direction and floods the floor.\nGoo slows you. Acid only burns - you can walk out of it.\n\nThe hit is survivable. Standing in the mess is not.", "button": "BEGIN", "next": "battle2"},
    "ready3": {"text": "THE CRUSHED LIGHTBULB\n\nIt dashes twice. Both paths are lethal.\nCrimson first. Violet second.\n\nIt BLASTS AFTER EACH DASH.\nGlass where the first dash stops.\nLight where the second stops.\n\nTwo hits a round. Find the gap.", "button": "BEGIN", "next": "battle3"},
    "win": {"text": "YOU MADE IT THROUGH", "button": "CONTINUE", "next": "title"},
    "gameover": {"text": "THE LOOP RESTARTS", "button": "TRY AGAIN", "next": "title"},
}

var current = null
var run = {}
var stage = 1
var sfx = null
var sound_on = SOUND_DEFAULT


func new_run():
    run = {
        "hp": C.PLAYER_HP, "max_hp": C.PLAYER_HP, "coins": 0, "mods": [],
        "event_bag": [], "last_event": "", "events_seen": [], "rounds": 0,
    }
    stage = int(clamp(DEBUG_START_STAGE, 1, 3))
    if stage > 1:
        run["coins"] = C.COIN_REWARD * (stage - 1)


func shuffle_array(a):
    var i = a.size() - 1
    while i > 0:
        var j = randi() % (i + 1)
        var tmp = a[i]
        a[i] = a[j]
        a[j] = tmp
        i -= 1


func next_event_kind():
    if C.FORCE_ENCOUNTER != "":
        return C.FORCE_ENCOUNTER
    var bag = run.get("event_bag", [])
    if bag.empty():
        bag = EVENT_KINDS.duplicate()
        shuffle_array(bag)
        var last = run.get("last_event", "")
        if last != "" and bag.size() > 1 and bag[0] == last:
            var tmp = bag[0]
            bag[0] = bag[1]
            bag[1] = tmp
    var kind = bag.pop_front()
    run["event_bag"] = bag
    run["last_event"] = kind
    var seen = run.get("events_seen", [])
    seen.append(kind)
    run["events_seen"] = seen
    return kind


func set_sound(on):
    sound_on = on
    if sfx != null:
        sfx.set_enabled(on)
        if on:
            sfx.play("ui")
    if current != null and is_instance_valid(current):
        current.update()


func restart_run():
    if sfx != null:
        sfx.play("ui")
    switch_to("title")


func battle_won(hp):
    run["hp"] = hp
    var reward = C.COIN_REWARD
    if run["mods"].has("scavenger"):
        reward += SCAVENGER_COINS
    run["coins"] += reward
    if stage >= 3:
        switch_to("win")
        return
    stage += 1
    switch_to("encounter")


func _ready():
    randomize()
    var bg = ColorRect.new()
    bg.color = C.BG
    bg.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    sfx = SFX.new()
    sfx.setup(self, sound_on, SFX_VOL)

    new_run()
    switch_to("title")


func safe_theme():
    var t = S.make_theme()
    if t == null:
        t = Theme.new()
    return t


func win_text():
    var t = "YOU MADE IT THROUGH\n\nThe light goes out.\nThe hallway is just a hallway again.\n\n"
    t += "Rounds: " + str(run.get("rounds", 0)) + "\n"
    t += "Gear: " + str(run["mods"].size()) + "\n"
    for id in run["mods"]:
        t += "   " + M.name_of(id) + "\n"
    t += "\nYou walk out."
    return t


func show_error(msg):
    current = Control.new()
    current.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
    current.theme = safe_theme()
    add_child(current)
    var center = CenterContainer.new()
    center.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
    current.add_child(center)
    var panel = PanelContainer.new()
    panel.rect_min_size = Vector2(720, 0)
    center.add_child(panel)
    var box = VBoxContainer.new()
    box.add_constant_override("separation", 22)
    panel.add_child(box)
    var l = Label.new()
    l.text = "A SCRIPT FAILED TO LOAD\n\n" + msg + "\n\nCheck the Output panel for the parse error."
    l.autowrap = true
    l.rect_min_size = Vector2(660, 0)
    l.add_color_override("font_color", C.CRUSH)
    box.add_child(l)
    var b = Button.new()
    b.text = "BACK TO TITLE"
    b.rect_min_size = Vector2(0, 46)
    b.connect("pressed", self, "on_screen_button", ["title"])
    box.add_child(b)


func instance_screen(path):
    var scr = load(path)
    if scr == null:
        show_error(path + " could not be loaded.")
        return null
    if not scr.can_instance():
        show_error(path + " has a compile error.")
        return null
    var node = scr.new()
    if node == null:
        show_error(path + " could not be instanced.")
        return null
    return node


func switch_to(screen_name):
    if current != null and is_instance_valid(current):
        current.queue_free()
    current = null

    if screen_name == "title":
        new_run()

    if screen_name == "ready" and DEBUG_START_STAGE > 1:
        if DEBUG_START_STAGE >= 3:
            screen_name = "ready3"
        else:
            screen_name = "ready2"

    if screen_name == "battle" or screen_name == "battle2" or screen_name == "battle3":
        var battle = instance_screen("res://scripts/BattleScreen.gd")
        if battle == null:
            return
        if screen_name == "battle2":
            battle.enemy_type = "hanger"
        elif screen_name == "battle3":
            battle.enemy_type = "bulb"
        battle.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
        battle.theme = safe_theme()
        add_child(battle)
        current = battle
        return

    if screen_name == "encounter":
        var enc = instance_screen("res://scripts/EncounterScreen.gd")
        if enc == null:
            return
        enc.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
        enc.theme = safe_theme()
        add_child(enc)
        current = enc
        return

    if not SCREENS.has(screen_name):
        screen_name = "title"
    var data = SCREENS[screen_name]
    var width = 620
    if screen_name == "ready" or screen_name == "ready2" or screen_name == "ready3":
        width = 660
    if screen_name == "win":
        width = 660
    if screen_name == "help":
        width = 800

    current = Control.new()
    current.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
    current.theme = safe_theme()
    add_child(current)

    var center = CenterContainer.new()
    center.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
    current.add_child(center)

    var panel = PanelContainer.new()
    panel.rect_min_size = Vector2(width, 0)
    center.add_child(panel)

    var box = VBoxContainer.new()
    box.add_constant_override("separation", 26)
    panel.add_child(box)

    var label = Label.new()
    if screen_name == "win":
        label.text = win_text()
    else:
        label.text = data["text"]
    label.align = Label.ALIGN_CENTER
    label.autowrap = true
    label.rect_min_size = Vector2(width - 60, 0)
    if screen_name == "title":
        var big = S.make_font(24)
        if big != null:
            label.add_font_override("font", big)
    elif screen_name == "help":
        var small = S.make_font(11)
        if small != null:
            label.add_font_override("font", small)
    elif screen_name != "lore" and screen_name != "gameover":
        var mid = S.make_font(13)
        if mid != null:
            label.add_font_override("font", mid)
    if screen_name != "title" and screen_name != "lore" and screen_name != "gameover":
        label.align = Label.ALIGN_LEFT
    box.add_child(label)

    var button = Button.new()
    button.text = data["button"]
    button.rect_min_size = Vector2(0, 46)
    button.connect("pressed", self, "on_screen_button", [data["next"]])
    box.add_child(button)
    button.call_deferred("grab_focus")

    if screen_name == "title":
        var how = Button.new()
        how.text = "HOW TO PLAY"
        how.rect_min_size = Vector2(0, 40)
        how.connect("pressed", self, "on_screen_button", ["help"])
        box.add_child(how)

        var sndb = Button.new()
        sndb.text = "SOUND ON"
        if not sound_on:
            sndb.text = "SOUND OFF"
        sndb.rect_min_size = Vector2(0, 40)
        sndb.connect("pressed", self, "toggle_sound_button", [sndb])
        box.add_child(sndb)


func on_screen_button(next):
    if sfx != null:
        sfx.play("ui")
    switch_to(next)


func toggle_sound_button(btn):
    set_sound(not sound_on)
    if sound_on:
        btn.text = "SOUND ON"
    else:
        btn.text = "SOUND OFF"