extends Control
## 任务详情底部弹层（对齐 Tasks UI 设计稿）

signal closed
signal accept_pressed(planet_id: String, location_id: String, mission_id: String)

const UI_TEXT := Color(0.957, 0.984, 1.0)
const UI_MUTED := Color(0.576, 0.639, 0.71)
const UI_CYAN := Color(0.557, 0.882, 0.969)
const UI_CYAN_SOFT := Color(0.635, 0.925, 0.976)
const UI_ICE := Color(0.902, 0.988, 1.0)
const UI_MISSION_DONE := Color(0.34, 0.72, 0.58)
const UI_EMBER_RUN_BG := Color(0.29, 0.055, 0.09, 0.58)
const UI_EMBER_RUN_BORDER := Color(0.42, 0.11, 0.14, 0.82)
const UI_EMBER_RUN_GLOW := Color(0.64, 0.11, 0.11, 0.30)
const UI_EMBER_RUN_TEXT := Color(0.93, 0.78, 0.76)
const UI_REWARD_CLAIM := ClaimButtonUI.HIGHLIGHT

const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")

const CARGO_ICON_DESIGN_PX := 64.0

var _design_size := Vector2(682.0, 1228.0)
var _viewport_size := Vector2(1080.0, 1920.0)
var _mask: ColorRect
var _sheet: PanelContainer
var _body: VBoxContainer
var _accept: Button
var _close_btn: Button
var _planet_id := ""
var _location_id := ""
var _mission_id := ""
var _reward := 0
var _tween: Tween
var _outpost_name_cb: Callable = Callable()
var _built := false
var _preview_locked := false


func configure(viewport_size: Vector2, design_size: Vector2, outpost_name_cb: Callable = Callable()) -> void:
	_viewport_size = viewport_size
	_design_size = design_size
	_outpost_name_cb = outpost_name_cb


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	z_index = 80
	_build()


func _spec_w(design_px: float) -> int:
	return int(round(design_px * (_viewport_size.x / _design_size.x)))


func _spec_h(design_px: float) -> int:
	return int(round(design_px * (_viewport_size.y / _design_size.y)))


func _spec_fs(design_px: float) -> int:
	return _spec_w(design_px)


func _spec_em(design_font_px: float, em: float) -> int:
	return int(round(design_font_px * em * (_viewport_size.x / _design_size.x)))


