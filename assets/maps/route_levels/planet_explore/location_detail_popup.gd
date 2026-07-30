class_name LocationDetailPopup
extends Control

signal closed
signal story_pressed
signal runner_pressed

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
var _runner_button: Button
var _pending_payload: Dictionary = {}
var _ui_built := false


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
	_icon_label.text = String(payload.get("type_icon", "◎"))
	_title_label.text = String(payload.get("title", "据点详情"))
	_title_en_label.text = String(payload.get("title_en", ""))
	_status_label.text = String(payload.get("status", ""))
	var revealed := bool(payload.get("revealed", false))
	if revealed:
		_desc_label.text = "%s\n%s" % [
			String(payload.get("tagline", "")),
			String(payload.get("goal", "")),
		]
	else:
		_desc_label.text = "还没轮到这个据点的任务哦。%s" % String(payload.get("locked_hint", ""))
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
	_rebuild_missions(payload.get("transport_missions", []), revealed)
	var manager: Dictionary = payload.get("manager", {})
	_manager_name.text = String(manager.get("name", ""))
	_manager_title.text = String(manager.get("title", ""))
	_manager_quote.text = "“%s”" % String(manager.get("quote", ""))
	_apply_manager_portrait(manager, payload.get("manager_accent", Color(0.28, 0.48, 0.72)))
	var rewards: Dictionary = payload.get("rewards", {})
	_reward_coins_label.text = "星火币 %d" % int(rewards.get("coins", 0))
	var unlock_character := String(rewards.get("unlock_character", ""))
	if unlock_character != "":
		_reward_extra_label.text = "解锁新角色：%s" % unlock_character
		_reward_extra_label.visible = true
	else:
		_reward_extra_label.visible = false
	_story_button.visible = false
	_runner_button.disabled = not revealed
	_runner_button.text = String(payload.get("runner_label", "开始运输"))
	_sync_runner_style_options()


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
	_content_margin.add_theme_constant_override("margin_left", 10)
	_content_margin.add_theme_constant_override("margin_top", 8)
	_content_margin.add_theme_constant_override("margin_right", 10)
	_content_margin.add_theme_constant_override("margin_bottom", 8)
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
	frame_margin.add_theme_constant_override("margin_top", 10)
	frame_margin.add_theme_constant_override("margin_right", 12)
	frame_margin.add_theme_constant_override("margin_bottom", 10)
	frame.add_child(frame_margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	frame_margin.add_child(root)

	# —— 顶栏 ——
	root.add_child(_build_header())

	# —— 双栏主体 ——
	var body := HBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	root.add_child(body)

	body.add_child(_build_left_column())
	body.add_child(_build_right_column())

	_story_button = Button.new()
	_story_button.text = "查看剧情"
	_story_button.visible = false
	_story_button.custom_minimum_size = Vector2(0, 36)
	_story_button.focus_mode = Control.FOCUS_NONE
	_style_flat_button(_story_button, Color(0.10, 0.12, 0.16), PANEL_BORDER, MUTED, 14)
	_story_button.pressed.connect(func(): story_pressed.emit())
	root.add_child(_story_button)

	# —— 底部：跑道外观 + 开始运输 ——
	var footer_margin := MarginContainer.new()
	footer_margin.add_theme_constant_override("margin_left", 10)
	footer_margin.add_theme_constant_override("margin_right", 10)
	footer_margin.add_theme_constant_override("margin_bottom", 10)
	footer_margin.add_theme_constant_override("margin_top", 4)
	shell.add_child(footer_margin)

	var footer_box := VBoxContainer.new()
	footer_box.add_theme_constant_override("separation", 8)
	footer_margin.add_child(footer_box)

	footer_box.add_child(_build_runner_style_row("跑道外观", "RoadStyleOption", true))
	footer_box.add_child(_build_runner_style_row("场景背景", "BackgroundStyleOption", false))

	_runner_button = Button.new()
	_runner_button.text = "开始运输"
	_runner_button.custom_minimum_size = Vector2(0, 62)
	_runner_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_runner_button.focus_mode = Control.FOCUS_NONE
	_style_gold_button(_runner_button)
	_runner_button.pressed.connect(func(): runner_pressed.emit())
	footer_box.add_child(_runner_button)


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(48, 48)
	icon_wrap.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.14, 0.20, 0.98), PANEL_BORDER, 6, 1))
	header.add_child(icon_wrap)
	_icon_label = Label.new()
	_icon_label.text = "💧"
	_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_icon_label.set_anchors_preset(PRESET_FULL_RECT)
	_icon_label.add_theme_font_size_override("font_size", 24)
	icon_wrap.add_child(_icon_label)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 1)
	header.add_child(title_box)
	_title_label = _make_label("", 22, TEXT)
	title_box.add_child(_title_label)
	_title_en_label = _make_label("", 12, MUTED)
	title_box.add_child(_title_en_label)

	var danger_box := VBoxContainer.new()
	danger_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(danger_box)
	danger_box.add_child(_make_label("危险等级", 11, MUTED))
	_stars_box = HBoxContainer.new()
	_stars_box.add_theme_constant_override("separation", 2)
	_stars_box.alignment = BoxContainer.ALIGNMENT_END
	danger_box.add_child(_stars_box)

	var close_button := Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(40, 40)
	close_button.focus_mode = Control.FOCUS_NONE
	_style_flat_button(close_button, Color(0.10, 0.12, 0.16), PANEL_BORDER, TEXT, 18)
	close_button.pressed.connect(_close)
	header.add_child(close_button)
	return header


