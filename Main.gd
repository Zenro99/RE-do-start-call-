extends Node2D

const C = preload("res://scripts/Constants.gd")
const S = preload("res://scripts/Style.gd")

const SCREENS = {
	"title": {"text": "RE:(do)(start)(call)", "button": "START", "next": "lore"},
	"lore": {"text": "You ran. You cried.\nThen you opened your eyes... and nothing here was familiar.\n\nThe halls remember everything.\nKeep moving.", "button": "CONTINUE", "next": "ready"},
	"ready": {"text": "BATTLE 1: THE RUSTED PIPE\n\nIt hunts you. Before every attack the danger flashes for a split second. Remember it, then move!\n\nRED X: where it slides. Touch it and it's over.\nORANGE: where it hits. It has TWO attacks:\n  RUST CHARGE (!): slides, then swings a long line.\n  SPIN SWEEP (*): slides, then spins and hits every tile around it.\n\nYou attack AFTER it moves, so aim where it will END UP.\nHit the gold + tile (the exact middle of your attack) for a BULLSEYE: x1.5 damage!", "button": "BEGIN", "next": "battle"},
	"ready2": {"text": "BATTLE 2: THE MELTED HANGER\n\nIt slides in every direction, even diagonally.\nIts attacks are random and spread out across the floor.\nSticky goo slows you down.\n\nThe flash is longer, but there's more to remember.\nUse what you found!", "button": "BEGIN", "next": "battle2"},
	"win": {"text": "YOU MADE IT THROUGH", "button": "CONTINUE", "next": "title"},
	"gameover": {"text": "THE LOOP RESTARTS", "button": "TRY AGAIN", "next": "title"},
}

var current = null
var run = {}      # carried between battles: hp, max_hp, coins, mods
var stage = 1     # 1 = Rusted Pipe, 2 = Melted Hanger

func new_run():
	run = {"hp": C.PLAYER_HP, "max_hp": C.PLAYER_HP, "coins": 0, "mods": []}
	stage = 1

# called by BattleScreen when you win: battle 1 leads to a random event, battle 2 to the win screen
func battle_won(hp):
	run["hp"] = hp
	if stage == 1:
		stage = 2
		run["coins"] += C.COIN_REWARD
		switch_to("encounter")
	else:
		switch_to("win")

func _ready():
	var bg = ColorRect.new()
	bg.color = C.BG
	bg.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
	add_child(bg)
	new_run()
	switch_to("title")

func switch_to(screen_name):
	if current != null:
		current.queue_free()

	if screen_name == "title":
		new_run()

	if screen_name == "battle" or screen_name == "battle2":
		var battle = load("res://scripts/BattleScreen.gd").new()
		if screen_name == "battle2":
			battle.enemy_type = "hanger"
		battle.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
		battle.theme = S.make_theme()
		add_child(battle)
		current = battle
		return

	if screen_name == "encounter":
		var enc = load("res://scripts/EncounterScreen.gd").new()
		enc.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
		enc.theme = S.make_theme()
		add_child(enc)
		current = enc
		return

	var data = SCREENS[screen_name]
	var width = 640
	if screen_name == "ready" or screen_name == "ready2":
		width = 800

	current = Control.new()
	current.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
	current.theme = S.make_theme()
	add_child(current)

	var center = CenterContainer.new()
	center.rect_size = Vector2(C.SCREEN_W, C.SCREEN_H)
	current.add_child(center)

	var panel = PanelContainer.new()
	panel.rect_min_size = Vector2(width, 0)
	center.add_child(panel)

	var box = VBoxContainer.new()
	box.add_constant_override("separation", 28)
	panel.add_child(box)

	var label = Label.new()
	label.text = data["text"]
	label.align = Label.ALIGN_CENTER
	label.autowrap = true
	label.rect_min_size = Vector2(width - 56, 0)
	if screen_name == "title":
		label.add_font_override("font", S.make_font(24))
	if screen_name == "ready" or screen_name == "ready2":
		label.align = Label.ALIGN_LEFT
	box.add_child(label)

	var button = Button.new()
	button.text = data["button"]
	button.rect_min_size = Vector2(0, 48)
	button.connect("pressed", self, "switch_to", [data["next"]])
	box.add_child(button)
	button.call_deferred("grab_focus")