func _build() -> void:
	if _built:
		return
	_built = true

	_mask = ColorRect.new()
	_mask.name = "TaskDetailMask"
	_mask.color = Color(0.008, 0.02, 0.039, 0.6)
	_mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	_mask.gui_input.connect(_on_mask_gui_input)
	add_child(_mask)

	_sheet = PanelContainer.new()
	_sheet.name = "TaskDetailSheet"
	_sheet.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_sheet.anchor_top = 0.26
	_sheet.offset_top = 0
	_sheet.offset_bottom = 0
	_sheet.offset_left = 0
	_sheet.offset_right = 0
	_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	_sheet.z_index = 1
	var sheet_style := StyleBoxFlat.new()
	sheet_style.bg_color = Color(0.031, 0.067, 0.118, 0.92)
	sheet_style.border_color = Color(0.667, 0.902, 1.0, 0.35)
	sheet_style.border_width_left = 1
	sheet_style.border_width_top = 1
	sheet_style.border_width_right = 1
	sheet_style.border_width_bottom = 0
	sheet_style.corner_radius_top_left = _spec_w(28)
	sheet_style.corner_radius_top_right = _spec_w(28)
	sheet_style.shadow_color = Color(0.557, 0.882, 0.969, 0.12)
	sheet_style.shadow_size = 24
	sheet_style.content_margin_left = _spec_w(40)
	sheet_style.content_margin_right = _spec_w(40)
	sheet_style.content_margin_top = _spec_h(22)
	sheet_style.content_margin_bottom = _spec_h(28)
	_sheet.add_theme_stylebox_override("panel", sheet_style)
	add_child(_sheet)

	var root := VBoxContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", _spec_h(14))
	_sheet.add_child(root)

	var handle := ColorRect.new()
	handle.color = Color(0.627, 0.784, 0.922, 0.35)
	handle.custom_minimum_size = Vector2(_spec_w(82), maxi(_spec_h(6), 3))
	handle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	handle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(handle)

	# 标题行：左侧占位 + 右侧关闭，避免锚点落在 0 宽 Control 上点不到
	var head_row := HBoxContainer.new()
	head_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head_row.add_theme_constant_override("separation", _spec_w(12))
	head_row.custom_minimum_size = Vector2(0, _spec_h(56))
	root.add_child(head_row)

	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head_row.add_child(head_spacer)

	_close_btn = Button.new()
	_close_btn.name = "TaskDetailClose"
	_close_btn.focus_mode = Control.FOCUS_NONE
	_close_btn.text = "✕"
	_close_btn.custom_minimum_size = Vector2(_spec_w(56), _spec_w(56))
	_close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_close_btn.add_theme_font_size_override("font_size", _spec_fs(22))
	_close_btn.add_theme_color_override("font_color", UI_TEXT)
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color(0.063, 0.137, 0.227, 0.85)
	close_style.border_color = Color(0.667, 0.902, 1.0, 0.45)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(_spec_w(28))
	close_style.content_margin_left = 0
	close_style.content_margin_right = 0
	close_style.content_margin_top = 0
	close_style.content_margin_bottom = 0
	_close_btn.add_theme_stylebox_override("normal", close_style)
	_close_btn.add_theme_stylebox_override("hover", close_style)
	_close_btn.add_theme_stylebox_override("pressed", close_style)
	_close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_close_btn.pressed.connect(_on_close_pressed)
	_close_btn.gui_input.connect(_on_close_gui_input)
	head_row.add_child(_close_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(scroll)

	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_theme_constant_override("separation", _spec_h(14))
	scroll.add_child(_body)

	_accept = Button.new()
	_accept.focus_mode = Control.FOCUS_NONE
	_accept.custom_minimum_size = Vector2(0, _spec_h(72))
	_accept.mouse_filter = Control.MOUSE_FILTER_STOP
	_accept.add_theme_font_size_override("font_size", _spec_fs(24))
	_accept.add_theme_constant_override("letter_spacing", _spec_em(24, 0.16))
	_accept.add_theme_color_override("font_color", UI_ICE)
	var accept_style := StyleBoxFlat.new()
	accept_style.bg_color = Color(0.314, 0.549, 0.745, 0.55)
	accept_style.border_color = Color(0.745, 0.933, 1.0, 0.65)
	accept_style.set_border_width_all(1)
	accept_style.set_corner_radius_all(_spec_w(18))
	accept_style.shadow_color = Color(0.557, 0.882, 0.969, 0.45)
	accept_style.shadow_size = 14
	accept_style.content_margin_left = _spec_w(18)
	accept_style.content_margin_right = _spec_w(18)
	accept_style.content_margin_top = _spec_h(10)
	accept_style.content_margin_bottom = _spec_h(10)
	_accept.add_theme_stylebox_override("normal", accept_style)
	_accept.add_theme_stylebox_override("hover", accept_style)
	_accept.add_theme_stylebox_override("pressed", accept_style)
	_accept.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_accept.pressed.connect(_on_accept_pressed)
	root.add_child(_accept)


func _on_mask_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()
		accept_event()


func _on_close_pressed() -> void:
	close()


func _on_close_gui_input(event: InputEvent) -> void:
	# 兜底：部分机型 pressed 信号偶发不触发时，仍可用 gui_input 关闭
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()
		accept_event()


func _on_accept_pressed() -> void:
	accept_pressed.emit(_planet_id, _location_id, _mission_id)


func _apply_accept_button_style(mode: String) -> void:
	if mode == "claim":
		ClaimButtonUI.apply(
			_accept,
			_spec_w(18),
			_spec_w(18),
			_spec_h(10),
			_spec_w(18),
			_spec_h(10),
			_spec_fs(24)
		)
		return
	var accept_style := StyleBoxFlat.new()
	match mode:
		"run":
			accept_style.bg_color = UI_EMBER_RUN_BG
			accept_style.border_color = UI_EMBER_RUN_BORDER
			accept_style.shadow_color = UI_EMBER_RUN_GLOW
			accept_style.shadow_size = 10
			_accept.add_theme_color_override("font_color", UI_EMBER_RUN_TEXT)
		"done":
			accept_style.bg_color = Color(0.12, 0.28, 0.22, 0.72)
			accept_style.border_color = Color(UI_MISSION_DONE.r, UI_MISSION_DONE.g, UI_MISSION_DONE.b, 0.75)
			accept_style.shadow_color = Color(UI_MISSION_DONE.r, UI_MISSION_DONE.g, UI_MISSION_DONE.b, 0.25)
			accept_style.shadow_size = 8
			_accept.add_theme_color_override("font_color", Color(0.88, 0.98, 0.92))
		"preview":
			accept_style.bg_color = Color(0.16, 0.10, 0.04, 0.72)
			accept_style.border_color = Color(0.98, 0.74, 0.28, 0.78)
			accept_style.shadow_color = Color(0.98, 0.74, 0.28, 0.22)
			accept_style.shadow_size = 6
			_accept.add_theme_color_override("font_color", Color(0.98, 0.82, 0.42))
		_:
			accept_style.bg_color = Color(0.06, 0.10, 0.16, 0.88)
			accept_style.border_color = Color(0.667, 0.902, 1.0, 0.45)
			accept_style.shadow_color = Color(0.557, 0.882, 0.969, 0.25)
			accept_style.shadow_size = 8
			_accept.add_theme_color_override("font_color", UI_ICE)
	accept_style.set_border_width_all(1)
	accept_style.set_corner_radius_all(_spec_w(18))
	accept_style.content_margin_left = _spec_w(18)
	accept_style.content_margin_right = _spec_w(18)
	accept_style.content_margin_top = _spec_h(10)
	accept_style.content_margin_bottom = _spec_h(10)
	_accept.add_theme_stylebox_override("normal", accept_style)
	_accept.add_theme_stylebox_override("hover", accept_style)
	_accept.add_theme_stylebox_override("pressed", accept_style)


func open(planet_id: String, mission: Dictionary) -> void:
	if not _built:
		_build()
	var location_id := String(mission.get("location_id", "dome"))
	var mission_id := Global.mission_key(mission)
	var profile: Dictionary = MissionTypes.resolve(mission)
	var type_en := String(mission.get("task_type", profile.get("task_type", "Supply Run"))).to_upper()
	if not type_en.ends_with(" RUN") and "RUN" not in type_en:
		type_en = "%s RUN" % type_en
	var type_zh := String(mission.get("task_type_zh", profile.get("name_zh", "补给")))
	var reward := int(mission.get("base_reward", profile.get("base_reward", 100 + int(mission.get("difficulty", 1)) * 10)))
	var duration_s := int(mission.get("duration", profile.get("duration", 60)))
	var timed := bool(profile.get("timed_fail", false))
	var time_text := "%ds LIMIT" % duration_s if timed else "%d-%ds" % [maxi(duration_s - 10, 30), duration_s]
	var outpost := String(mission.get("target_hearth", mission.get("source_hearth", location_id)))
	if _outpost_name_cb.is_valid():
		outpost = String(_outpost_name_cb.call(location_id, outpost))
	var cargo_name := String(mission.get("cargo_name", "Cargo"))
	var cargo_en := String(mission.get("cargo_name_en", "")).strip_edges()
	var cargo_text := cargo_en if cargo_en != "" else cargo_name
	var trait_text := _cargo_trait(mission, profile)
	var tip := _tip_text(mission, profile)
	var diff := clampi(int(mission.get("difficulty", 1)), 1, 5)
	var accepted := Global.is_mission_accepted(planet_id, mission_id)
	var location_lit := Global.get_completed_runner_locations(planet_id).has(location_id)
	var mission_done := Global.is_mission_completed(planet_id, mission_id)
	var reward_pending := Global.is_mission_reward_pending(planet_id, mission_id)
	var reward_claimed := Global.is_mission_reward_claimed(planet_id, mission_id)
	var progress_target := MissionTypes.mission_progress_target(mission)
	var progress_now := Global.get_mission_progress(planet_id, mission_id)
	var preview_locked := MissionDispatch.is_preview_location(planet_id, location_id)

	_planet_id = planet_id
	_location_id = location_id
	_mission_id = mission_id
	_reward = reward
	_preview_locked = preview_locked

	for child in _body.get_children():
		child.queue_free()

	var title := Label.new()
	title.text = type_en
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", _spec_fs(40))
	title.add_theme_color_override("font_color", UI_TEXT)
	title.add_theme_constant_override("letter_spacing", _spec_em(40, 0.04))
	_body.add_child(title)

	var sub := Label.new()
	sub.text = "%s运输" % type_zh
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub.add_theme_font_size_override("font_size", _spec_fs(22))
	sub.add_theme_color_override("font_color", UI_MUTED)
	_body.add_child(sub)

	if preview_locked:
		var lock_panel := PanelContainer.new()
		lock_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var lock_style := StyleBoxFlat.new()
		lock_style.bg_color = Color(0.18, 0.10, 0.04, 0.55)
		lock_style.border_color = Color(0.98, 0.74, 0.28, 0.82)
		lock_style.set_border_width_all(1)
		lock_style.set_corner_radius_all(_spec_w(12))
		lock_style.content_margin_left = _spec_w(16)
		lock_style.content_margin_right = _spec_w(16)
		lock_style.content_margin_top = _spec_h(12)
		lock_style.content_margin_bottom = _spec_h(12)
		lock_panel.add_theme_stylebox_override("panel", lock_style)
		_body.add_child(lock_panel)
		var lock_lbl := Label.new()
		lock_lbl.text = "预览模式 · 批次正式解锁前可试玩体验\n点击底部「试玩体验」直接进入关卡调优（进度暂不计入任务板）"
		lock_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lock_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock_lbl.add_theme_font_size_override("font_size", _spec_fs(18))
		lock_lbl.add_theme_color_override("font_color", Color(0.98, 0.82, 0.42))
		lock_panel.add_child(lock_lbl)

	var rows := VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", _spec_h(16))
	_body.add_child(rows)

	_add_row(rows, "OUTPOST", "📍  %s" % outpost)
	_add_cargo_row(rows, planet_id, mission, cargo_text, trait_text)

	var diff_host := HBoxContainer.new()
	diff_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diff_host.add_theme_constant_override("separation", _spec_w(12))
	var bars := HBoxContainer.new()
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bars.add_theme_constant_override("separation", _spec_w(6))
	for i in 5:
		var seg := ColorRect.new()
		seg.custom_minimum_size = Vector2(_spec_w(22), _spec_h(10))
		seg.color = UI_CYAN if i < diff else Color(0.18, 0.24, 0.30, 0.85)
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bars.add_child(seg)
	diff_host.add_child(bars)
	var diff_lbl := Label.new()
	diff_lbl.text = _difficulty_label(diff)
	diff_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diff_lbl.add_theme_font_size_override("font_size", _spec_fs(20))
	diff_lbl.add_theme_color_override("font_color", UI_MUTED)
	diff_host.add_child(diff_lbl)
	_add_row_control(rows, "DIFFICULTY", diff_host)

	_add_row(rows, "TIME", "⏱  %s" % time_text)
	if mission_done:
		_add_row(rows, "PROGRESS", "✓  %d / %d" % [progress_target, progress_target], ClaimButtonUI.DONE)
	else:
		_add_row(rows, "PROGRESS", "▣  %d / %d" % [progress_now, progress_target])
	if reward_pending:
		_add_row(rows, "REWARD", "★  %d" % reward, UI_REWARD_CLAIM)
	elif mission_done and reward_claimed:
		_add_row(rows, "REWARD", "★  %d" % reward, ClaimButtonUI.DONE)
	else:
		_add_row(rows, "REWARD", "★  完成奖励 %d（跑酷采集另计）" % reward, UI_CYAN)

	var mechanics := _mechanics_text(mission, profile)
	if mechanics != "":
		var mech_panel := PanelContainer.new()
		mech_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mech_style := StyleBoxFlat.new()
		mech_style.bg_color = Color(0.04, 0.08, 0.14, 0.55)
		mech_style.border_color = Color(0.557, 0.882, 0.969, 0.45)
		mech_style.set_border_width_all(1)
		mech_style.set_corner_radius_all(_spec_w(12))
		mech_style.content_margin_left = _spec_w(18)
		mech_style.content_margin_right = _spec_w(18)
		mech_style.content_margin_top = _spec_h(14)
		mech_style.content_margin_bottom = _spec_h(14)
		mech_panel.add_theme_stylebox_override("panel", mech_style)
		_body.add_child(mech_panel)
		var mech_box := VBoxContainer.new()
		mech_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mech_box.add_theme_constant_override("separation", _spec_h(8))
		mech_panel.add_child(mech_box)
		var mech_title := Label.new()
		mech_title.text = "机制说明"
		mech_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mech_title.add_theme_font_size_override("font_size", _spec_fs(18))
		mech_title.add_theme_color_override("font_color", UI_CYAN_SOFT)
		mech_box.add_child(mech_title)
		var mech_body := Label.new()
		mech_body.text = mechanics
		mech_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		mech_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mech_body.add_theme_font_size_override("font_size", _spec_fs(20))
		mech_body.add_theme_color_override("font_color", UI_TEXT)
		mech_box.add_child(mech_body)

	var tip_panel := PanelContainer.new()
	tip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tip_style := StyleBoxFlat.new()
	tip_style.bg_color = Color(0.12, 0.08, 0.04, 0.35)
	tip_style.border_color = Color(0.75, 0.48, 0.28, 0.75)
	tip_style.set_border_width_all(1)
	tip_style.set_corner_radius_all(_spec_w(12))
	tip_style.content_margin_left = _spec_w(18)
	tip_style.content_margin_right = _spec_w(18)
	tip_style.content_margin_top = _spec_h(14)
	tip_style.content_margin_bottom = _spec_h(14)
	tip_panel.add_theme_stylebox_override("panel", tip_style)
	_body.add_child(tip_panel)
	var tip_l := Label.new()
	tip_l.text = tip
	tip_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip_l.add_theme_font_size_override("font_size", _spec_fs(20))
	tip_l.add_theme_color_override("font_color", Color(0.93, 0.72, 0.42))
	tip_panel.add_child(tip_l)

	if reward_pending:
		_accept.text = "★ %d" % reward
		_apply_accept_button_style("claim")
	elif preview_locked:
		if MissionDispatch.can_preview_trial_run(planet_id, location_id):
			_accept.text = "试玩体验"
			_apply_accept_button_style("run")
		else:
			_accept.text = "批次未解锁"
			_apply_accept_button_style("preview")
	elif mission_done:
		_accept.text = "REPLAY"
		_apply_accept_button_style("done")
	elif location_lit:
		_accept.text = "REPLAY"
		_apply_accept_button_style("done")
	elif accepted:
		_accept.text = "RUN"
		_apply_accept_button_style("run")
	else:
		_accept.text = "ACCEPT"
		_apply_accept_button_style("accept")

	# 提到最前，避免被底栏 / 状态栏挡住点击
	if get_parent() != null:
		get_parent().move_child(self, -1)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	modulate = Color(1, 1, 1, 1)
	_sheet.modulate.a = 0.0
	_sheet.offset_top = float(_spec_h(48))
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_sheet, "modulate:a", 1.0, 0.2)
	_tween.parallel().tween_property(_sheet, "offset_top", 0.0, 0.26)


