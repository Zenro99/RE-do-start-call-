extends Reference

const LIST = [
    {"id": "duct_tape", "name": "DUCT TAPE", "short": "TAPE", "price": 2,
     "color": Color(1.0, 0.85, 0.25), "desc": "+5 damage on every hit."},
    {"id": "spare_mag", "name": "SPARE MAGAZINE", "short": "MAGS", "price": 3,
     "color": Color(0.45, 0.95, 0.90), "desc": "+1 shot per toy, faster reloads."},
    {"id": "big_heart", "name": "JUMBO LUNCHBOX", "short": "HEART", "price": 2,
     "color": Color(0.40, 1.0, 0.50), "desc": "+20 max health."},
    {"id": "extra_step", "name": "LIGHT-UP SNEAKERS", "short": "STEP", "price": 2,
     "color": Color(0.30, 0.90, 0.40), "desc": "+1 tile of movement."},
    {"id": "foam_armor", "name": "FOAM ARMOR", "short": "ARMOR", "price": 2,
     "color": Color(0.30, 0.85, 0.95), "desc": "Blocks the first hit each battle."},
    {"id": "echo", "name": "ECHO STICKER", "short": "ECHO", "price": 3,
     "color": Color(0.70, 0.80, 1.0), "desc": "Last attack repeats at half damage."},
    {"id": "fixation", "name": "FIXATION", "short": "FIX", "price": 2,
     "color": Color(1.0, 0.45, 0.75), "desc": "+4 damage per hit in a row."},
    {"id": "ripple", "name": "RIPPLE CAP", "short": "RIPPLE", "price": 2,
     "color": Color(0.55, 0.85, 1.0), "desc": "Foam and burn spread sideways."},
    {"id": "comfort", "name": "COMFORT OBJECT", "short": "COMFY", "price": 2,
     "color": Color(1.0, 0.70, 0.85), "desc": "Heal 6 on an untouched round."},
    {"id": "lucky", "name": "LUCKY MARBLE", "short": "LUCKY", "price": 3,
     "color": Color(1.0, 0.82, 0.20), "desc": "Bullseyes hit for double."},
    {"id": "plush", "name": "PLUSH GUARD", "short": "PLUSH", "price": 2,
     "color": Color(0.85, 0.65, 1.0), "desc": "Take 4 less damage per hit."},
    {"id": "scavenger", "name": "SCAVENGER PIN", "short": "COIN", "price": 1,
     "color": Color(1.0, 0.80, 0.30), "desc": "+1 coin per battle won."},
]


static func find(id):
    for m in LIST:
        if m["id"] == id:
            return m
    return null


static func name_of(id):
    var m = find(id)
    if m == null:
        return str(id)
    return m["name"]


static func short_of(id):
    var m = find(id)
    if m == null:
        return str(id)
    return m["short"]


static func desc_of(id):
    var m = find(id)
    if m == null:
        return ""
    return m["desc"]


static func price_of(id):
    var m = find(id)
    if m == null:
        return 2
    return m["price"]


static func color_of(id):
    var m = find(id)
    if m == null:
        return Color(1, 1, 1)
    return m["color"]