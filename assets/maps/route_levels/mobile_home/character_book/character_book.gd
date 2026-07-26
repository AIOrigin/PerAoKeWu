extends Control
class_name CharacterBook

## 角色档案宝典：开合书本 + 3D 翻页（参考 Story Teller / Godot page flip）

signal closed

const PAGE_TEX_SIZE := Vector2i(480, 720)
const FLIP_SEC := 0.72
const PAGE_W := 1.0
const PAGE_H := 1.5

var _character_id: String = CharacterRoster.CHAR_ELSA
var _character: Dictionary = {}
var _pages: Array[Dictionary] = []
var _spread: int = 0
var _flipping: bool = false
var _touch_start := Vector2.ZERO
var _touch_tracking := false

var _title_label: Label
var _page_label: Label
var _btn_prev: Button
var _btn_next: Button

var _book_viewport: SubViewport
var _book_host: SubViewportContainer
var _static_root: Node3D
var _turning_root: Node3D
var _mesh_left: MeshInstance3D
var _mesh_right: MeshInstance3D
var _mesh_turn_front: MeshInstance3D
var _mesh_turn_back: MeshInstance3D
var _turn_pivot: Node3D

var _vp_left: SubViewport
var _vp_right: SubViewport
var _vp_front: SubViewport
var _vp_back: SubViewport


func setup(character_id: String) -> void:
	_character_id = character_id
	_character = CharacterRoster.get_character(character_id)
	_pages = _build_pages(_character)
	_spread = 0
	_build_ui()
	_refresh_static_pages()
	_update_nav()


func _build_pages(character: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	out.append({
		"kind": "cover_left",
		"title": "星火信使",
		"subtitle": "MESSENGER ARCHIVE",
	})
	out.append({
		"kind": "cover_right",
		"name": String(character.get("name_en", "")),
		"title": String(character.get("title", "")),
		"badge": String(character.get("badge", "?")),
	})
	out.append({
		"kind": "why",
		"section": String(character.get("section_why", "")),
		"quote_zh": String(character.get("quote_zh", "")),
		"quote": String(character.get("quote", "")),
	})
	out.append({
		"kind": "art",
		"art_path": String(character.get("story_art_path", "")),
		"hero_path": String(character.get("hero_path", "")),
		"portrait_path": String(character.get("portrait_path", "")),
		"quote": String(character.get("quote", "")),
		"quote_in_art": bool(character.get("quote_in_art", false)),
	})
	var paragraphs: Array = character.get("story_paragraphs", [])
	var idx := 0
	for paragraph in paragraphs:
		idx += 1
		out.append({
			"kind": "text",
			"heading": "BACKGROUND · 背景故事" if idx == 1 else "",
			"body": String(paragraph),
			"index": idx,
		})
	out.append({
		"kind": "end",
		"name": String(character.get("name", "")),
		"title": String(character.get("title", "")),
	})
	if out.size() % 2 == 1:
		out.append({"kind": "blank"})
	return out


func _spread_count() -> int:
	return maxi(1, int(ceil(float(_pages.size()) / 2.0)))


func _page_at(index: int) -> Dictionary:
	if index < 0 or index >= _pages.size():
		return {"kind": "blank"}
	return _pages[index]


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.color = Color(0.045, 0.055, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# 氛围光晕
	var glow := ColorRect.new()
	glow.color = Color(0.55, 0.38, 0.18, 0.12)
	glow.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	glow.offset_left = -420
	glow.offset_right = 420
	glow.offset_top = -280
	glow.offset_bottom = 320
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	column.add_child(_make_top_bar())

	var book_stage := Control.new()
	book_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	book_stage.clip_contents = false
	column.add_child(book_stage)

	_book_viewport = SubViewport.new()
	_book_viewport.transparent_bg = true
	_book_viewport.handle_input_locally = false
	_book_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_book_viewport.size = Vector2i(1000, 760)
	_book_host = SubViewportContainer.new()
	_book_host.stretch = true
	_book_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_book_host.mouse_filter = Control.MOUSE_FILTER_STOP
	_book_host.gui_input.connect(_on_book_gui_input)
	book_stage.add_child(_book_host)
	_book_host.add_child(_book_viewport)

	_setup_content_viewports()
	_setup_book_3d()

	column.add_child(_make_nav_bar())


func _make_top_bar() -> Control:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)

	var back := Button.new()
	back.text = "‹"
	back.focus_mode = Control.FOCUS_NONE
	back.flat = true
	back.custom_minimum_size = Vector2(48, 48)
	back.add_theme_font_size_override("font_size", 34)
	back.add_theme_color_override("font_color", Color(0.94, 0.92, 0.88))
	back.pressed.connect(func() -> void: closed.emit())
	top.add_child(back)

	_title_label = Label.new()
	_title_label.text = "信使宝典  ARCHIVE"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", Color(0.94, 0.93, 0.90))
	top.add_child(_title_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(48, 0)
	top.add_child(spacer)
	return top


func _make_nav_bar() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	_btn_prev = _make_nav_button("‹ 上一页")
	_btn_prev.pressed.connect(_turn_backward)
	row.add_child(_btn_prev)

	_page_label = Label.new()
	_page_label.custom_minimum_size = Vector2(180, 0)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_page_label.add_theme_font_size_override("font_size", 16)
	_page_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62))
	row.add_child(_page_label)

	_btn_next = _make_nav_button("下一页 ›")
	_btn_next.pressed.connect(_turn_forward)
	row.add_child(_btn_next)
	return row


