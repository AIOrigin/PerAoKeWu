extends Control
class_name SettlementSkyLayer

## 结算页上半天空：灰青蓝渐变（设计稿）

var horizon_ratio := 0.38


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var sz := size
	if sz.x < 8.0 or sz.y < 8.0:
		return
	var horizon_y: float = sz.y * horizon_ratio
	# 设计稿：顶部偏亮灰蓝 → 地平线附近略深
	var top := Color(0.52, 0.58, 0.66, 1.0)
	var mid := Color(0.30, 0.36, 0.46, 1.0)
	var near := Color(0.14, 0.18, 0.28, 1.0)
	for i in 32:
		var t0 := float(i) / 32.0
		var t1 := float(i + 1) / 32.0
		var y0 := horizon_y * t0
		var y1 := horizon_y * t1 + 1.0
		var c: Color
		if t0 < 0.45:
			c = top.lerp(mid, smoothstep(0.0, 0.45, t0))
		else:
			c = mid.lerp(near, smoothstep(0.45, 1.0, t0))
		draw_rect(Rect2(0.0, y0, sz.x, y1 - y0), c)
	draw_rect(Rect2(0.0, horizon_y, sz.x, sz.y - horizon_y), Color(0.035, 0.05, 0.09, 1.0))
