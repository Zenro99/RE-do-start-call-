extends Control

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")

var run_state = {}
var event_kind = ""              # "shop", "chest", or "trap"
var resolved = false

var title_label = null
var body_label = null
var status_label = null
var button_box = null

func _ready():
	randomize()
	var kinds = ["shop", "chest", "trap"]
	event_kind = kinds[randi() % kinds.size()]

	var center = CenterContainer.new()
	center.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
	add_child(center)

	var panel = PanelContainer.new()
	panel.rect_min_size = Vector2(740, 0)
	center.add_child(panel)

	var box = VBoxContainer.new()
	box.add_constant_override("separation", 20)
	panel.add_child(box)

	title_label = Label.new()
	title_label.align = Label.ALIGN_CENTER
	title_label.add_font_override("font", S.make_font(22))
	title_label.add_color_override("font_color", C.ACCENT)
	box.add_child(title_label)

	status_label = Label.new()
	status_label.align = Label.ALIGN_CENTER
	status_label.add_font_override("font", S.make_font(12))
	status_label.add_color_override("font_color", C.PLAYER)
	box.add_child(status_label)

	body_label = Label.new()
	body_label.align = Label.ALIGN_CENTER
	body_label.autowrap = true
	body_label.rect_min_size = Vector2(680, 0)
	box.add_child(body_label)

	button_box = VBoxContainer.new()
	button_box.add_constant_override("separation", 12)
	box.add_child(button_box)

	refresh_status()
	setup_event()

func refresh_status():
	var hp = run_state.get("player_hp", C.PLAYER_HP)
	var mhp = run_state.get("max_hp", C.PLAYER_HP)
	var dmg = run_state.get("bonus_dmg", 0)
	var mov = C.PLAYER_MOVE + run_state.get("bonus_move", 0)
	status_label.text = "HP: " + str(hp) + "/" + str(mhp) + "   |   BONUS DMG: +" + str(dmg) + "   |   MOVE: " + str(mov)

func clear_buttons():
	for c in button_box.get_children():
		c.queue_free()

func add_choice_button(text, callback, disabled = false):
	var b = Button.new()
	b.text = text
	b.disabled = disabled
	b.rect_min_size = Vector2(0, 44)
	b.connect("pressed", self, callback)
	button_box.add_child(b)
	return b

func setup_event():
	clear_buttons()
	if event_kind == "shop":
		title_label.text = "RANDOM EVENT: HALLWAY SHOP"
		body_label.text = "A flickering vending machine hums beside an open locker.\nTrade your energy (HP) for an upgrade before Battle 2!"
		var hp = run_state.get("player_hp", C.PLAYER_HP)
		add_choice_button("VENDING SODA (FREE: HEAL +30 HP)", "_shop_heal")
		add_choice_button("9V BATTERY PACK (-15 HP: +5 ALL DAMAGE)", "_shop_dmg", hp <= 15)
		add_choice_button("LIGHT-UP SNEAKERS (-15 HP: +1 MOVE RANGE)", "_shop_move", hp <= 15)
		add_choice_button("LEAVE SHOP -> BATTLE 2", "_continue_next")
	elif event_kind == "chest":
		title_label.text = "RANDOM EVENT: LOST & FOUND CHEST"
		body_label.text = "You spot a locked Lost & Found crate wedged under the stairs.\nThe latch is loose..."
		var b = add_choice_button("OPEN CHEST", "_open_chest")
		b.call_deferred("grab_focus")
	else:
		title_label.text = "RANDOM EVENT: HALLWAY TRAP!"
		body_label.text = "CLICK! You stepped on a loose floor tile wired to a heavy mop bucket!\nHow do you react?"
		var b = add_choice_button("BRACE FOR IMPACT (TAKE 15 DAMAGE)", "_trap_tank")
		add_choice_button("DIVE ROLL (0 DAMAGE, -1 MOVE IN BATTLE 2)", "_trap_dodge")
		b.call_deferred("grab_focus")

# ---- Shop handlers ----
func _shop_heal():
	var mhp = run_state.get("max_hp", C.PLAYER_HP)
	run_state["player_hp"] = int(min(mhp, run_state.get("player_hp", mhp) + 30))
	finish_event("You chug the fizzy soda! Recovered 30 HP.")

func _shop_dmg():
	run_state["player_hp"] = max(1, run_state.get("player_hp", C.PLAYER_HP) - 15)
	run_state["bonus_dmg"] = run_state.get("bonus_dmg", 0) + 5
	finish_event("ZAP! Your toys are overcharged (+5 damage to all attacks)!")

func _shop_move():
	run_state["player_hp"] = max(1, run_state.get("player_hp", C.PLAYER_HP) - 15)
	run_state["bonus_move"] = run_state.get("bonus_move", 0) + 1
	finish_event("Fresh kicks! You can now move +1 tile every round.")

# ---- Chest handler ----
func _open_chest():
	var roll = randi() % 3
	if roll == 0:
		run_state["max_hp"] = run_state.get("max_hp", C.PLAYER_HP) + 15
		run_state["player_hp"] = min(run_state["max_hp"], run_state.get("player_hp", C.PLAYER_HP) + 30)
		run_state["juice_heal"] = run_state.get("juice_heal", C.ITEM_HEAL) + 10
		finish_event("FOUND: JUMBO LUNCHBOX!\n+15 Max HP, +30 HP healed, and stronger Juice Boxes!")
	elif roll == 1:
		run_state["bonus_dmg"] = run_state.get("bonus_dmg", 0) + 5
		finish_event("FOUND: DUCT-TAPE MOD!\nAll your toy attacks gain +5 damage!")
	else:
		run_state["bonus_move"] = run_state.get("bonus_move", 0) + 1
		finish_event("FOUND: ROLLER HEELIES!\nYour movement range increases by +1 tile!")

# ---- Trap handlers ----
func _trap_tank():
	run_state["player_hp"] = max(5, run_state.get("player_hp", C.PLAYER_HP) - 15)
	finish_event("CLANG! The bucket bonks your head for 15 damage, but your gear is fine.")

func _trap_dodge():
	run_state["bonus_move"] = run_state.get("bonus_move", 0) - 1
	finish_event("WHOOSH! You dodge the bucket, but twist your ankle (-1 move range next battle).")

func finish_event(msg):
	resolved = true
	refresh_status()
	body_label.text = msg
	clear_buttons()
	var b = add_choice_button("CONTINUE TO BATTLE 2", "_continue_next")
	b.call_deferred("grab_focus")

func _continue_next():
	get_parent().start_battle_2(run_state)