class_name LocationDetailPopup
extends Control

signal closed
signal story_pressed
signal runner_pressed(mission_id: String)
signal reward_claim_pressed
signal view_runner_pressed(character_id: String)

const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const TaskDetailSheet = preload("res://assets/maps/route_levels/mobile_home/task_detail_sheet.gd")
const CharacterUnlockReveal = preload("res://assets/maps/route_levels/planet_explore/character_unlock_reveal.gd")

const BG := Color(0.03, 0.05, 0.08, 0.98)
const FRAME := Color(0.06, 0.08, 0.12, 0.98)
const FRAME_BORDER := Color(0.34, 0.52, 0.68, 0.92)
const PANEL := Color(0.08, 0.10, 0.14, 0.96)
const PANEL_BORDER := Color(0.24, 0.38, 0.52, 0.72)
const TEXT := Color(0.90, 0.93, 0.98)
const MUTED := Color(0.58, 0.64, 0.72)
const STATUS := Color(0.98, 0.74, 0.30)
const CYAN := Color(0.42, 0.86, 0.98)
const REWARD := Color(0.78, 0.62, 0.98)
const GOLD := Color(0.94, 0.72, 0.22)
const GOLD_BORDER := Color(0.98, 0.84, 0.42)
const UI_ICE := Color(0.902, 0.988, 1.0)
const UI_MISSION_DONE := Color(0.34, 0.72, 0.58)
const DETAIL_VIEWPORT := Vector2(1080, 1920)
const DETAIL_DESIGN := Vector2(682.0, 1228.0)

var _scroll: ScrollContainer
var _content_margin: MarginContainer
var _icon_label: Label
var _title_label: Label
var _title_en_label: Label
var _status_label: Label
var _desc_label: Label
var _manager_portrait: PanelContainer
var _manager_portrait_icon: TextureRect
var _manager_portrait_fallback: Label
var _manager_name: Label
var _manager_title: Label
var _manager_quote: Label
var _reward_coins_label: Label
var _reward_extra_label: Label
var _preview: TextureRect
var _repair_percent_label: Label
var _repair_bar: ProgressBar
var _repair_value_label: Label
var _needs_row: VBoxContainer
var _missions_box: VBoxContainer
var _stars_box: HBoxContainer
var _story_button: Button
var _reward_panel: PanelContainer
var _reward_claim_button: Button
var _reward_status_label: Label
var _pending_payload: Dictionary = {}
var _ui_built := false
var _location_id := ""
var _planet_id := "glass_desert"
var _selected_mission_id := ""
var _mission_card_refs: Array[Dictionary] = []
var _upper_block: VBoxContainer
var _missions_panel: PanelContainer
var _task_detail: Control
var _revealed := false
var _missions_cache: Array = []


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_ensure_ui()
	if _scroll:
		_scroll.resized.connect(_sync_scroll_size)
		call_deferred("_sync_scroll_size")
	if not _pending_payload.is_empty():
		_apply_payload(_pending_payload)
		_pending_payload.clear()


func present(payload: Dictionary) -> void:
	if not is_node_ready() or not _ui_built:
		_pending_payload = payload
		return
	_apply_payload(payload)