func _build_left_column() -> Control:
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(260, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.36
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)

	# 状态 + 描述
	var info_panel := _wrap_panel(PANEL, PANEL_BORDER)
	left.add_child(info_panel)
	var info_box := _panel_vbox(info_panel)
	_status_label = _make_label("状态：修复中", 15, STATUS)
	info_box.add_child(_status_label)
	_desc_label = _make_label("", 13, Color(0.78, 0.82, 0.88))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.add_child(_desc_label)

	# 负责人（头像吃掉剩余高度）
	var manager_panel := _wrap_panel(PANEL, PANEL_BORDER)
	manager_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	manager_panel.size_flags_stretch_ratio = 1.4
	left.add_child(manager_panel)
	var manager_box := _panel_vbox(manager_panel)
	manager_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	manager_box.add_child(_section_label("负责人"))
	_manager_portrait = PanelContainer.new()
	_manager_portrait.custom_minimum_size = Vector2(0, 180)
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
	_manager_portrait_fallback.add_theme_font_size_override("font_size", 42)
	_manager_portrait.add_child(_manager_portrait_fallback)
	_manager_name = _make_label("", 16, TEXT)
	manager_box.add_child(_manager_name)
	_manager_title = _make_label("", 12, MUTED)
	manager_box.add_child(_manager_title)
	_manager_quote = _make_label("", 12, Color(0.68, 0.74, 0.82))
	_manager_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_manager_quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	manager_box.add_child(_manager_quote)

	# 据点奖励（贴底）
	var reward_panel := _wrap_panel(PANEL, PANEL_BORDER)
	left.add_child(reward_panel)
	var reward_box := _panel_vbox(reward_panel)
	reward_box.add_child(_section_label("据点奖励（修复后）"))
	var reward_row := HBoxContainer.new()
	reward_row.add_theme_constant_override("separation", 8)
	reward_box.add_child(reward_row)
	reward_row.add_child(_make_label("✦", 22, REWARD))
	var reward_text := VBoxContainer.new()
	reward_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reward_text.add_theme_constant_override("separation", 2)
	reward_row.add_child(reward_text)
	_reward_coins_label = _make_label("星火币 0", 16, REWARD)
	reward_text.add_child(_reward_coins_label)
	_reward_extra_label = _make_label("", 12, MUTED)
	_reward_extra_label.visible = false
	reward_text.add_child(_reward_extra_label)
	return left


