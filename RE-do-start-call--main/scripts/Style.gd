extends Reference

# Godot 3 Theme setters take (value, name, type). Any other order raises a
# runtime error and aborts screen construction.

const C = preload("res://scripts/Constants.gd")

const FONT_PATH = "res://fonts/PressStart2P-Regular.ttf"


static func make_font(size):
	if not ResourceLoader.exists(FONT_PATH):
		return null
	var data = load(FONT_PATH)
	if data == null:
		return null
	if data is DynamicFontData:
		data.antialiased = false
	var f = DynamicFont.new()
	f.font_data = data
	f.size = int(size)
	f.use_filter = false
	f.use_mipmaps = false
	f.outline_size = 0
	return f


static func box(bg, border, bw = 2, mx = 10, my = 8):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(int(bw))
	sb.set_corner_radius_all(0)
	sb.anti_aliasing = false
	sb.content_margin_left = mx
	sb.content_margin_right = mx
	sb.content_margin_top = my
	sb.content_margin_bottom = my
	return sb


static func make_theme():
	var t = Theme.new()
	var f = make_font(16)
	if f != null:
		t.default_font = f

	t.set_stylebox(box(C.BTN, C.BORDER_DIM), "normal", "Button")
	t.set_stylebox(box(C.BTN_HOVER, C.ACCENT), "hover", "Button")
	t.set_stylebox(box(C.BTN_PRESS, C.ACCENT), "pressed", "Button")
	t.set_stylebox(box(C.BTN_OFF, C.GRID_LINE), "disabled", "Button")
	t.set_stylebox(box(Color(0, 0, 0, 0), C.ACCENT, 2), "focus", "Button")

	t.set_color(C.TEXT, "font_color", "Button")
	t.set_color(C.ACCENT, "font_color_hover", "Button")
	t.set_color(C.ACCENT, "font_color_pressed", "Button")
	t.set_color(C.TEXT_DIM, "font_color_disabled", "Button")
	t.set_color(C.TEXT, "font_color", "Label")

	t.set_stylebox(box(C.PANEL_BG, C.BORDER_DIM, 2, 30, 26), "panel", "PanelContainer")
	t.set_stylebox(box(C.PANEL_BG, C.BORDER_DIM, 2, 12, 12), "panel", "Panel")

	var track = box(C.BAR_BG, C.GRID_LINE, 2, 0, 0)
	var grab = box(C.BORDER_DIM, C.BORDER_DIM, 0, 0, 0)
	var grab_h = box(C.ACCENT, C.ACCENT, 0, 0, 0)
	for bar in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox(track, "scroll", bar)
		t.set_stylebox(track, "scroll_focus", bar)
		t.set_stylebox(grab, "grabber", bar)
		t.set_stylebox(grab_h, "grabber_highlight", bar)
		t.set_stylebox(grab_h, "grabber_pressed", bar)
	return t