func _apply_payload(payload: Dictionary) -> void:
	_location_id = String(payload.get("location_id", ""))
	_planet_id = String(payload.get("planet_id", Global.exploration_planet_id))
	_selected_mission_id = ""
	_revealed = bool(payload.get("revealed", false))
	var preview := bool(payload.get("preview", false))
	_icon_label.text = String(payload.get("type_icon", "◎"))
	_title_label.text = String(payload.get("title", "Outpost Detail"))
	_title_en_label.visible = false
	_status_label.text = String(payload.get("status", ""))
	if _revealed:
		_desc_label.text = String(payload.get("description", ""))
	elif preview:
		_desc_label.text = "%s\n%s%s" % [
			String(payload.get("description", "")),
			String(payload.get("locked_hint", "")),
			"",
		]
	else:
		_desc_label.text = "This outpost is not open yet.%s" % String(payload.get("locked_hint", ""))
	_set_stars(int(payload.get("danger_stars", 3)))
	var preview_path := String(payload.get("preview_path", ""))
	if preview_path != "" and ResourceLoader.exists(preview_path):
		_preview.texture = load(preview_path) as Texture2D
		_preview.visible = true
	else:
		_preview.visible = false
	var repair_percent := int(payload.get("repair_percent", 0))
	_repair_percent_label.text = "%d%%" % repair_percent
	_repair_bar.max_value = 100.0
	_repair_bar.value = repair_percent
	_repair_value_label.text = "%d / %d" % [
		int(payload.get("repair_current", 0)),
		int(payload.get("repair_total", 0)),
	]
	_rebuild_needs(payload.get("needs", []))
	_rebuild_missions(payload.get("transport_missions", []), _revealed)
	var manager: Dictionary = payload.get("manager", {})
	var show_identity := bool(manager.get("show_identity", bool(payload.get("completed", false))))
	if show_identity:
		_manager_name.text = String(manager.get("name", ""))
		_manager_title.text = String(manager.get("title", ""))
		var quote_text := String(manager.get("quote", ""))
		_manager_quote.text = "\"%s\"" % quote_text if quote_text != "" else ""
	else:
		_manager_name.text = "???"
		_manager_title.text = "Unknown"
		_manager_quote.text = "Confirm the manager after lighting up this outpost."
	_apply_manager_portrait(manager, payload.get("manager_accent", Color(0.28, 0.48, 0.72)), show_identity)
	var rewards: Dictionary = payload.get("rewards", {})
	_reward_coins_label.text = "Ember Coins %d" % int(rewards.get("coins", 0))
	var unlock_character := String(rewards.get("unlock_character", ""))
	if unlock_character != "":
		_reward_extra_label.text = "Unlock New Runner: %s" % unlock_character
		_reward_extra_label.visible = true
	else:
		_reward_extra_label.visible = false
	_refresh_reward_claim_state(payload)
	_story_button.visible = false
	_ensure_task_detail()


func _refresh_reward_claim_state(payload: Dictionary) -> void:
	if _reward_claim_button == null or _reward_status_label == null:
		return
	var completed := bool(payload.get("completed", false))
	var planet_id := String(payload.get("planet_id", Global.exploration_planet_id))
	var coins := int(payload.get("rewards", {}).get("coins", 0))
	var claimed := Global.is_outpost_light_reward_claimed(planet_id, _location_id)
	var pending := Global.is_outpost_light_reward_pending(planet_id, _location_id)
	if not completed or coins <= 0:
		_reward_claim_button.visible = false
		_reward_status_label.text = "Claim after lighting up"
		_reward_status_label.visible = true
		return
	if claimed:
		_reward_claim_button.visible = false
		_reward_status_label.text = "Claimed"
		_reward_status_label.visible = true
		return
	if pending or completed:
		_reward_claim_button.visible = true
		_reward_claim_button.text = "CLAIM"
		_reward_claim_button.disabled = false
		_reward_status_label.visible = false
	else:
		_reward_claim_button.visible = false
		_reward_status_label.text = "Awaiting lighting"
		_reward_status_label.visible = true


func play_character_unlock_reveal(character_name: String) -> void:
	CharacterUnlockReveal.play(self, character_name, Callable(self, "_emit_view_runner").bind(character_name))


func _emit_view_runner(character_name: String) -> void:
	view_runner_pressed.emit(character_name.to_lower())


