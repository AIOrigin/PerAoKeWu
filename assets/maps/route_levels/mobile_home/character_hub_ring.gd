extends Control
class_name CharacterHubRing

## 星环中枢 · SP/HP/EN 属性弧（对齐设计稿 arcSvg）

const ARC_ROT := {"sp": -142.0, "hp": 98.0, "en": -22.0}
const ARC_LEN := 104.0

const TRACK_COLORS := {
	"sp": Color(0.384, 0.863, 0.961, 0.2),
	"hp": Color(1.0, 0.533, 0.647, 0.2),
	"en": Color(1.0, 0.745, 0.333, 0.2),
}
const FILL_COLORS := {
	"sp": Color(0.608, 0.933, 1.0),
	"hp": Color(1.0, 0.718, 0.788),
	"en": Color(1.0, 0.867, 0.584),
}
const FILL_GRADIENT_START := {
	"sp": Color(0.243, 0.761, 0.937),
	"hp": Color(1.0, 0.435, 0.576),
	"en": Color(1.0, 0.682, 0.208),
}

var hub_stats: Array = []
var dimmed: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func set_stats(stats: Array, locked: bool = false) -> void:
	hub_stats = stats
	dimmed = locked
	queue_redraw()


func _draw() -> void:
	if hub_stats.is_empty():
		return
	var center := size * 0.5
	var unit := minf(size.x, size.y) / 200.0
	var mod := 0.4 if dimmed else 1.0

	_draw_ring(center, 93.0 * unit, Color(0.627, 0.784, 0.922, 0.2 * mod), 1.0 * unit, true)
	_draw_ring(center, 75.0 * unit, Color(0.627, 0.784, 0.922, 0.12 * mod), 1.0 * unit, false)

	for stat in hub_stats:
		if stat is Dictionary:
			_draw_stat_arc(center, 84.0 * unit, stat as Dictionary, mod)


func _draw_ring(center: Vector2, radius: float, color: Color, width: float, dashed: bool) -> void:
	if dashed:
		var segments := 36
		var gap := TAU / segments
		for i in segments:
			if i % 2 == 0:
				continue
			var a0 := i * gap
			var a1 := a0 + gap * 0.55
			draw_arc(center, radius, a0, a1, 8, color, width, true)
	else:
		draw_arc(center, radius, 0.0, TAU, 64, color, width, true)


func _draw_stat_arc(center: Vector2, radius: float, stat: Dictionary, mod: float) -> void:
	var icon := String(stat.get("icon", "sp"))
	var pct := clampf(float(stat.get("pct", 0.0)), 0.0, 100.0)
	var track_color: Color = TRACK_COLORS.get(icon, TRACK_COLORS["sp"])
	var fill_color: Color = FILL_COLORS.get(icon, FILL_COLORS["sp"])
	track_color.a *= mod
	fill_color.a *= mod

	var start_deg: float = ARC_ROT.get(icon, -142.0)
	var track_start := deg_to_rad(start_deg)
	var track_end := deg_to_rad(start_deg + ARC_LEN)
	var fill_end := deg_to_rad(start_deg + ARC_LEN * pct / 100.0)

	_draw_dashed_arc(center, radius, track_start, track_end, track_color, 3.5, 6.5)
	if pct > 0.5:
		var glow := fill_color
		glow.a *= 0.22
		draw_arc(center, radius, track_start, fill_end, 32, glow, 10.0, true)
		var grad_start: Color = FILL_GRADIENT_START.get(icon, fill_color)
		grad_start.a *= mod
		draw_arc(center, radius, track_start, fill_end, 32, grad_start.lerp(fill_color, 0.5), 5.5, true)
		var tip := center + Vector2(cos(fill_end), sin(fill_end)) * radius
		draw_circle(tip, 5.0 * minf(size.x, size.y) / 200.0, fill_color)
		draw_circle(tip, 2.5 * minf(size.x, size.y) / 200.0, Color(1.0, 1.0, 1.0, 0.85))


func _draw_dashed_arc(
	center: Vector2,
	radius: float,
	start: float,
	end: float,
	color: Color,
	width: float,
	dash_deg: float
) -> void:
	var dash_rad := deg_to_rad(dash_deg)
	var pos := start
	while pos < end:
		var seg_end := minf(pos + deg_to_rad(0.8), end)
		draw_arc(center, radius, pos, seg_end, 6, color, width, true)
		pos += dash_rad