func _make_nav_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(160, 52)
	btn.add_theme_font_size_override("font_size", 18)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.12, 0.09, 0.92)
	normal.border_color = Color(0.83, 0.65, 0.45, 0.55)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(8)
	normal.set_content_margin_all(10)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.22, 0.18, 0.12, 0.95)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.10, 0.10, 0.10, 0.55)
	disabled.border_color = Color(0.35, 0.35, 0.35, 0.35)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", pressed)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.45, 0.45))
	return btn


func _setup_content_viewports() -> void:
	_vp_left = _make_content_viewport()
	_vp_right = _make_content_viewport()
	_vp_front = _make_content_viewport()
	_vp_back = _make_content_viewport()
	add_child(_vp_left)
	add_child(_vp_right)
	add_child(_vp_front)
	add_child(_vp_back)


func _make_content_viewport() -> SubViewport:
	var vp := SubViewport.new()
	vp.size = PAGE_TEX_SIZE
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.handle_input_locally = false
	return vp


func _setup_book_3d() -> void:
	var world := Node3D.new()
	world.name = "BookWorld"
	_book_viewport.add_child(world)

	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.fov = 28.0
	cam.position = Vector3(0.0, 0.05, 4.35)
	cam.look_at(Vector3(0.0, 0.0, 0.0))
	world.add_child(cam)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42, -28, 0)
	light.light_energy = 1.15
	light.shadow_enabled = false
	world.add_child(light)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0.0, 1.2, 2.0)
	fill.light_energy = 0.55
	fill.omni_range = 8.0
	world.add_child(fill)

	# 书壳
	var cover := Node3D.new()
	world.add_child(cover)
	cover.add_child(_make_box_mesh(
		Vector3(-PAGE_W * 0.52, 0.0, -0.045),
		Vector3(PAGE_W * 1.08, PAGE_H * 1.06, 0.06),
		Color(0.28, 0.14, 0.08)
	))
	cover.add_child(_make_box_mesh(
		Vector3(PAGE_W * 0.52, 0.0, -0.045),
		Vector3(PAGE_W * 1.08, PAGE_H * 1.06, 0.06),
		Color(0.26, 0.13, 0.07)
	))
	# 书脊
	cover.add_child(_make_box_mesh(
		Vector3(0.0, 0.0, -0.02),
		Vector3(0.08, PAGE_H * 1.04, 0.09),
		Color(0.18, 0.09, 0.05)
	))

	_static_root = Node3D.new()
	_static_root.name = "Static"
	world.add_child(_static_root)
	_mesh_left = _make_page_mesh(Vector3(-PAGE_W * 0.52, 0.0, 0.0))
	_mesh_right = _make_page_mesh(Vector3(PAGE_W * 0.52, 0.0, 0.0))
	_static_root.add_child(_mesh_left)
	_static_root.add_child(_mesh_right)

	_turning_root = Node3D.new()
	_turning_root.name = "Turning"
	_turning_root.visible = false
	world.add_child(_turning_root)

	# 左静态页在翻页时仍显示；右侧由翻页片代替
	var turn_left := _make_page_mesh(Vector3(-PAGE_W * 0.52, 0.0, 0.0))
	turn_left.name = "TurnLeftStatic"
	_turning_root.add_child(turn_left)
	# 翻页后露出的右页
	var turn_right := _make_page_mesh(Vector3(PAGE_W * 0.52, 0.0, 0.0))
	turn_right.name = "TurnRightStatic"
	_turning_root.add_child(turn_right)

	_turn_pivot = Node3D.new()
	_turn_pivot.name = "TurnPivot"
	_turning_root.add_child(_turn_pivot)

	_mesh_turn_front = _make_page_mesh(Vector3(PAGE_W * 0.52, 0.0, 0.002))
	_mesh_turn_front.name = "TurnFront"
	_turn_pivot.add_child(_mesh_turn_front)

	_mesh_turn_back = _make_page_mesh(Vector3(PAGE_W * 0.52, 0.0, -0.002))
	_mesh_turn_back.rotation_degrees.y = 180.0
	_mesh_turn_back.name = "TurnBack"
	_turn_pivot.add_child(_mesh_turn_back)

	# 缓存引用：翻页时左右静态页材质
	_turning_root.set_meta("left_mesh", turn_left)
	_turning_root.set_meta("right_mesh", turn_right)


