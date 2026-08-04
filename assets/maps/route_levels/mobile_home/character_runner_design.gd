extends RefCounted
class_name CharacterRunnerDesign

## 星火信使 · 角色页设计稿坐标系（682×1228，与 HTML cqw/cqh 一致）

const STAGE_W := 682.0
const STAGE_H := 1228.0
const PAD_X := STAGE_W * 4.11 / 100.0
const CONTENT_W := STAGE_W - PAD_X * 2.0
const SCROLL_H := STAGE_H * (100.0 - 10.2 - 8.7) / 100.0

const CYAN := Color(0.557, 0.882, 0.969)
const CYAN_SOFT := Color(0.635, 0.925, 0.976)
const ICE := Color(0.902, 0.988, 1.0)
const TEXT := Color(0.957, 0.984, 1.0)
const TEXT_SUB := Color(0.576, 0.639, 0.71)
const GREEN := Color(0.494, 0.878, 0.722)
const AMBER := Color(1.0, 0.702, 0.361)
const GLASS := Color(0.027, 0.063, 0.114, 0.62)
const LINE := Color(0.627, 0.784, 0.922, 0.16)
const PANEL_TOP := Color(0.086, 0.165, 0.267, 0.6)
const PANEL_BOT := Color(0.031, 0.063, 0.118, 0.58)

const STAT_COLORS := {
	"sp": Color(0.384, 0.863, 0.961),
	"hp": Color(1.0, 0.533, 0.647),
	"en": Color(1.0, 0.745, 0.333),
}
const RARITY := {
	"rare": Color(0.208, 0.639, 1.0),
	"epic": Color(0.659, 0.333, 0.969),
	"legend": Color(1.0, 0.702, 0.361),
}


static func cqw(v: float) -> float:
	return STAGE_W * v / 100.0


static func cqh(v: float) -> float:
	return STAGE_H * v / 100.0


static func fs_cqw(v: float) -> int:
	return int(round(cqw(v)))


static func fs_cqh(v: float) -> int:
	return int(round(cqh(v)))


static func em_cqw(font_cqw: float, em: float) -> int:
	return int(round(cqw(font_cqw) * em))


static func glass_style(radius: float, margins: Vector4 = Vector4.ZERO) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = GLASS
	s.border_color = Color(0.667, 0.902, 1.0, 0.32)
	s.set_border_width_all(1)
	s.set_corner_radius_all(int(radius))
	s.shadow_color = Color(CYAN.r, CYAN.g, CYAN.b, 0.2)
	s.shadow_size = 10
	if margins != Vector4.ZERO:
		s.content_margin_left = int(margins.x)
		s.content_margin_top = int(margins.y)
		s.content_margin_right = int(margins.z)
		s.content_margin_bottom = int(margins.w)
	return s


static func gear_style(accent: Color, dimmed: bool, corner_r: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(corner_r)
	if dimmed:
		s.bg_color = Color(0.035, 0.078, 0.122, 0.72)
		s.border_color = Color(0.42, 0.486, 0.561, 0.55)
		s.set_border_width_all(1)
		return s
	s.bg_color = Color(0.078, 0.141, 0.235, 0.78).lerp(accent, 0.22)
	s.border_color = accent.lerp(Color.WHITE, 0.22)
	s.set_border_width_all(1)
	s.shadow_color = Color(accent.r, accent.g, accent.b, 0.34)
	s.shadow_size = 12
	s.draw_center = true
	return s


static func gear_rarity_style(accent: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(accent.r, accent.g, accent.b, 0.22)
	s.border_color = Color(accent.r, accent.g, accent.b, 0.8)
	s.set_border_width_all(1)
	s.set_corner_radius_all(fs_cqw(1))
	s.content_margin_left = fs_cqw(1.6)
	s.content_margin_right = fs_cqw(1.6)
	s.content_margin_top = int(cqh(0.1))
	s.content_margin_bottom = int(cqh(0.1))
	return s


static func card_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_TOP.lerp(PANEL_BOT, 0.45)
	s.border_color = LINE
	s.set_border_width_all(1)
	s.set_corner_radius_all(fs_cqw(2.2))
	s.content_margin_left = fs_cqw(3.6)
	s.content_margin_right = fs_cqw(3.6)
	s.content_margin_top = fs_cqh(1.4)
	s.content_margin_bottom = fs_cqh(1.4)
	s.shadow_color = Color(CYAN.r, CYAN.g, CYAN.b, 0.1)
	s.shadow_size = 8
	return s
