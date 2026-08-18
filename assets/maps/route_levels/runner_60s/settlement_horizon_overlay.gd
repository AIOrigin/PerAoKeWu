extends Control
class_name SettlementHorizonOverlay

## 地平线光感 + 跃起剪影 + 下半青蓝光影氛围

var horizon_ratio := 0.38
var _t := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	queue_redraw()


func _draw() -> void:
	var sz := size
	if sz.x < 8.0 or sz.y < 8.0:
		return
	var horizon_y: float = sz.y * horizon_ratio
	_draw_horizon_glow(sz, horizon_y)
	_draw_elsa_silhouette(sz, horizon_y)
	_draw_lower_veil(sz, horizon_y)


func _draw_horizon_glow(sz: Vector2, horizon_y: float) -> void:
	var pulse: float = 0.94 + sin(_t * 1.9) * 0.06
	var cx := sz.x * 0.5
	# 略微紫光晕（设计稿中心柔光，不要粉紫主色）
	for i in 8:
		var r := sz.x * (0.09 + float(i) * 0.05)
		var a := (0.11 - float(i) * 0.011) * pulse
		draw_circle(Vector2(cx, horizon_y), r, Color(0.48, 0.36, 0.78, maxf(a, 0.0)))
	# 青蓝能量地平线光带
	for i in 6:
		var spread := (6 - i) * sz.x * 0.11
		var alpha := 0.03 + float(i) * 0.025
		draw_rect(
			Rect2(cx - spread, horizon_y - 14.0 - float(i) * 4.0, spread * 2.0, 28.0 + float(i) * 8.0),
			Color(0.55, 0.88, 1.0, alpha * pulse)
		)
	draw_rect(Rect2(0.0, horizon_y - 1.5, sz.x, 3.0), Color(0.92, 0.98, 1.0, 0.98 * pulse))
	draw_rect(Rect2(cx - sz.x * 0.32, horizon_y - 4.5, sz.x * 0.64, 9.0), Color(0.72, 0.94, 1.0, 0.48 * pulse))


func _draw_elsa_silhouette(sz: Vector2, horizon_y: float) -> void:
	# 设计稿：居中跃起剪影，约占屏高 14%
	var cx := sz.x * 0.5
	var fig_h: float = sz.y * 0.145
	var scale: float = fig_h / 100.0
	var jump: float = (0.5 + 0.5 * sin(_t * 4.8)) * 12.0 * scale
	var feet_y: float = horizon_y + 4.0 * scale
	var ink := Color(0.14, 0.16, 0.26, 1.0)
	var head_y := feet_y - fig_h * 0.84 - jump
	var torso_top := feet_y - fig_h * 0.70 - jump * 0.9
	var hip_y := feet_y - fig_h * 0.40 - jump * 0.4
	# 头光（青）
	draw_circle(Vector2(cx, head_y), 7.8 * scale, Color(0.55, 0.88, 1.0, 0.28 + sin(_t * 3.6) * 0.05))
	draw_circle(Vector2(cx, head_y), 6.6 * scale, ink)
	# 发束
	draw_line(Vector2(cx + 2.8 * scale, head_y - 1.5 * scale), Vector2(cx + 13.0 * scale, head_y - 11.0 * scale), ink, 3.4 * scale, true)
	# 躯干
	draw_rect(Rect2(cx - 4.6 * scale, torso_top, 9.2 * scale, fig_h * 0.32), ink)
	# 双臂上扬 V
	draw_line(Vector2(cx - 3.2 * scale, torso_top + 7.0 * scale), Vector2(cx - 24.0 * scale, head_y - 20.0 * scale), ink, 4.6 * scale, true)
	draw_line(Vector2(cx + 3.2 * scale, torso_top + 7.0 * scale), Vector2(cx + 24.0 * scale, head_y - 20.0 * scale), ink, 4.6 * scale, true)
	draw_circle(Vector2(cx - 24.0 * scale, head_y - 20.0 * scale), 3.4 * scale, ink)
	draw_circle(Vector2(cx + 24.0 * scale, head_y - 20.0 * scale), 3.4 * scale, ink)
	# 腿
	draw_line(Vector2(cx - 2.2 * scale, hip_y), Vector2(cx - 15.0 * scale, feet_y + jump * 0.1), ink, 4.6 * scale, true)
	draw_line(Vector2(cx + 2.2 * scale, hip_y), Vector2(cx + 11.0 * scale, feet_y - fig_h * 0.2 + jump * 0.05), ink, 4.6 * scale, true)
	# 倒影（下半光影）
	var ref_a: float = 0.2 * clampf(1.0 - jump / (16.0 * scale), 0.3, 1.0)
	draw_set_transform(Vector2(cx, horizon_y + fig_h * 0.1), 0.0, Vector2(16.0 * scale, 3.6 * scale))
	draw_circle(Vector2.ZERO, 1.0, Color(0.0, 0.05, 0.1, ref_a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_lower_veil(sz: Vector2, horizon_y: float) -> void:
	var floor_top := horizon_y + 1.0
	var floor_h := sz.y - floor_top
	if floor_h <= 1.0:
		return
	# 深蓝底 + 顶部青雾光影
	var top_col := Color(0.06, 0.09, 0.14, 1.0)
	var mid_col := Color(0.04, 0.06, 0.11, 1.0)
	var bot_col := Color(0.025, 0.035, 0.07, 1.0)
	for i in 20:
		var t0 := float(i) / 20.0
		var t1 := float(i + 1) / 20.0
		var y0 := floor_top + floor_h * t0
		var y1 := floor_top + floor_h * t1
		var c0 := top_col.lerp(mid_col, smoothstep(0.0, 0.4, t0)).lerp(bot_col, smoothstep(0.5, 1.0, t0))
		draw_rect(Rect2(0.0, y0, sz.x, y1 - y0 + 1.0), c0)
	# 地平线下青蓝光影弥散
	var pulse: float = 0.9 + sin(_t * 1.7) * 0.1
	for i in 5:
		var h := 28.0 + float(i) * 18.0
		var a := (0.07 - float(i) * 0.01) * pulse
		draw_rect(Rect2(0.0, floor_top, sz.x, h), Color(0.28, 0.62, 0.88, maxf(a, 0.0)))
	# 极淡中央紫残光
	draw_circle(Vector2(sz.x * 0.5, floor_top + floor_h * 0.12), sz.x * 0.22, Color(0.42, 0.32, 0.7, 0.04 * pulse))