func close() -> void:
	if not visible:
		return
	if _tween:
		_tween.kill()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	closed.emit()


func refresh_if_open(planet_id: String, mission: Dictionary) -> void:
	if visible and planet_id == _planet_id and Global.mission_key(mission) == _mission_id:
		open(planet_id, mission)


func _cargo_trait(mission: Dictionary, profile: Dictionary) -> String:
	var custom := String(mission.get("cargo_trait", "")).strip_edges()
	if custom != "":
		return custom
	var fragility := float(mission.get("cargo_fragility", 0.0))
	if fragility >= 1.35:
		return "极脆 · ×%.1f" % fragility
	var load_n := int(mission.get("cargo_load", 0))
	var mid := String(profile.get("id", "supply"))
	if load_n >= 90:
		return "超重 · 单击短跳"
	if mid == "emergency":
		return "极脆 · 限时冲刺"
	if mid == "ignition":
		return "高压 · 注意追击"
	if mid == "repair":
		return "密障 · 完整度优先"
	if mid == "relay":
		return "中继 · 分叉选择"
	if fragility > 0.0 and fragility < 0.95:
		return "稳健 · ×%.1f" % fragility
	return "标准载荷"


func _tip_text(mission: Dictionary, profile: Dictionary) -> String:
	if MissionTypes.normalize_type(String(mission.get("task_type", profile.get("task_type", "")))) == "Emergency Run":
		var env := String(mission.get("environment_factor", "")).strip_edges()
		if env != "":
			return env
	if MissionTypes.is_overweight_cargo(mission):
		var env_over := String(mission.get("environment_factor", "")).strip_edges()
		if env_over != "":
			return env_over
		return "负重运输：注意跳跃节奏，保护建设包完整度。"
	var rhythm := String(mission.get("runner_rhythm", "")).strip_edges()
	if rhythm != "":
		return rhythm
	var hint := String(mission.get("task_hint", profile.get("hint", ""))).strip_edges()
	if hint != "":
		return hint
	return "完成运输以推进据点修复进度。"