func _ensure_ui() -> void:
	if _ui_built:
		return
	_build_ui()
	_ui_built = true


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)

	var shell := VBoxContainer.new()
	shell.set_anchors_preset(PRESET_FULL_RECT)
	shell.add_theme_constant_override("separation", 0)
	add_child(shell)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	shell.add_child(_scroll)

	_content_margin = MarginContainer.new()
	_content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_margin.add_theme_constant_override("margin_left", 12)
	_content_margin.add_theme_constant_override("margin_top", 6)
	_content_margin.add_theme_constant_override("margin_right", 12)
	_content_margin.add_theme_constant_override("margin_bottom", 10)
	_scroll.add_child(_content_margin)

	var frame := PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", _panel_style(FRAME, FRAME_BORDER, 8, 2))
	_content_margin.add_child(frame)

	var frame_margin := MarginContainer.new()
	frame_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame_margin.add_theme_constant_override("margin_left", 12)
	frame_margin.add_theme_constant_override("margin_top", 8)
	frame_margin.add_theme_constant_override("margin_right", 12)
	frame_margin.add_theme_constant_override("margin_bottom", 6)
	frame.add_child(frame_margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	frame_margin.add_child(root)

	# —— 顶栏（加高，压住顶部空档） ——
	var header_wrap := PanelContainer.new()
	header_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_wrap.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.11, 0.16, 0.98), PANEL_BORDER, 8, 1))
	root.add_child(header_wrap)
	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 12)
	header_margin.add_theme_constant_override("margin_top", 12)
	header_margin.add_theme_constant_override("margin_right", 10)
	header_margin.add_theme_constant_override("margin_bottom", 12)
	header_wrap.add_child(header_margin)
	header_margin.add_child(_build_header())

	# —— 上半（红框）：地图立绘 / 负责人 / 奖励进度 —— 加大面积 ——
	_upper_block = VBoxContainer.new()
	_upper_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_upper_block.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_upper_block.size_flags_stretch_ratio = 1.55
	_upper_block.add_theme_constant_override("separation", 8)
	root.add_child(_upper_block)

	var top_row := HBoxContainer.new()
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_row.size_flags_stretch_ratio = 1.35
	top_row.add_theme_constant_override("separation", 10)
	_upper_block.add_child(top_row)
	top_row.add_child(_build_top_left_block())
	top_row.add_child(_build_preview_block())

	# —— 中部：点亮奖励 | 进度 ——
	_upper_block.add_child(_build_reward_progress_row())

	# —— 下半（绿框）：四个运输任务占位 ——
	var missions := _build_missions_block()
	missions.size_flags_stretch_ratio = 1.0
	root.add_child(missions)

	_story_button = Button.new()
	_story_button.text = "查看剧情"
	_story_button.visible = false
	_story_button.custom_minimum_size = Vector2(0, 36)
	_story_button.focus_mode = Control.FOCUS_NONE
	_style_flat_button(_story_button, Color(0.10, 0.12, 0.16), PANEL_BORDER, MUTED, 14)
	_story_button.pressed.connect(func(): story_pressed.emit())
	root.add_child(_story_button)

	_ensure_task_detail()


func _ensure_task_detail() -> void:
	if _task_detail != null and is_instance_valid(_task_detail):
		return
	_task_detail = TaskDetailSheet.new()
	_task_detail.configure(DETAIL_VIEWPORT, DETAIL_DESIGN, _outpost_display_name)
	_task_detail.accept_pressed.connect(_on_task_detail_accept)
	_task_detail.z_index = 120
	add_child(_task_detail)


func _outpost_display_name(location_id: String, fallback: String) -> String:
	match location_id:
		"dome":
			return "Residential Dome"
		"reservoir":
			return "Water Station"
		"medical":
			return "Medical Station"
		"relay":
			return "Relay Station"
		"gate":
			return "Defense Outpost"
		_:
			return fallback if fallback != "" else "Outpost"


func _open_task_detail(mission: Dictionary) -> void:
	_ensure_task_detail()
	_task_detail.open(_planet_id, mission.duplicate(true))


func _on_task_detail_accept(planet_id: String, location_id: String, mission_id: String = "") -> void:
	if mission_id == "":
		mission_id = location_id
	if MissionDispatch.is_preview_location(planet_id, location_id):
		if MissionDispatch.can_preview_trial_run(planet_id, location_id):
			var trial_mission := _find_mission(mission_id)
			if trial_mission.is_empty():
				return
			if _task_detail:
				_task_detail.close()
			_selected_mission_id = mission_id
			runner_pressed.emit(mission_id)
		else:
			_show_preview_toast()
		return
	var mission := _find_mission(mission_id)
	if mission.is_empty():
		return
	var mission_done := Global.is_mission_completed(planet_id, mission_id)
	var reward_pending := Global.is_mission_reward_pending(planet_id, mission_id)
	var location_lit := Global.get_completed_runner_locations(planet_id).has(location_id)
	var accepted := Global.is_mission_accepted(planet_id, mission_id)
	if reward_pending:
		var payout := Global.get_mission_reward_amount(planet_id, mission_id)
		if Global.claim_mission_reward(planet_id, mission_id, payout):
			_open_task_detail(mission)
			_rebuild_missions(_missions_cache, _revealed)
		return
	if mission_done or location_lit or accepted:
		if _task_detail:
			_task_detail.close()
		_selected_mission_id = mission_id
		runner_pressed.emit(mission_id)
		return
	Global.accept_mission(planet_id, mission_id)
	_open_task_detail(mission)
	_rebuild_missions(_missions_cache, _revealed)


