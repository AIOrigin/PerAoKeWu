extends Control

## 结算页庆祝剪影：jump（跃起双臂上扬）

var figure_kind := "jump"
var anim_phase := 0.0

var _t := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(140, 200)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	pivot_offset = Vector2(size.x * 0.5, size.y * 0.92)


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	queue_redraw()


func _draw() -> void:
	var sz := size
	if sz.x < 8.0 or sz.y < 8.0:
		return
	var ink := Color(0.16, 0.18, 0.28, 1.0)
	var cx := sz.x * 0.5
	var lift := (0.5 + 0.5 * sin((_t + anim_phase) * 6.2)) * sz.y * 0.04
	var head_y := sz.y * 0.16 - lift
	var torso_top := sz.y * 0.28 - lift * 0.7
	var hip_y := sz.y * 0.58 - lift * 0.3
	var ground := sz.y * 0.94

	# 头部外圈微光
	draw_circle(Vector2(cx, head_y), sz.x * 0.12, Color(0.55, 0.88, 1.0, 0.28))
	draw_circle(Vector2(cx, head_y), sz.x * 0.10, ink)
	# 发束
	draw_line(Vector2(cx + sz.x * 0.04, head_y - sz.y * 0.01), Vector2(cx + sz.x * 0.22, head_y - sz.y * 0.08), ink, sz.x * 0.055, true)
	# 躯干
	draw_rect(Rect2(cx - sz.x * 0.07, torso_top, sz.x * 0.14, sz.y * 0.28), ink)
	# 双臂上扬 V
	draw_line(Vector2(cx - sz.x * 0.05, torso_top + sz.y * 0.06), Vector2(cx - sz.x * 0.40, head_y - sz.y * 0.12), ink, sz.x * 0.08, true)
	draw_line(Vector2(cx + sz.x * 0.05, torso_top + sz.y * 0.06), Vector2(cx + sz.x * 0.40, head_y - sz.y * 0.12), ink, sz.x * 0.08, true)
	draw_circle(Vector2(cx - sz.x * 0.40, head_y - sz.y * 0.12), sz.x * 0.055, ink)
	draw_circle(Vector2(cx + sz.x * 0.40, head_y - sz.y * 0.12), sz.x * 0.055, ink)
	# 腿
	draw_line(Vector2(cx - sz.x * 0.03, hip_y), Vector2(cx - sz.x * 0.22, ground), ink, sz.x * 0.085, true)
	draw_line(Vector2(cx + sz.x * 0.03, hip_y), Vector2(cx + sz.x * 0.16, ground - sz.y * 0.18), ink, sz.x * 0.085, true)