func _mechanics_text(mission: Dictionary, profile: Dictionary) -> String:
	var custom := String(mission.get("mechanics_hint", "")).strip_edges()
	if custom != "":
		return custom
	if MissionTypes.is_overweight_cargo(mission):
		var rhythm := String(mission.get("runner_rhythm", "")).strip_edges()
		if rhythm != "":
			return rhythm
		return "超重建设包：单击短跳更低，快速双击才是满跳。跳跃障碍请连点两次；贴墙就绪时单击即可上墙。"
	if MissionTypes.normalize_type(String(mission.get("task_type", profile.get("task_type", "")))) != "Emergency Run":
		return ""
	if not bool(profile.get("timed_fail", false)):
		return ""
	return "限时挑战：多吃加速靴提速。集满 5 个解锁紧急冲刺（电脑 Shift/E，手机点按冲刺键）。"


func _difficulty_label(diff: int) -> String:
	match clampi(diff, 1, 5):
		1:
			return "教学"
		2:
			return "简单"
		3:
			return "标准"
		4:
			return "困难"
		_:
			return "极限"


func _add_cargo_row(parent: Control, planet_id: String, mission: Dictionary, cargo_text: String, trait_text: String) -> void:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", _spec_w(18))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(row)

	var key := Label.new()
	key.text = "CARGO"
	key.mouse_filter = Control.MOUSE_FILTER_IGNORE
	key.custom_minimum_size = Vector2(_spec_w(140), 0)
	key.add_theme_font_size_override("font_size", _spec_fs(18))
	key.add_theme_color_override("font_color", UI_MUTED)
	key.add_theme_constant_override("letter_spacing", _spec_em(18, 0.2))
	row.add_child(key)

	var value := HBoxContainer.new()
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value.add_theme_constant_override("separation", _spec_w(14))
	row.add_child(value)

	var icon_path := _cargo_icon_path(planet_id, mission)
	var icon_tex: Texture2D = _load_cargo_icon_texture(icon_path)
	if icon_tex != null:
		var icon_px := _spec_w(CARGO_ICON_DESIGN_PX)
		var icon_pad := _spec_w(6)
		var icon_wrap := PanelContainer.new()
		icon_wrap.custom_minimum_size = Vector2(icon_px, icon_px)
		icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon_style := StyleBoxFlat.new()
		icon_style.bg_color = Color(0.06, 0.10, 0.16, 0.92)
		icon_style.border_color = Color(0.667, 0.902, 1.0, 0.35)
		icon_style.set_border_width_all(1)
		icon_style.set_corner_radius_all(_spec_w(12))
		icon_style.content_margin_left = icon_pad
		icon_style.content_margin_right = icon_pad
		icon_style.content_margin_top = icon_pad
		icon_style.content_margin_bottom = icon_pad
		icon_wrap.add_theme_stylebox_override("panel", icon_style)
		value.add_child(icon_wrap)
		var icon_rect := TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_wrap.add_child(icon_rect)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_theme_constant_override("separation", _spec_h(4))
	value.add_child(text_col)

	var cargo_l := Label.new()
	cargo_l.text = cargo_text
	cargo_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cargo_l.add_theme_font_size_override("font_size", _spec_fs(22))
	cargo_l.add_theme_color_override("font_color", UI_TEXT)
	text_col.add_child(cargo_l)

	var trait_l := Label.new()
	trait_l.text = trait_text
	trait_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trait_l.add_theme_font_size_override("font_size", _spec_fs(20))
	trait_l.add_theme_color_override("font_color", UI_CYAN_SOFT)
	text_col.add_child(trait_l)