func _find_mission(mission_id: String) -> Dictionary:
	for entry in _mission_card_refs:
		if String(entry.get("mission_id", "")) == mission_id:
			return entry.get("mission", {})
	for m in _missions_cache:
		if typeof(m) == TYPE_DICTIONARY and Global.mission_key(m) == mission_id:
			return m
	return {}


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 64)
	header.add_theme_constant_override("separation", 12)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(56, 56)
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_wrap.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.14, 0.20, 0.98), PANEL_BORDER, 8, 1))
	header.add_child(icon_wrap)
	_icon_label = Label.new()
	_icon_label.text = "💧"
	_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_icon_label.set_anchors_preset(PRESET_FULL_RECT)
	_icon_label.add_theme_font_size_override("font_size", 28)
	icon_wrap.add_child(_icon_label)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_box.add_theme_constant_override("separation", 3)
	header.add_child(title_box)
	_title_label = _make_label("", 28, TEXT)
	title_box.add_child(_title_label)
	_title_en_label = _make_label("", 15, MUTED)
	title_box.add_child(_title_en_label)

	var danger_box := VBoxContainer.new()
	danger_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	danger_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(danger_box)
	danger_box.add_child(_make_label("Danger Level", 14, MUTED))
	_stars_box = HBoxContainer.new()
	_stars_box.add_theme_constant_override("separation", 3)
	_stars_box.alignment = BoxContainer.ALIGNMENT_END
	danger_box.add_child(_stars_box)

	var close_button := Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(48, 48)
	close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close_button.focus_mode = Control.FOCUS_NONE
	_style_flat_button(close_button, Color(0.10, 0.12, 0.16), PANEL_BORDER, TEXT, 20)
	close_button.pressed.connect(_close)
	header.add_child(close_button)
	return header


func _build_top_left_block() -> Control:
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(250, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.48
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)

	var info_panel := _wrap_panel(PANEL, PANEL_BORDER)
	left.add_child(info_panel)
	var info_box := _panel_vbox(info_panel)
	info_box.add_theme_constant_override("separation", 6)
	_status_label = _make_label("Status: Transport Repair", 17, STATUS)
	info_box.add_child(_status_label)
	_desc_label = _make_label("", 15, Color(0.80, 0.84, 0.90))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.add_child(_desc_label)

	# 负责人：名字放标题旁，立绘横向铺满，避免挤成窄条
	var manager_panel := _wrap_panel(PANEL, PANEL_BORDER)
	manager_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(manager_panel)
	var manager_box := _panel_vbox(manager_panel)
	manager_box.add_theme_constant_override("separation", 8)

	var manager_head := HBoxContainer.new()
	manager_head.add_theme_constant_override("separation", 8)
	manager_box.add_child(manager_head)
	manager_head.add_child(_section_label("Manager"))
	_manager_name = _make_label("", 20, TEXT)
	_manager_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_manager_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	manager_head.add_child(_manager_name)

	_manager_portrait = PanelContainer.new()
	_manager_portrait.custom_minimum_size = Vector2(0, 250)
	_manager_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_manager_portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_manager_portrait.clip_contents = true
	_manager_portrait.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.12, 0.16, 0.96), PANEL_BORDER, 6, 1))
	manager_box.add_child(_manager_portrait)
	_manager_portrait_icon = TextureRect.new()
	_manager_portrait_icon.set_anchors_preset(PRESET_FULL_RECT)
	_manager_portrait_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_manager_portrait_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_manager_portrait_icon.visible = false
	_manager_portrait.add_child(_manager_portrait_icon)
	_manager_portrait_fallback = Label.new()
	_manager_portrait_fallback.set_anchors_preset(PRESET_FULL_RECT)
	_manager_portrait_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_manager_portrait_fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_manager_portrait_fallback.add_theme_font_size_override("font_size", 48)
	_manager_portrait.add_child(_manager_portrait_fallback)

	_manager_title = _make_label("", 15, MUTED)
	manager_box.add_child(_manager_title)
	_manager_quote = _make_label("", 14, Color(0.72, 0.78, 0.86))
	_manager_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_manager_quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	manager_box.add_child(_manager_quote)
	return left


func _build_preview_block() -> Control:
	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_stretch_ratio = 0.52
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_panel.custom_minimum_size = Vector2(0, 300)
	preview_panel.clip_contents = true
	var preview_style := _panel_style(PANEL, PANEL_BORDER, 6, 1)
	preview_style.content_margin_left = 0
	preview_style.content_margin_right = 0
	preview_style.content_margin_top = 0
	preview_style.content_margin_bottom = 0
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	_preview = TextureRect.new()
	_preview.custom_minimum_size = Vector2(0, 300)
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	preview_panel.add_child(_preview)
	return preview_panel