func _make_box_mesh(pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.position = pos
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mi.material_override = mat
	return mi


func _make_page_mesh(pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(PAGE_W, PAGE_H)
	plane.orientation = PlaneMesh.FACE_Z
	mi.mesh = plane
	mi.position = pos
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.96, 0.93, 0.86)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mi.material_override = mat
	return mi


func _apply_page_texture(mesh: MeshInstance3D, vp: SubViewport) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = vp.get_texture()
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat


func _paint_page(vp: SubViewport, page: Dictionary) -> void:
	while vp.get_child_count() > 0:
		var old: Node = vp.get_child(0)
		vp.remove_child(old)
		old.free()
	var root := Control.new()
	root.size = Vector2(PAGE_TEX_SIZE)
	root.custom_minimum_size = Vector2(PAGE_TEX_SIZE)
	vp.add_child(root)

	var paper := ColorRect.new()
	paper.color = Color(0.965, 0.94, 0.88)
	paper.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(paper)

	# 纸张纹理感
	var grain := ColorRect.new()
	grain.color = Color(0.78, 0.70, 0.55, 0.06)
	grain.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(grain)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	root.add_child(margin)

	var kind := String(page.get("kind", "blank"))
	match kind:
		"cover_left":
			_fill_cover_left(margin, page)
		"cover_right":
			_fill_cover_right(margin, page)
		"why":
			_fill_why(margin, page)
		"art":
			_fill_art(root, margin, page)
		"text":
			_fill_text(margin, page)
		"end":
			_fill_end(margin, page)
		_:
			_fill_blank(margin)

	# 页脚页码装饰线
	var footer := ColorRect.new()
	footer.color = Color(0.55, 0.42, 0.28, 0.35)
	footer.position = Vector2(48, PAGE_TEX_SIZE.y - 28)
	footer.size = Vector2(PAGE_TEX_SIZE.x - 96, 1)
	root.add_child(footer)

	vp.render_target_update_mode = SubViewport.UPDATE_ONCE


func _fill_cover_left(margin: MarginContainer, page: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	var ornament := Label.new()
	ornament.text = "◆"
	ornament.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ornament.add_theme_font_size_override("font_size", 28)
	ornament.add_theme_color_override("font_color", Color(0.55, 0.38, 0.22))
	box.add_child(ornament)
	var t := Label.new()
	t.text = String(page.get("title", ""))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 36)
	t.add_theme_color_override("font_color", Color(0.28, 0.18, 0.10))
	box.add_child(t)
	var s := Label.new()
	s.text = String(page.get("subtitle", ""))
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_theme_font_size_override("font_size", 14)
	s.add_theme_color_override("font_color", Color(0.55, 0.42, 0.28))
	box.add_child(s)


func _fill_cover_right(margin: MarginContainer, page: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var badge := Label.new()
	badge.text = String(page.get("badge", "?"))
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 64)
	badge.add_theme_color_override("font_color", Color(0.55, 0.38, 0.22))
	box.add_child(badge)

	var name_l := Label.new()
	name_l.text = String(page.get("name", ""))
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 48)
	name_l.add_theme_color_override("font_color", Color(0.18, 0.12, 0.08))
	box.add_child(name_l)

	var title := Label.new()
	title.text = String(page.get("title", ""))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.45, 0.32, 0.20))
	box.add_child(title)

	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(120, 2)
	line.color = Color(0.83, 0.65, 0.45, 0.85)
	var line_wrap := CenterContainer.new()
	line_wrap.add_child(line)
	box.add_child(line_wrap)

	var hint := Label.new()
	hint.text = "轻触右侧翻页"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35))
	box.add_child(hint)


