extends RefCounted

## 地图列表卡片切角框线（Map Archive UI）


class MapCardFrameOverlay extends Control:
	var fill := Color(0.047, 0.094, 0.165, 0.55)
	var stroke := Color(0.769, 0.941, 1.0, 0.92)
	var stroke_glow := Color(0.627, 0.902, 1.0, 0.45)

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		if size.x < 8.0 or size.y < 4.0:
			return
		var pts := _outline(Rect2(Vector2.ZERO, size))
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_colored_polygon(pts, fill)
		draw_polyline(closed, stroke_glow, 3.2, true)
		draw_polyline(closed, stroke, 1.5, true)

	static func _outline(rect: Rect2) -> PackedVector2Array:
		var x: float = rect.position.x
		var y: float = rect.position.y
		var w: float = rect.size.x
		var h: float = rect.size.y
		var sx: float = w / 594.0
		var sy: float = h / 174.0
		return PackedVector2Array([
			Vector2(x + 16.0 * sx, y + 3.0 * sy),
			Vector2(x + 578.0 * sx, y + 3.0 * sy),
			Vector2(x + 591.0 * sx, y + 17.0 * sy),
			Vector2(x + 591.0 * sx, y + 157.0 * sy),
			Vector2(x + 578.0 * sx, y + 171.0 * sy),
			Vector2(x + 16.0 * sx, y + 171.0 * sy),
			Vector2(x + 3.0 * sx, y + 157.0 * sy),
			Vector2(x + 3.0 * sx, y + 17.0 * sy),
		])