func _build_reward_progress_row() -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_theme_constant_override("separation", 10)

	_reward_panel = _wrap_panel(Color(0.16, 0.12, 0.04, 0.96), GOLD_BORDER)
	_reward_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reward_panel.size_flags_stretch_ratio = 0.46
	row.add_child(_reward_panel)
	var reward_box := _panel_vbox(_reward_panel)
	reward_box.add_theme_constant_override("separation", 8)
	reward_box.add_child(_make_label("Lighting Rewards", 15, GOLD))
	var reward_row := HBoxContainer.new()
	reward_row.add_theme_constant_override("separation", 8)
	reward_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_box.add_child(reward_row)
	reward_row.add_child(_make_label("✦", 22, GOLD))
	_reward_coins_label = _make_label("Ember Coins 0", 18, GOLD)
	_reward_coins_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reward_row.add_child(_reward_coins_label)
	_reward_claim_button = Button.new()
	_reward_claim_button.text = "CLAIM"
	_reward_claim_button.focus_mode = Control.FOCUS_NONE
	_reward_claim_button.custom_minimum_size = Vector2(96, 36)
	_reward_claim_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	ClaimButtonUI.apply(_reward_claim_button, 6.0, 10.0, 8.0, 10.0, 8.0, 14)
	_reward_claim_button.pressed.connect(func(): reward_claim_pressed.emit())
	reward_row.add_child(_reward_claim_button)
	_reward_extra_label = _make_label("", 21, Color(0.98, 0.90, 0.62))
	_reward_extra_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reward_extra_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reward_extra_label.visible = false
	reward_box.add_child(_reward_extra_label)
	_reward_status_label = _make_label("Claim after lighting up", 14, MUTED)
	reward_box.add_child(_reward_status_label)

	var repair_panel := _wrap_panel(PANEL, Color(0.32, 0.62, 0.82, 0.85))
	repair_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	repair_panel.size_flags_stretch_ratio = 0.54
	row.add_child(repair_panel)
	var repair_box := _panel_vbox(repair_panel)
	repair_box.add_theme_constant_override("separation", 8)
	var repair_top := HBoxContainer.new()
	repair_top.add_theme_constant_override("separation", 10)
	repair_box.add_child(repair_top)
	repair_top.add_child(_make_label("Progress", 15, MUTED))
	_repair_percent_label = _make_label("0%", 24, CYAN)
	_repair_percent_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_repair_percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	repair_top.add_child(_repair_percent_label)
	_repair_bar = ProgressBar.new()
	_repair_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_repair_bar.custom_minimum_size = Vector2(0, 26)
	_repair_bar.show_percentage = false
	_style_progress_bar(_repair_bar, CYAN)
	repair_box.add_child(_repair_bar)
	_repair_value_label = _make_label("0 / 0", 15, MUTED)
	_repair_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	repair_box.add_child(_repair_value_label)
	return row


func _build_missions_block() -> Control:
	_missions_panel = _wrap_panel(PANEL, PANEL_BORDER)
	_missions_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_missions_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_missions_panel.size_flags_stretch_ratio = 1.0
	var missions_box := _panel_vbox(_missions_panel)
	missions_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	missions_box.add_child(_section_label("Transport Missions · Tap for details"))
	_missions_box = VBoxContainer.new()
	_missions_box.add_theme_constant_override("separation", 6)
	_missions_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_missions_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	missions_box.add_child(_missions_box)
	_needs_row = VBoxContainer.new()
	_needs_row.visible = false
	missions_box.add_child(_needs_row)
	return _missions_panel


func _build_left_column() -> Control:
	# 兼容旧调用；主体已改用分块布局
	return _build_top_left_block()


func _build_right_column() -> Control:
	var right := VBoxContainer.new()
	right.add_child(_build_preview_block())
	return right


func _wrap_panel(fill: Color, border: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(fill, border, 6, 1))
	return panel