func _fill_why(margin: MarginContainer, page: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	margin.add_child(box)

	var section := Label.new()
	section.text = String(page.get("section", ""))
	section.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	section.add_theme_font_size_override("font_size", 18)
	section.add_theme_color_override("font_color", Color(0.55, 0.38, 0.22))
	box.add_child(section)

	var qz := Label.new()
	qz.text = "「%s」" % String(page.get("quote_zh", ""))
	qz.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	qz.add_theme_font_size_override("font_size", 22)
	qz.add_theme_color_override("font_color", Color(0.16, 0.12, 0.08))
	box.add_child(qz)

	var qe := Label.new()
	qe.text = String(page.get("quote", ""))
	qe.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	qe.add_theme_font_size_override("font_size", 14)
	qe.add_theme_color_override("font_color", Color(0.42, 0.36, 0.30))
	box.add_child(qe)


func _fill_art(root: Control, margin: MarginContainer, page: Dictionary) -> void:
	# 插画铺满纸面，margin 仅作占位
	for c in margin.get_children():
		c.queue_free()
	margin.visible = false

	var image := TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.offset_left = 18
	image.offset_right = -18
	image.offset_top = 18
	image.offset_bottom = -18
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art := CharacterRoster.load_texture(String(page.get("art_path", "")))
	if art == null:
		art = CharacterRoster.load_texture(String(page.get("hero_path", "")))
	if art == null:
		art = CharacterRoster.load_texture(String(page.get("portrait_path", "")))
	if art:
		image.texture = art
	root.add_child(image)

	if not bool(page.get("quote_in_art", false)):
		var quote := Label.new()
		quote.text = String(page.get("quote", ""))
		quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		quote.position = Vector2(32, 28)
		quote.size = Vector2(PAGE_TEX_SIZE.x - 64, 0)
		quote.add_theme_font_size_override("font_size", 13)
		quote.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))
		root.add_child(quote)


func _fill_text(margin: MarginContainer, page: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var heading := String(page.get("heading", ""))
	if heading != "":
		var h := Label.new()
		h.text = heading
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_theme_font_size_override("font_size", 16)
		h.add_theme_color_override("font_color", Color(0.55, 0.38, 0.22))
		box.add_child(h)

	var body := Label.new()
	body.text = String(page.get("body", ""))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", 18)
	body.add_theme_color_override("font_color", Color(0.18, 0.14, 0.10))
	box.add_child(body)


func _fill_end(margin: MarginContainer, page: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)
	var done := Label.new()
	done.text = "— 完 —"
	done.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	done.add_theme_font_size_override("font_size", 22)
	done.add_theme_color_override("font_color", Color(0.45, 0.32, 0.20))
	box.add_child(done)
	var name_l := Label.new()
	name_l.text = "%s · %s" % [String(page.get("name", "")), String(page.get("title", ""))]
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.add_theme_font_size_override("font_size", 18)
	name_l.add_theme_color_override("font_color", Color(0.28, 0.18, 0.10))
	box.add_child(name_l)
	var tip := Label.new()
	tip.text = "希望准时送达。"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", Color(0.50, 0.40, 0.30))
	box.add_child(tip)


func _fill_blank(margin: MarginContainer) -> void:
	var box := CenterContainer.new()
	margin.add_child(box)
	var mark := Label.new()
	mark.text = "·"
	mark.add_theme_font_size_override("font_size", 28)
	mark.add_theme_color_override("font_color", Color(0.70, 0.62, 0.50))
	box.add_child(mark)


func _refresh_static_pages() -> void:
	var left_i := _spread * 2
	var right_i := left_i + 1
	_paint_page(_vp_left, _page_at(left_i))
	_paint_page(_vp_right, _page_at(right_i))
	_apply_page_texture(_mesh_left, _vp_left)
	_apply_page_texture(_mesh_right, _vp_right)
	# 等一帧让 Viewport 出图后再贴一次，避免首帧空白
	if not RenderingServer.frame_post_draw.is_connected(_reapply_static_textures):
		RenderingServer.frame_post_draw.connect(_reapply_static_textures, CONNECT_ONE_SHOT)


func _reapply_static_textures() -> void:
	if not is_instance_valid(self):
		return
	_apply_page_texture(_mesh_left, _vp_left)
	_apply_page_texture(_mesh_right, _vp_right)


func _update_nav() -> void:
	var total := _spread_count()
	_page_label.text = "第 %d / %d 开" % [_spread + 1, total]
	_btn_prev.disabled = _flipping or _spread <= 0
	_btn_next.disabled = _flipping or _spread >= total - 1
	var name_en := String(_character.get("name_en", ""))
	_title_label.text = "%s  ·  信使宝典" % name_en


func _on_book_gui_input(event: InputEvent) -> void:
	if _flipping:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_tracking = true
			_touch_start = touch.position
		elif _touch_tracking:
			_touch_tracking = false
			_handle_swipe_or_tap(touch.position)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_touch_tracking = true
			_touch_start = mb.position
		elif _touch_tracking:
			_touch_tracking = false
			_handle_swipe_or_tap(mb.position)


func _handle_swipe_or_tap(end_pos: Vector2) -> void:
	var delta := end_pos - _touch_start
	if absf(delta.x) > 72.0 and absf(delta.x) > absf(delta.y):
		if delta.x < 0.0:
			_turn_forward()
		else:
			_turn_backward()
		return
	# 点击：左半上一页，右半下一页（坐标相对书本 ViewportContainer）
	var host_w := 1.0
	if _book_host:
		host_w = maxf(_book_host.size.x, 1.0)
	if end_pos.x > host_w * 0.5:
		_turn_forward()
	else:
		_turn_backward()


func _turn_forward() -> void:
	if _flipping or _spread >= _spread_count() - 1:
		return
	_flipping = true
	_update_nav()
	_flip_forward_async()


func _flip_forward_async() -> void:
	var cur_left := _spread * 2
	var cur_right := cur_left + 1
	var next_left := cur_left + 2
	var next_right := cur_left + 3

	_paint_page(_vp_front, _page_at(cur_right))
	_paint_page(_vp_back, _page_at(next_left))
	_paint_page(_vp_left, _page_at(cur_left))
	_paint_page(_vp_right, _page_at(next_right))
	await RenderingServer.frame_post_draw

	if not is_instance_valid(self):
		return

	var left_m: MeshInstance3D = _turning_root.get_meta("left_mesh")
	var right_m: MeshInstance3D = _turning_root.get_meta("right_mesh")
	_apply_page_texture(left_m, _vp_left)
	_apply_page_texture(right_m, _vp_right)
	_apply_page_texture(_mesh_turn_front, _vp_front)
	_apply_page_texture(_mesh_turn_back, _vp_back)

	_turn_pivot.rotation_degrees.y = 0.0
	_static_root.visible = false
	_turning_root.visible = true

	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_turn_pivot, "rotation_degrees:y", -180.0, FLIP_SEC)
	tw.finished.connect(_on_flip_forward_done, CONNECT_ONE_SHOT)


