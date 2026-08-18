class_name ClaimButtonUI
extends RefCounted

## 全游戏统一：可领取奖励按钮 · 透明淡粉玻璃感

const BG := Color(0.98, 0.74, 0.80, 0.58)
const BORDER := Color(1.0, 0.88, 0.92, 0.82)
const GLOW := Color(1.0, 0.68, 0.76, 0.38)
const BG_HOVER := Color(1.0, 0.82, 0.86, 0.72)
const BG_PRESSED := Color(0.92, 0.62, 0.70, 0.65)
const TEXT := Color(0.38, 0.12, 0.20)
const HIGHLIGHT := Color(1.0, 0.78, 0.84)
const STAR := Color(0.98, 0.96, 1.0)
const DONE := Color(1.0, 0.82, 0.88)


static func _make_box(
	corner_radius: float,
	margin_left: float,
	margin_top: float,
	margin_right: float,
	margin_bottom: float,
	bg: Color,
	shadow_size: int
) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = BORDER
	box.shadow_color = GLOW
	box.shadow_size = shadow_size
	box.set_border_width_all(1)
	box.set_corner_radius_all(maxi(int(corner_radius), 1))
	box.content_margin_left = margin_left
	box.content_margin_top = margin_top
	box.content_margin_right = margin_right
	box.content_margin_bottom = margin_bottom
	return box


static func apply(
	button: Button,
	corner_radius: float,
	margin_left: float,
	margin_top: float,
	margin_right: float,
	margin_bottom: float,
	font_size: int = 15,
	shadow_size: int = 8
) -> void:
	var normal := _make_box(corner_radius, margin_left, margin_top, margin_right, margin_bottom, BG, shadow_size)
	var hover := _make_box(corner_radius, margin_left, margin_top, margin_right, margin_bottom, BG_HOVER, shadow_size + 2)
	var pressed := _make_box(corner_radius, margin_left, margin_top, margin_right, margin_bottom, BG_PRESSED, 2)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if font_size >= 0:
		button.add_theme_font_size_override("font_size", font_size)
		button.add_theme_color_override("font_color", TEXT)