func _panel_vbox(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	return box


func _sync_scroll_size() -> void:
	if _scroll == null or _content_margin == null:
		return
	var width := _scroll.size.x
	var height := _scroll.size.y
	if width > 8.0 and height > 8.0:
		# 宽度铺满；高度铺满滚动区，由内部 stretch 分配空间
		_content_margin.custom_minimum_size = Vector2(width, height)
		_content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _rebuild_needs(needs: Array) -> void:
	for child in _needs_row.get_children():
		child.queue_free()
	if needs.is_empty():
		_needs_row.add_child(_make_label("No requirements", 14, MUTED))
		return
	for need in needs:
		_needs_row.add_child(_build_need_card(need))


func _build_need_card(need: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.09, 0.11, 0.15, 0.98), PANEL_BORDER, 5, 1))
	var margin := MarginContainer.new()
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(48, 48)
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_wrap.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.12, 0.16), PANEL_BORDER, 4, 1))
	row.add_child(icon_wrap)
	var icon := TextureRect.new()
	icon.set_anchors_preset(PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path := String(need.get("icon_path", ""))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path) as Texture2D
	icon_wrap.add_child(icon)
	if icon.texture == null:
		var fallback := Label.new()
		fallback.text = "▣"
		fallback.set_anchors_preset(PRESET_FULL_RECT)
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback.add_theme_color_override("font_color", MUTED)
		icon_wrap.add_child(fallback)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)
	text_box.add_child(_make_label(String(need.get("name", "Supplies")), 13, TEXT))
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 9)
	bar.show_percentage = false
	var total := int(need.get("total", 1))
	var current := int(need.get("current", 0))
	bar.max_value = float(maxi(total, 1))
	bar.value = float(current)
	_style_progress_bar(bar, ACCENT_FOR_NEED(String(need.get("name", ""))))
	text_box.add_child(bar)
	text_box.add_child(_make_label("%d / %d" % [current, total], 11, MUTED))
	return card


func _rebuild_missions(missions: Array, revealed: bool) -> void:
	_mission_card_refs.clear()
	_selected_mission_id = ""
	var source: Array = []
	for m in missions:
		if typeof(m) == TYPE_DICTIONARY:
			source.append((m as Dictionary).duplicate(true))
	_missions_cache = source
	for child in _missions_box.get_children():
		child.queue_free()
	if not revealed or _missions_cache.is_empty():
		_missions_box.add_child(_make_label("Unlock after adjacent outpost missions", 16, MUTED))
		return
	for i in _missions_cache.size():
		var mission: Dictionary = _missions_cache[i]
		_missions_box.add_child(_build_mission_card(mission, i))
	if not _mission_card_refs.is_empty():
		_select_mission(String(_mission_card_refs[0].get("mission_id", "")), false)


func _mission_type_accent(task_type: String) -> Color:
	match MissionTypes.normalize_type(task_type):
		"Repair Run":
			return Color(0.45, 0.78, 0.92)
		"Emergency Run":
			return Color(0.98, 0.55, 0.32)
		"Relay Run":
			return Color(0.62, 0.72, 0.98)
		"Ignition Run":
			return Color(0.98, 0.48, 0.38)
		_:
			return Color(0.96, 0.58, 0.22)


func _mission_type_icon_char(task_type: String) -> String:
	match MissionTypes.normalize_type(task_type):
		"Repair Run":
			return "🔧"
		"Emergency Run":
			return "⚡"
		"Relay Run":
			return "↗"
		"Ignition Run":
			return "🔥"
		_:
			return "▣"


func _mission_card_meta(mission: Dictionary, profile: Dictionary) -> String:
	var cargo := String(mission.get("cargo_name_en", mission.get("cargo_name", "Cargo")))
	var location_id := String(mission.get("location_id", _location_id))
	var outpost := _outpost_display_name(
		location_id,
		String(mission.get("target_hearth", mission.get("source_hearth", location_id)))
	)
	var duration_s := int(mission.get("duration", profile.get("duration", 60)))
	var timed := bool(profile.get("timed_fail", false))
	if timed:
		return "%s · %s · %ds LIMIT" % [cargo, outpost, duration_s]
	return "%s · %s · %d-%ds" % [cargo, outpost, maxi(duration_s - 10, 30), duration_s]


func _mission_display_title(mission: Dictionary, profile: Dictionary) -> String:
	var type_en := String(mission.get("task_type", profile.get("task_type", "Supply Run"))).to_upper()
	if not type_en.ends_with(" RUN"):
		type_en = "%s RUN" % type_en.replace(" RUN", "")
	return type_en