func _cargo_icon_path(planet_id: String, mission: Dictionary) -> String:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_cargo_icon_path"):
		return String(cfg.get_cargo_icon_path(mission))
	return ""


func _load_cargo_icon_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		var tex: Variant = load(path)
		if tex is Texture2D:
			return tex as Texture2D
	var fs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(fs_path):
		var img := Image.load_from_file(fs_path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null


func _add_row(parent: Control, label: String, value: String, value_color: Color = UI_TEXT) -> HBoxContainer:
	var value_host := HBoxContainer.new()
	value_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_host.add_theme_constant_override("separation", _spec_w(12))
	var value_l := Label.new()
	value_l.text = value
	value_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_l.add_theme_font_size_override("font_size", _spec_fs(22))
	value_l.add_theme_color_override("font_color", value_color)
	value_host.add_child(value_l)
	_add_row_control(parent, label, value_host)
	return value_host


func _add_row_control(parent: Control, label: String, value_control: Control) -> void:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", _spec_w(18))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(row)
	var key := Label.new()
	key.text = label
	key.mouse_filter = Control.MOUSE_FILTER_IGNORE
	key.custom_minimum_size = Vector2(_spec_w(140), 0)
	key.add_theme_font_size_override("font_size", _spec_fs(18))
	key.add_theme_color_override("font_color", UI_MUTED)
	key.add_theme_constant_override("letter_spacing", _spec_em(18, 0.2))
	row.add_child(key)
	value_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_control)
