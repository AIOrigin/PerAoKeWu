extends RefCounted

## 首页框线装饰（只画边框，不填充 — 避免之前整块 _draw 撑满的问题）


class ChamferBorderOverlay extends Control:
	var stroke := Color(0.682, 0.914, 0.969, 0.88)
	var stroke_soft := Color(0.667, 0.902, 1.0, 0.45)
	var sheen := Color(0.824, 0.941, 0.996, 0.11)

	static func outline(rect: Rect2) -> PackedVector2Array:
		var x: float = rect.position.x
		var y: float = rect.position.y
		var w: float = rect.size.x
		var h: float = rect.size.y
		return PackedVector2Array([
			Vector2(x, y + h * 0.08),
			Vector2(x + w * 0.03, y),
			Vector2(x + w * 0.97, y),
			Vector2(x + w, y + h * 0.08),
			Vector2(x + w, y + h * 0.92),
			Vector2(x + w * 0.97, y + h),
			Vector2(x + w * 0.03, y + h),
			Vector2(x, y + h * 0.92),
		])

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		if size.x < 4.0 or size.y < 4.0:
			return
		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.38)), sheen, true)
		var pts := outline(rect)
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, stroke, 1.8, true)
		var mid_x: float = rect.size.x * 0.5
		var base_y: float = rect.size.y - 3.0
		for dx in [-9.0, 0.0, 9.0]:
			draw_line(Vector2(mid_x + dx, base_y), Vector2(mid_x + dx, base_y + 4.0), stroke_soft, 1.2)


class StartBracketOverlay extends Control:
	var stroke := Color(0.667, 0.902, 1.0, 0.58)
	var stroke_dim := Color(0.667, 0.902, 1.0, 0.38)

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		if size.x < 8.0 or size.y < 8.0:
			return
		var sx: float = size.x / 495.0
		var sy: float = size.y / 115.0
		_line(Vector2(12.0 * sx, 102.0 * sy), Vector2(24.0 * sx, 89.0 * sy), Vector2(46.0 * sx, 89.0 * sy))
		_line(Vector2(483.0 * sx, 102.0 * sy), Vector2(471.0 * sx, 89.0 * sy), Vector2(449.0 * sx, 89.0 * sy))
		var tick_y: float = size.y - 9.0 * sy
		for tx in [238.0, 247.0, 256.0]:
			var x: float = float(tx) * sx
			draw_line(Vector2(x, tick_y), Vector2(x, tick_y + 4.0 * sy), stroke_dim, 1.2)

	func _line(a: Vector2, b: Vector2, c: Vector2) -> void:
		draw_line(a, b, stroke, 1.4, true)
		draw_line(b, c, stroke, 1.4, true)