func _build_mission_card(mission: Dictionary, index: int) -> Control:
	var mission_id := Global.mission_key(mission)
	var profile: Dictionary = MissionTypes.resolve(mission)
	var accent := _mission_type_accent(String(mission.get("task_type", "")))
	var type_en := _mission_display_title(mission, profile)
	var reward := int(mission.get("base_reward", profile.get("base_reward", 50)))
	var is_done := Global.is_mission_completed(_planet_id, mission_id)
	var reward_pending := Global.is_mission_reward_pending(_planet_id, mission_id)
	var progress_target := MissionTypes.mission_progress_target(mission)
	var progress_now := Global.get_mission_progress(_planet_id, mission_id)
	var index_text := String(mission.get("index", "%02d" % (index + 1)))

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 96)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.027, 0.063, 0.114, 0.92), Color(accent.r, accent.g, accent.b, 0.45), 8, 1))
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	var index_badge := Label.new()
	index_badge.text = index_text
	index_badge.custom_minimum_size = Vector2(40, 40)
	index_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	index_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	index_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	index_badge.add_theme_font_size_override("font_size", 16)
	index_badge.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	index_badge.add_theme_stylebox_override("normal", _panel_style(accent, accent, 6, 0))
	row.add_child(index_badge)

	var accent_bar := ColorRect.new()
	accent_bar.custom_minimum_size = Vector2(4, 52)
	accent_bar.color = accent
	accent_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(accent_bar)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(48, 48)
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_wrap.add_theme_stylebox_override("panel", _panel_style(Color(0.063, 0.137, 0.227, 0.7), Color(accent.r, accent.g, accent.b, 0.5), 8, 1))
	row.add_child(icon_wrap)
	var icon_lbl := Label.new()
	icon_lbl.text = _mission_type_icon_char(String(mission.get("task_type", "")))
	icon_lbl.set_anchors_preset(PRESET_FULL_RECT)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 20)
	icon_lbl.add_theme_color_override("font_color", accent)
	icon_wrap.add_child(icon_lbl)

	var text_box := VBoxContainer.new()
	text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)
	text_box.add_child(_make_label(type_en, 20, TEXT))
	text_box.add_child(_make_label(_mission_card_meta(mission, profile), 16, MUTED))
	if not is_done and progress_now > 0:
		text_box.add_child(_make_label("Progress %d / %d" % [progress_now, progress_target], 15, Color(0.62, 0.72, 0.82)))
	elif is_done and reward_pending:
		text_box.add_child(_make_label("Reward pending", 15, ClaimButtonUI.HIGHLIGHT))
	elif is_done:
		text_box.add_child(_make_label("Completed", 15, UI_MISSION_DONE))

	var reward_box := VBoxContainer.new()
	reward_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_box.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(reward_box)
	reward_box.add_child(_make_label("★ %d" % reward, 20, UI_ICE))
	if is_done and not reward_pending:
		reward_box.add_child(_make_label("DONE", 15, UI_MISSION_DONE))

	_mission_card_refs.append({
		"mission_id": mission_id,
		"mission": mission.duplicate(true),
		"card": card,
		"border": accent,
	})
	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_select_mission(mission_id, true)
		elif event is InputEventScreenTouch and event.pressed:
			_select_mission(mission_id, true)
	)
	return card


func _select_mission(mission_id: String, open_detail: bool = false) -> void:
	if mission_id == "":
		return
	_selected_mission_id = mission_id
	for entry in _mission_card_refs:
		var card: PanelContainer = entry.get("card")
		if card == null or not is_instance_valid(card):
			continue
		var border: Color = entry.get("border", PANEL_BORDER)
		var selected := String(entry.get("mission_id", "")) == mission_id
		var fill := Color(0.10, 0.16, 0.24, 0.98) if selected else Color(0.027, 0.063, 0.114, 0.92)
		var edge := GOLD if selected else Color(border.r, border.g, border.b, 0.45)
		var width := 3 if selected else 1
		card.add_theme_stylebox_override("panel", _panel_style(fill, edge, 8, width))
	if open_detail:
		var mission := _find_mission(mission_id)
		if not mission.is_empty():
			_open_task_detail(mission)


func _apply_manager_portrait(manager: Dictionary, accent: Color, show_identity: bool = true) -> void:
	var style := _panel_style(accent.darkened(0.55), accent, 6, 1)
	_manager_portrait.add_theme_stylebox_override("panel", style)
	if not show_identity:
		_manager_portrait_fallback.text = "?"
		_manager_portrait_fallback.add_theme_color_override("font_color", accent.lightened(0.35))
		_manager_portrait_icon.visible = false
		_manager_portrait_fallback.visible = true
		return
	var name := String(manager.get("name", "?"))
	_manager_portrait_fallback.text = name.substr(0, 1) if name != "" else "?"
	_manager_portrait_fallback.add_theme_color_override("font_color", accent.lightened(0.35))
	var portrait_path := String(manager.get("portrait_path", ""))
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		_manager_portrait_icon.texture = load(portrait_path) as Texture2D
		_manager_portrait_icon.visible = true
		_manager_portrait_fallback.visible = false
	else:
		_manager_portrait_icon.visible = false
		_manager_portrait_fallback.visible = true