func _on_flip_forward_done() -> void:
	_spread += 1
	_turning_root.visible = false
	_static_root.visible = true
	_turn_pivot.rotation_degrees.y = 0.0
	_refresh_static_pages()
	_flipping = false
	_update_nav()


func _turn_backward() -> void:
	if _flipping or _spread <= 0:
		return
	_flipping = true
	_update_nav()
	_flip_backward_async()


func _flip_backward_async() -> void:
	var cur_left := _spread * 2
	var cur_right := cur_left + 1
	var prev_left := cur_left - 2
	var prev_right := cur_left - 1

	# 往后翻：从左侧掀回。起始角 -180，可见面=当前左页；结束时右页=上一开右页
	_paint_page(_vp_front, _page_at(prev_right))
	_paint_page(_vp_back, _page_at(cur_left))
	_paint_page(_vp_left, _page_at(prev_left))
	_paint_page(_vp_right, _page_at(cur_right))
	await RenderingServer.frame_post_draw

	if not is_instance_valid(self):
		return

	var left_m: MeshInstance3D = _turning_root.get_meta("left_mesh")
	var right_m: MeshInstance3D = _turning_root.get_meta("right_mesh")
	_apply_page_texture(left_m, _vp_left)
	_apply_page_texture(right_m, _vp_right)
	_apply_page_texture(_mesh_turn_front, _vp_front)
	_apply_page_texture(_mesh_turn_back, _vp_back)

	_turn_pivot.rotation_degrees.y = -180.0
	_static_root.visible = false
	_turning_root.visible = true

	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_turn_pivot, "rotation_degrees:y", 0.0, FLIP_SEC)
	tw.finished.connect(_on_flip_backward_done, CONNECT_ONE_SHOT)


func _on_flip_backward_done() -> void:
	_spread -= 1
	_turning_root.visible = false
	_static_root.visible = true
	_turn_pivot.rotation_degrees.y = 0.0
	_refresh_static_pages()
	_flipping = false
	_update_nav()
