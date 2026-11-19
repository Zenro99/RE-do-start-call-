extends Reference
# The modifiers (buffs) the player can find in chests, shops and doors.
# Add a new one here, then give it an effect in BattleScreen.gd (search for has_mod).

const LIST = [
	{"id": "extra_step", "name": "EXTRA STEP", "short": "STEP", "price": 2, "desc": "+1 tile of movement every round."},
	{"id": "foam_armor", "name": "FOAM ARMOR", "short": "ARMOR", "price": 2, "desc": "Blocks the first enemy hit of each battle."},
	{"id": "fixation", "name": "FIXATION", "short": "FIXATE", "price": 2, "desc": "Hit the enemy every round to stack +4 damage (max +16). A miss resets it."},
	{"id": "ripple", "name": "RIPPLE", "short": "RIPPLE", "price": 2, "desc": "Slow and burn tiles from your toys spread to the tiles next to them."},
	{"id": "echo", "name": "ECHO", "short": "ECHO", "price": 3, "desc": "Every toy attack repeats next round for half damage."},
	{"id": "static_trade", "name": "STATIC TRADE", "short": "STATIC", "price": 2, "desc": "The warning flash is 45% shorter, but your toys deal 30% more damage."},
	{"id": "comfort", "name": "COMFORT OBJECT", "short": "COMFORT", "price": 2, "desc": "Heal 6 HP at the end of any round you take no damage."},
	{"id": "big_heart", "name": "BIG HEART", "short": "HEART", "price": 3, "desc": "+20 max HP and heal 20 right now."},
]

static func find(id):
	for m in LIST:
		if m["id"] == id:
			return m
	return {}

static func name_of(id):
	return find(id).get("name", "?")

static func short_of(id):
	return find(id).get("short", "?")

static func desc_of(id):
	return find(id).get("desc", "")

static func price_of(id):
	return find(id).get("price", 2)
