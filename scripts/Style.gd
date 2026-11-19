extends Reference
# Shared pixel look: fonts and the UI theme used by every screen.

const C = preload("res://scripts/Constants.gd")
const FONT_PATH = "res://fonts/PressStart2P-Regular.ttf"

# Returns a crisp pixel font, or null if the font file is missing
# (everything still works with Godot's default font).
static func make_font(size):
	if not ResourceLoader.exists(FONT_PATH):
		return null
	var data = load(FONT_PATH)
	if data == null:
		return null
	data.antialiased = false
	var f = DynamicFont.new()
	f.font_data = data
	f.size = size
	f.use_filter = false
	f.use_mipmaps = false
	return f

static func box(bg, border, bw = 2, mx = 8, my = 6):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
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
	t.set_stylebox("normal", "Button", box(C.BTN, C.BORDER_DIM))
	t.set_stylebox("hover", "Button", box(C.BTN_HOVER, C.ACCENT))
	t.set_stylebox("pressed", "Button", box(C.BTN_PRESS, C.ACCENT))
	t.set_stylebox("disabled", "Button", box(C.BTN_OFF, C.GRID_LINE))
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), C.ACCENT, 2))
	t.set_color("font_color", "Button", C.TEXT)
	t.set_color("font_color_hover", "Button", C.ACCENT)
	t.set_color("font_color_pressed", "Button", C.ACCENT)
	t.set_color("font_color_disabled", "Button", C.TEXT_DIM)
	t.set_color("font_color", "Label", C.TEXT)
	t.set_stylebox("panel", "PanelContainer", box(C.PANEL_BG, C.BORDER, 4, 28, 24))
	return t