func _build_right_column() -> Control:
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 0.64
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)

	# 主视觉（占右侧大部分高度）
	var preview_panel := _wrap_panel(PANEL, PANEL_BORDER)
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_stretch_ratio = 1.35
	right.add_child(preview_panel)
	_preview = TextureRect.new()
	_preview.custom_minimum_size = Vector2(0, 220)
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	preview_panel.add_child(_preview)

	# 修复进度
	var repair_panel := _wrap_panel(PANEL, PANEL_BORDER)
	right.add_child(repair_panel)
	var repair_box := _panel_vbox(repair_panel)
	repair_box.add_child(_section_label("修复进度"))
	var repair_top := HBoxContainer.new()
	repair_top.add_theme_constant_override("separation", 10)
	repair_box.add_child(repair_top)
	_repair_percent_label = _make_label("0%", 28, CYAN)
	repair_top.add_child(_repair_percent_label)
	var repair_bar_box := VBoxContainer.new()
	repair_bar_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	repair_bar_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	repair_bar_box.add_theme_constant_override("separation", 4)
	repair_top.add_child(repair_bar_box)
	_repair_bar = ProgressBar.new()
	_repair_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_repair_bar.custom_minimum_size = Vector2(0, 14)
	_repair_bar.show_percentage = false
	_style_progress_bar(_repair_bar, CYAN)
	repair_bar_box.add_child(_repair_bar)
	_repair_value_label = _make_label("0 / 0", 12, MUTED)
	_repair_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	repair_bar_box.add_child(_repair_value_label)

	# 需求 | 任务（共同吃掉下半剩余高度）
	var lower := HBoxContainer.new()
	lower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lower.size_flags_stretch_ratio = 1.0
	lower.add_theme_constant_override("separation", 8)
	right.add_child(lower)

	var needs_panel := _wrap_panel(PANEL, PANEL_BORDER)
	needs_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	needs_panel.size_flags_stretch_ratio = 0.42
	needs_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lower.add_child(needs_panel)
	var needs_box := _panel_vbox(needs_panel)
	needs_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	needs_box.add_child(_section_label("当前需求"))
	_needs_row = VBoxContainer.new()
	_needs_row.add_theme_constant_override("separation", 8)
	_needs_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_needs_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	needs_box.add_child(_needs_row)

	var missions_panel := _wrap_panel(PANEL, PANEL_BORDER)
	missions_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	missions_panel.size_flags_stretch_ratio = 0.58
	missions_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lower.add_child(missions_panel)
	var missions_box := _panel_vbox(missions_panel)
	missions_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	missions_box.add_child(_section_label("可执行运输任务"))
	_missions_box = VBoxContainer.new()
	_missions_box.add_theme_constant_override("separation", 8)
	_missions_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_missions_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	missions_box.add_child(_missions_box)
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
		_needs_row.add_child(_make_label("暂无需求", 14, MUTED))
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
	text_box.add_child(_make_label(String(need.get("name", "物资")), 13, TEXT))
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
	for child in _missions_box.get_children():
		child.queue_free()
	if not revealed or missions.is_empty():
		_missions_box.add_child(_make_label("完成相邻据点任务后解锁", 13, MUTED))
		return
	var border_colors: Array[Color] = [Color(0.96, 0.58, 0.22), Color(0.82, 0.42, 0.28)]
	for i in missions.size():
		var mission: Dictionary = missions[i]
		var border: Color = border_colors[i % border_colors.size()]
		_missions_box.add_child(_build_mission_card(mission, border))


func _build_mission_card(mission: Dictionary, border_color: Color) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.10, 0.13, 0.98), border_color, 5, 2))
	var margin := MarginContainer.new()
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var index_badge := Label.new()
	index_badge.text = String(mission.get("index", "01"))
	index_badge.custom_minimum_size = Vector2(34, 34)
	index_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	index_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	index_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	index_badge.add_theme_font_size_override("font_size", 14)
	index_badge.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	index_badge.add_theme_stylebox_override("normal", _panel_style(border_color, border_color, 4, 0))
	row.add_child(index_badge)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 2)
	row.add_child(text_box)
	text_box.add_child(_make_label(
		"%s · %ds" % [
			String(mission.get("type", "补给")),
			int(mission.get("duration", 60)),
		],
		14,
		TEXT
	))
	var hint := String(mission.get("hint", ""))
	if hint != "":
		text_box.add_child(_make_label(hint, 11, MUTED))
	text_box.add_child(_make_label(String(mission.get("cargo_text", "")), 12, MUTED))

	var reward_box := VBoxContainer.new()
	reward_box.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(reward_box)
	reward_box.add_child(_make_label("◉ %d" % int(mission.get("coins", 0)), 12, STATUS))
	reward_box.add_child(_make_label("EXP %d" % int(mission.get("xp", 0)), 12, CYAN))
	return card


func _apply_manager_portrait(manager: Dictionary, accent: Color) -> void:
	var name := String(manager.get("name", "?"))
	_manager_portrait_fallback.text = name.substr(0, 1)
	_manager_portrait_fallback.add_theme_color_override("font_color", accent.lightened(0.35))
	var style := _panel_style(accent.darkened(0.55), accent, 6, 1)
	_manager_portrait.add_theme_stylebox_override("panel", style)
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
		star.add_theme_font_size_override("font_size", 15)
		star.add_theme_color_override("font_color", STATUS if i < count else MUTED)
		_stars_box.add_child(star)


func _section_label(text: String) -> Label:
	return _make_label(text, 13, MUTED)


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


func _style_gold_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(GOLD, GOLD_BORDER, 8, 2))
	button.add_theme_stylebox_override("hover", _panel_style(GOLD.lightened(0.05), GOLD_BORDER.lightened(0.04), 8, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(GOLD.darkened(0.08), GOLD_BORDER.darkened(0.04), 8, 2))
	button.add_theme_stylebox_override("disabled", _panel_style(GOLD.darkened(0.22), GOLD_BORDER.darkened(0.12), 8, 1))
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	button.add_theme_color_override("font_disabled_color", Color(0.28, 0.22, 0.16))


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


func _close() -> void:
	closed.emit()
	queue_free()


static func ACCENT_FOR_NEED(name: String) -> Color:
	if name.contains("能源"):
		return Color(0.98, 0.82, 0.28)
	if name.contains("医疗"):
		return Color(0.42, 0.86, 0.58)
	return Color(0.96, 0.58, 0.22)
