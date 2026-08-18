extends Control
## 参考视频 47–53s：屏幕中央叠放 +15，连吃 xN 角标

const BRIGHT := Color(1.0, 0.94, 0.42)
const GOLD := Color(1.0, 0.88, 0.28)
const OUTLINE := Color(0.22, 0.10, 0.02, 0.94)

var _combo_lbl: Label
var _combo_streak := 0
var _combo_hide_timer := 0.0
var _value_labels: Array[Label] = []
var _value_hide_timer := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 78


func _process(delta: float) -> void:
	if _combo_hide_timer > 0.0:
		_combo_hide_timer = maxf(_combo_hide_timer - delta, 0.0)
		if _combo_hide_timer <= 0.0 and _combo_lbl != null and is_instance_valid(_combo_lbl):
			var fade := create_tween()
			fade.tween_property(_combo_lbl, "modulate:a", 0.0, 0.18)
			fade.chain().tween_callback(func():
				if _combo_lbl != null and is_instance_valid(_combo_lbl):
					_combo_lbl.queue_free()
				_combo_lbl = null
				_combo_streak = 0
			)
	if _value_hide_timer > 0.0:
		_value_hide_timer = maxf(_value_hide_timer - delta, 0.0)
		if _value_hide_timer <= 0.0:
			_clear_value_labels()


func play_value_pop(value: int, streak: int) -> void:
	var slot := maxi(streak - 1, 0) % 4
	var lbl := Label.new()
	lbl.name = "CoinValuePop_%d" % slot
	lbl.text = "+%d" % value
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.z_index = 80
	var font_size := 76 + mini(streak, 10) * 4
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", BRIGHT)
	lbl.add_theme_color_override("font_outline_color", OUTLINE)
	lbl.add_theme_constant_override("outline_size", 10)
	lbl.modulate = Color(1, 1, 1, 0.98)
	add_child(lbl)
	lbl.reset_size()
	lbl.pivot_offset = lbl.size * 0.5
	# 参考 50s：两枚 +15 在画面中轴略偏右、纵向叠放
	var cx := size.x * 0.52 + float(slot % 2) * 10.0
	var cy := size.y * (0.36 - float(slot) * 0.058)
	lbl.position = Vector2(cx, cy) - lbl.pivot_offset
	lbl.scale = Vector2(0.82, 0.82)
	_value_labels.append(lbl)
	_value_hide_timer = 0.72
	_reflow_value_labels()
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.14).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(lbl, "position:y", lbl.position.y - 18.0, 0.52).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.52).set_delay(0.16).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func():
		if is_instance_valid(lbl):
			_value_labels.erase(lbl)
			lbl.queue_free()
	)


func play_combo_only(streak: int, hide_sec: float = 1.05) -> void:
	if streak < 4:
		return
	_combo_streak = streak
	_combo_hide_timer = hide_sec
	if _combo_lbl == null or not is_instance_valid(_combo_lbl):
		_combo_lbl = Label.new()
		_combo_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_combo_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_combo_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_combo_lbl.z_index = 81
		add_child(_combo_lbl)
	_combo_lbl.text = "x%d" % streak
	var font_size := 40 + mini(streak, 14) * 2
	_combo_lbl.add_theme_font_size_override("font_size", font_size)
	_combo_lbl.add_theme_color_override("font_color", GOLD)
	_combo_lbl.add_theme_color_override("font_outline_color", OUTLINE)
	_combo_lbl.add_theme_constant_override("outline_size", 7)
	_combo_lbl.modulate = Color(1, 1, 1, 0.94)
	_combo_lbl.reset_size()
	_combo_lbl.pivot_offset = _combo_lbl.size * 0.5
	_combo_lbl.position = Vector2(size.x * 0.68, size.y * 0.18) - _combo_lbl.pivot_offset
	_combo_lbl.scale = Vector2.ONE


func clear_combo() -> void:
	_combo_hide_timer = 0.0
	_value_hide_timer = 0.0
	if _combo_lbl != null and is_instance_valid(_combo_lbl):
		_combo_lbl.queue_free()
	_combo_lbl = null
	_combo_streak = 0
	_clear_value_labels()


func _clear_value_labels() -> void:
	for lbl in _value_labels:
		if lbl != null and is_instance_valid(lbl):
			lbl.queue_free()
	_value_labels.clear()


func _reflow_value_labels() -> void:
	var n := _value_labels.size()
	for i in range(n):
		var lbl: Label = _value_labels[i]
		if lbl == null or not is_instance_valid(lbl):
			continue
		var slot := (n - 1 - i)
		var cx := size.x * 0.52 + float(slot % 2) * 10.0
		var cy := size.y * (0.36 - float(slot) * 0.058)
		lbl.pivot_offset = lbl.size * 0.5
		lbl.position = Vector2(cx, cy) - lbl.pivot_offset