func _set_stars(count: int) -> void:
	for child in _stars_box.get_children():
		child.queue_free()
	for i in 5:
		var star := Label.new()
		star.text = "★" if i < count else "☆"
		star.add_theme_font_size_override("font_size", 17)
		star.add_theme_color_override("font_color", STATUS if i < count else MUTED)
		_stars_box.add_child(star)


func _section_label(text: String) -> Label:
	return _make_label(text, 15, MUTED)


func _make_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _panel_style(fill: Color, border: Color, radius: int, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func _style_progress_bar(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.10, 0.12, 0.16)
	bg.set_corner_radius_all(4)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _style_flat_button(button: Button, fill: Color, border: Color, font_color: Color, font_size: int) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(fill, border, 6, 1))
	button.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.05), border, 6, 1))
	button.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.06), border, 6, 1))
	button.add_theme_stylebox_override("disabled", _panel_style(fill.darkened(0.18), border.darkened(0.08), 6, 1))
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_disabled_color", MUTED)


func _build_runner_style_row(title_text: String, option_name: String, is_road: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var title := Label.new()
	title.text = title_text
	title.custom_minimum_size = Vector2(88, 0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", MUTED)
	row.add_child(title)

	var option := OptionButton.new()
	option.name = option_name
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.custom_minimum_size = Vector2(0, 52)
	option.focus_mode = Control.FOCUS_NONE
	if is_road:
		Global.populate_runner_road_style_option(option)
		option.item_selected.connect(_on_road_style_option_selected)
	else:
		Global.populate_runner_background_style_option(option)
		option.item_selected.connect(_on_background_style_option_selected)
	_style_option_button(option)
	row.add_child(option)
	return row


func _style_option_button(option: OptionButton) -> void:
	var fill := Color(0.10, 0.12, 0.16)
	var border := PANEL_BORDER
	option.add_theme_stylebox_override("normal", _panel_style(fill, border, 6, 1))
	option.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.05), border, 6, 1))
	option.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.06), border, 6, 1))
	option.add_theme_stylebox_override("focus", _panel_style(fill, border, 6, 1))
	option.add_theme_font_size_override("font_size", 16)
	option.add_theme_color_override("font_color", Color(0.45, 0.9, 1.0))


func _sync_runner_style_options() -> void:
	var road_option := find_child("RoadStyleOption", true, false) as OptionButton
	if road_option:
		Global.populate_runner_road_style_option(road_option)
	var bg_option := find_child("BackgroundStyleOption", true, false) as OptionButton
	if bg_option:
		Global.populate_runner_background_style_option(bg_option)


func _on_road_style_option_selected(index: int) -> void:
	if index < 0 or index >= Global.RUNNER_ROAD_STYLE_ORDER.size():
		return
	Global.set_runner_road_style(Global.RUNNER_ROAD_STYLE_ORDER[index])


func _on_background_style_option_selected(index: int) -> void:
	if index < 0 or index >= Global.RUNNER_BACKGROUND_STYLE_ORDER.size():
		return
	Global.set_runner_background_style(Global.RUNNER_BACKGROUND_STYLE_ORDER[index])


func _show_preview_toast() -> void:
	var toast := Label.new()
	toast.text = "预览模式 · 可点「试玩体验」直接进关调优"
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.set_anchors_preset(PRESET_CENTER_TOP)
	toast.offset_top = 88.0
	toast.offset_left = 24.0
	toast.offset_right = -24.0
	toast.add_theme_font_size_override("font_size", 17)
	toast.add_theme_color_override("font_color", STATUS)
	toast.add_theme_stylebox_override("normal", _panel_style(Color(0.12, 0.08, 0.04, 0.94), GOLD, 1))
	add_child(toast)
	var tween := create_tween()
	tween.tween_property(toast, "modulate:a", 0.0, 0.35).set_delay(2.2)
	tween.tween_callback(toast.queue_free)


func _close() -> void:
	if _task_detail != null and is_instance_valid(_task_detail) and _task_detail.has_method("close"):
		_task_detail.close()
	closed.emit()
	queue_free()


static func ACCENT_FOR_NEED(name: String) -> Color:
	var lower := name.to_lower()
	if lower.contains("energy") or name.contains("能源"):
		return Color(0.98, 0.82, 0.28)
	if lower.contains("medical") or name.contains("医疗"):
		return Color(0.42, 0.86, 0.58)
	return Color(0.96, 0.58, 0.22)
