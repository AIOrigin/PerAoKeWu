extends Control
class_name SettlementHorizonLayer

## 样例结算页：青蓝天空 + 建筑剪影 + 紫白同心环 + 跃起小人

const BUILDING_SILHOUETTE_PATH := "res://assets/maps/route_levels/runner_60s/settlement/water_station_silhouette.png"
const FIGURE_SILHOUETTE_PATH := "res://assets/maps/route_levels/runner_60s/settlement/elsa_jump_silhouette.png"
const FIGURE_FAILURE_SILHOUETTE_PATH := "res://assets/maps/route_levels/runner_60s/settlement/elsa_failure_dejected_silhouette.png"
const SETTLEMENT_SILHOUETTE := {
	"dome": "res://assets/maps/route_levels/runner_60s/settlement/habitat_dome_silhouette.jpg",
	"reservoir": "res://assets/maps/route_levels/runner_60s/settlement/water_station_silhouette.png",
	"medical": "res://assets/maps/route_levels/runner_60s/settlement/medical_settlement_silhouette.png",
	"gate": "res://assets/maps/route_levels/runner_60s/settlement/defense_settlement_silhouette.png",
	"relay": "res://assets/maps/route_levels/runner_60s/settlement/relay_settlement_silhouette.png",
}

const SKY_TOP := Color(0.52, 0.58, 0.66)
const SKY_MID := Color(0.30, 0.36, 0.46)
const SKY_NEAR := Color(0.14, 0.18, 0.28)
const GROUND_TOP := Color(0.06, 0.09, 0.14)
const GROUND_BOT := Color(0.025, 0.035, 0.07)
const HORIZON_CORE := Color(0.92, 0.98, 1.0)
const HORIZON_GLOW := Color(0.72, 0.94, 1.0)
const AURA_CORE := Color(0.55, 0.88, 1.0)
const AURA_MID := Color(0.48, 0.36, 0.78)
const RING_INNER := Color("#E8DCFF")
const RING_MID := Color("#B898E8")
const RING_OUTER := Color("#8868B8")
const SILHOUETTE := Color("#0A0E16")
const SILHOUETTE_LINE := Color("#68C8F0")
const SILHOUETTE_LINE_SOFT := Color("#4AA8E8")
const FAIL_RING_INNER := Color("#F0B0FF")
const FAIL_RING_MID := Color("#C868E8")
const FAIL_RING_OUTER := Color("#8848B8")
const FAIL_HORIZON_CORE := Color("#FFD0F8")
const FAIL_BODY := Color("#050508")
const FAIL_RIM := Color("#8AD8FF")

var outpost_title := "Water Station"
var horizon_ratio := 0.42

var _is_failure := false
var _ring_center := Vector2.ZERO
var _figure_reflect: TextureRect
var _base_fill: ColorRect
var _upper_sky_fill: ColorRect
var _backdrop: ColorRect
var _sky: Control
var _building_clip: Control
var _building: TextureRect
var _fx: Control
var _figure_glow_outer: TextureRect
var _figure_glow_inner: TextureRect
var _figure_halo: Control
var _figure: TextureRect
var _flare_tex: Texture2D
var _t := 0.0
var _figure_base_y := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_sync_layout)
	visibility_changed.connect(func(): if visible: call_deferred("_sync_layout"))
	_flare_tex = _make_soft_flare_texture(256)
	_build_layers()


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	if _sky != null:
		_sky.queue_redraw()
	if _fx != null:
		_fx.queue_redraw()
	if _figure != null and not _is_failure:
		_figure.position.y = _figure_base_y + sin(_t * 2.8) * 1.6
		if _figure_reflect != null and _figure_reflect.visible:
			_figure_reflect.position.y = _figure.position.y + _figure.size.y + 2.0
	elif _figure != null and _is_failure:
		var pulse := 0.88 + sin(_t * 1.8) * 0.12
		_figure.position.y = _figure_base_y + sin(_t * 1.4) * 0.35
		if _figure_glow_inner != null:
			_figure_glow_inner.modulate.a = 0.52 * pulse
		if _figure_glow_outer != null:
			_figure_glow_outer.modulate.a = 0.38 * pulse
		if _figure_halo != null:
			_figure_halo.modulate.a = 0.92 + sin(_t * 1.6) * 0.08


func _build_layers() -> void:
	_base_fill = ColorRect.new()
	_base_fill.name = "BaseFill"
	_base_fill.color = GROUND_BOT
	_base_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_base_fill)

	_upper_sky_fill = ColorRect.new()
	_upper_sky_fill.name = "UpperSkyFill"
	_upper_sky_fill.color = SKY_TOP
	_upper_sky_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_upper_sky_fill)

	_backdrop = ColorRect.new()
	_backdrop.name = "LowerBackdrop"
	_backdrop.color = GROUND_TOP
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_backdrop)

	_sky = Control.new()
	_sky.name = "SkyGradient"
	_sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sky.draw.connect(_draw_sky)
	add_child(_sky)

	_building_clip = Control.new()
	_building_clip.name = "BuildingClip"
	_building_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_building_clip.clip_contents = true
	_building_clip.z_index = 0
	add_child(_building_clip)

	_building = TextureRect.new()
	_building.name = "BuildingSilhouette"
	_building.texture = _load_building_tex(BUILDING_SILHOUETTE_PATH)
	_building.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_building.stretch_mode = TextureRect.STRETCH_SCALE
	_building.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_building.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_building_clip.add_child(_building)

	_fx = Control.new()
	_fx.name = "HorizonFX"
	_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx.z_index = 1
	_fx.draw.connect(_draw_fx)
	add_child(_fx)

	_figure_glow_outer = _make_figure_glow_rect("FigureGlowOuter", Color(0.72, 0.58, 0.96, 0.14), 2)
	add_child(_figure_glow_outer)
	_figure_glow_inner = _make_figure_glow_rect("FigureGlowInner", Color(1.0, 1.0, 1.0, 0.22), 2)
	add_child(_figure_glow_inner)

	_figure_halo = _FigureHalo.new()
	_figure_halo.name = "FigureHalo"
	_figure_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_figure_halo.z_index = 2
	_figure_halo.visible = false
	add_child(_figure_halo)

	_figure = TextureRect.new()
	_figure.name = "JumpSilhouette"
	_figure.texture = _load_black_figure_tex(FIGURE_SILHOUETTE_PATH)
	_figure.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_figure.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_figure.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_figure.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_figure.z_index = 3
	add_child(_figure)

	_figure_reflect = TextureRect.new()
	_figure_reflect.name = "JumpSilhouetteReflect"
	_figure_reflect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_figure_reflect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_figure_reflect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_figure_reflect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_figure_reflect.z_index = 0
	_figure_reflect.modulate = Color(0.04, 0.06, 0.10, 0.38)
	add_child(_figure_reflect)

	_sync_layout()


func _make_figure_glow_rect(node_name: String, tint: Color, z: int) -> TextureRect:
	var glow := TextureRect.new()
	glow.name = node_name
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.z_index = z
	glow.modulate = tint
	glow.visible = false
	return glow


func configure(outpost_name: String, location_id: String, _hearth_scene_path: String, failed: bool = false) -> void:
	outpost_title = outpost_name if outpost_name != "" else "Destination"
	_is_failure = failed
	var silhouette_path := _resolve_silhouette_path(location_id)
	if _building != null:
		if failed:
			_building.texture = _load_building_tex_failure(silhouette_path)
		else:
			_building.texture = _load_station_silhouette_tex(silhouette_path)
		_building.modulate = Color(0.72, 0.76, 0.82, 0.78) if failed else Color(0.94, 0.98, 1.0, 1.0)
	if _figure != null:
		var figure_path := FIGURE_FAILURE_SILHOUETTE_PATH if failed else FIGURE_SILHOUETTE_PATH
		var fig_tex := _load_failure_figure_tex(figure_path) if failed else _load_black_figure_tex(FIGURE_SILHOUETTE_PATH)
		_figure.texture = fig_tex
		if _figure_glow_outer != null:
			_figure_glow_outer.visible = not failed
		if _figure_glow_inner != null:
			_figure_glow_inner.visible = not failed
	call_deferred("_sync_layout")


func _load_tex(path: String) -> Texture2D:
	if path.strip_edges() == "":
		return null
	var abs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path) or FileAccess.file_exists(abs_path):
		var img := Image.load_from_file(abs_path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(path):
		var res := load(path)
		if res is Texture2D:
			return res
	return null


func _silhouette_resource_exists(path: String) -> bool:
	if path.strip_edges() == "":
		return false
	if FileAccess.file_exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return true
	return ResourceLoader.exists(path)


func _resolve_silhouette_path(location_id: String) -> String:
	var loc := location_id
	if loc == "medbay":
		loc = "medical"
	elif loc == "outpost":
		loc = "gate"
	var candidates: Array[String] = []
	if SETTLEMENT_SILHOUETTE.has(loc):
		candidates.append(String(SETTLEMENT_SILHOUETTE[loc]))
	match loc:
		"dome":
			candidates.append("res://mvp素材第一批/居民穹顶2d展示图.webp")
		"reservoir":
			candidates.append("res://mvp素材第一批/水源据点2d.webp")
	if not candidates.has(BUILDING_SILHOUETTE_PATH):
		candidates.append(BUILDING_SILHOUETTE_PATH)
	for path in candidates:
		if _silhouette_resource_exists(path):
			return path
	return BUILDING_SILHOUETTE_PATH


func _load_building_tex(path: String, failed: bool = false) -> Texture2D:
	if failed:
		return _load_building_tex_failure(path)
	return _load_station_silhouette_tex(path)


func _load_building_tex_failure(path: String) -> Texture2D:
	var tex := _load_tex(path)
	if tex == null:
		return null
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.04:
				continue
			var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			if luma > 0.62:
				c = Color(0.46, 0.49, 0.54, maxf(c.a, 0.82))
			elif luma > 0.18:
				c = Color(0.24, 0.26, 0.30, maxf(c.a, 0.88))
			else:
				c = Color(0.11, 0.12, 0.14, maxf(c.a, 0.94))
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func _load_station_silhouette_tex(path: String) -> Texture2D:
	var tex := _load_tex(path)
	if tex == null:
		return null
	var lower := path.to_lower()
	if lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".webp") or "silhouette" in lower:
		return _prepare_settlement_building_tex(tex, path)
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	img = img.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.04:
				continue
			var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			if luma > 0.08:
				c = Color(SILHOUETTE.r, SILHOUETTE.g, SILHOUETTE.b, maxf(c.a, 0.98))
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func _color_saturation(c: Color) -> float:
	return maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b))


func _prepare_settlement_building_tex(source: Texture2D, path: String) -> Texture2D:
	var img := source.get_image()
	if img == null or img.is_empty():
		return source
	img = img.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.04:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			var sat := _color_saturation(c)
			# 去掉白底/灰格，避免整图变成与背景融为一体的实心黑块
			if luma > 0.72 and sat < 0.28:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			if luma > 0.58 and sat < 0.12:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			# 青蓝或品红线框都收成结算页同一套青线，保持现有色调
			var is_cyan_line := c.b > c.r + 0.06 and c.b > 0.32 and luma > 0.22
			var is_purple_line := c.b > 0.26 and c.r > 0.16 and (c.r + c.b) > c.g * 1.85 and luma > 0.16 and sat > 0.10
			if is_cyan_line or is_purple_line:
				var line_a := clampf(maxf(c.a, 0.78) + (luma - 0.16) * 0.35, 0.0, 1.0)
				img.set_pixel(x, y, Color(SILHOUETTE_LINE.r, SILHOUETTE_LINE.g, SILHOUETTE_LINE.b, line_a))
				continue
			if luma < 0.34:
				img.set_pixel(x, y, Color(SILHOUETTE.r, SILHOUETTE.g, SILHOUETTE.b, maxf(c.a, 0.94)))
				continue
			var fill_a := clampf((0.56 - luma) / 0.34, 0.0, 1.0)
			if fill_a < 0.06:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
			else:
				var tone := SILHOUETTE.lerp(SILHOUETTE_LINE_SOFT, clampf((luma - 0.18) * 1.4, 0.0, 0.42))
				img.set_pixel(x, y, Color(tone.r, tone.g, tone.b, fill_a * 0.92))
	return ImageTexture.create_from_image(img)


func _load_black_figure_tex(path: String) -> Texture2D:
	var tex := _load_tex(path)
	if tex == null:
		return null
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.04:
				continue
			c = Color(SILHOUETTE.r, SILHOUETTE.g, SILHOUETTE.b, maxf(c.a, 0.99))
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func _load_failure_figure_tex(path: String) -> Texture2D:
	var tex := _load_tex(path)
	if tex == null:
		return null
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.08:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			if luma < 0.72:
				c = Color(FAIL_BODY.r, FAIL_BODY.g, FAIL_BODY.b, maxf(c.a, 0.99))
			else:
				c = FAIL_RIM.lerp(HORIZON_CORE, 0.22)
				c.a = maxf(c.a, 0.88)
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func _make_soft_flare_texture(size: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var cx := (size - 1) * 0.5
	var max_r := cx
	for y in size:
		for x in size:
			var dx := (float(x) - cx) / max_r
			var dy := (float(y) - cx) / max_r
			var d := sqrt(dx * dx + dy * dy)
			var a := clampf(1.0 - d, 0.0, 1.0)
			a = a * a * (3.0 - 2.0 * a)
			a = pow(a, 1.55)
			var c := RING_INNER.lerp(RING_OUTER, 1.0 - a)
			c.a = a * 0.92
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func _sync_layout() -> void:
	var sz := size
	if sz.x < 2.0 or sz.y < 2.0:
		sz = get_viewport_rect().size
	if sz.x < 2.0 or sz.y < 2.0:
		return
	var horizon_y := sz.y * horizon_ratio

	if _base_fill != null:
		_base_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _upper_sky_fill != null:
		_upper_sky_fill.set_anchors_preset(Control.PRESET_TOP_WIDE)
		_upper_sky_fill.offset_bottom = horizon_y
	if _backdrop != null:
		_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		_backdrop.offset_top = horizon_y
		_backdrop.offset_bottom = 0.0
	if _sky != null:
		_sky.set_anchors_preset(Control.PRESET_FULL_RECT)
		_sky.queue_redraw()

	if _building_clip != null and _building != null and _building.texture != null:
		_building_clip.position = Vector2(0.0, 0.0)
		_building_clip.size = Vector2(sz.x, horizon_y + sz.y * 0.04)

		var tex := _building.texture.get_size()
		var target := _building_clip.size
		var fit := maxf((target.x * 1.38) / maxf(tex.x, 1.0), (target.y * 1.02) / maxf(tex.y, 1.0))
		var b_w := tex.x * fit
		var b_h := tex.y * fit
		_building.size = Vector2(b_w, b_h)
		_building.position = Vector2((target.x - b_w) * 0.5, horizon_y - b_h * 0.98)

	if _fx != null:
		_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
		_fx.queue_redraw()

	if _figure != null:
		var fig_h := sz.y * (0.26 if _is_failure else 0.24)
		var fig_aspect := 0.72
		if _figure.texture != null:
			var ft := _figure.texture.get_size()
			fig_aspect = ft.x / maxf(ft.y, 1.0)
		var fig_w := fig_h * fig_aspect
		var feet_y := horizon_y - sz.y * 0.004
		var fig_pos := Vector2(sz.x * 0.5 - fig_w * 0.5, feet_y - fig_h)
		_figure.size = Vector2(fig_w, fig_h)
		_figure.position = fig_pos
		_figure_base_y = fig_pos.y
		_figure.visible = _figure.texture != null
		_ring_center = fig_pos + Vector2(fig_w * 0.5, fig_h * 0.44)
		if _figure_reflect != null and _figure.texture != null:
			_figure_reflect.texture = _figure.texture
			var reflect_h := fig_h * 0.38
			_figure_reflect.size = Vector2(fig_w, reflect_h)
			_figure_reflect.pivot_offset = Vector2(fig_w * 0.5, 0.0)
			_figure_reflect.scale = Vector2(1.0, -1.0)
			_figure_reflect.position = Vector2(fig_pos.x, feet_y + sz.y * 0.004)
			_figure_reflect.visible = _figure.visible and not _is_failure
		if _figure_glow_outer != null:
			_figure_glow_outer.visible = false
		if _figure_glow_inner != null:
			_figure_glow_inner.visible = false
	if _fx != null:
		_fx.queue_redraw()


func _draw_sky() -> void:
	var sz := _sky.size
	if sz.x < 2.0 or sz.y < 2.0:
		return
	var horizon_y := sz.y * horizon_ratio
	# 上半：浅青白天空，越靠近地平线越亮（样例 frame_65）
	for i in 128:
		var t0 := float(i) / 128.0
		var y0 := horizon_y * t0
		var y1 := horizon_y * (t0 + 1.0 / 128.0) + 1.0
		var c: Color
		if t0 < 0.35:
			c = SKY_TOP.lerp(SKY_MID, smoothstep(0.0, 0.35, t0))
		else:
			c = SKY_MID.lerp(SKY_NEAR, smoothstep(0.35, 1.0, t0))
		_sky.draw_rect(Rect2(0.0, y0, sz.x, y1 - y0), c)
	# 地平线附近向上溢出的白青光
	var glow_h := maxf(8.0, sz.y * 0.028)
	for i in 6:
		var t := float(i) / 5.0
		var band_h := glow_h * (1.0 - t * 0.55)
		var alpha := lerpf(0.28, 0.04, t)
		_sky.draw_rect(
			Rect2(0.0, horizon_y - band_h * (1.0 + t * 0.35), sz.x, band_h),
			Color(HORIZON_GLOW.r, HORIZON_GLOW.g, HORIZON_GLOW.b, alpha)
		)
	var floor_h := sz.y - horizon_y
	for i in 64:
		var t0 := float(i) / 64.0
		var y0 := horizon_y + floor_h * t0
		var y1 := horizon_y + floor_h * (t0 + 1.0 / 64.0) + 1.0
		_sky.draw_rect(Rect2(0.0, y0, sz.x, y1 - y0), GROUND_TOP.lerp(GROUND_BOT, t0))


func _draw_fx() -> void:
	var sz := _fx.size
	if sz.x < 2.0 or sz.y < 2.0:
		return
	var horizon_y := sz.y * horizon_ratio
	var pulse := 0.96 + sin(_t * 0.9) * 0.04
	var cx := sz.x * 0.5
	var ring_center := _ring_center if _ring_center.length_squared() > 4.0 else Vector2(cx, horizon_y - sz.y * 0.04)
	var ring_mid: Color = FAIL_RING_MID if _is_failure else RING_MID

	# 参考图：人物背后大团紫粉光晕 + 水平 lens flare
	if _flare_tex != null:
		var aura_w := sz.x * 0.72
		var aura_h := sz.y * 0.34
		var aura_rect := Rect2(ring_center.x - aura_w * 0.5, ring_center.y - aura_h * 0.58, aura_w, aura_h)
		_fx.draw_texture_rect(_flare_tex, aura_rect, false, Color(AURA_CORE.r, AURA_CORE.g, AURA_CORE.b, 0.28 * pulse))
		var mid_rect := Rect2(ring_center.x - aura_w * 0.42, ring_center.y - aura_h * 0.48, aura_w * 0.84, aura_h * 0.72)
		_fx.draw_texture_rect(_flare_tex, mid_rect, false, Color(0.72, 0.86, 1.0, 0.16 * pulse))
	for i in 6:
		var t := float(i) / 5.0
		var r := sz.x * lerpf(0.10, 0.30, t)
		var a := lerpf(0.20, 0.02, t) * pulse
		_fx.draw_circle(ring_center, r, Color(AURA_MID.r, AURA_MID.g, AURA_MID.b, a))
	# 水平 lens flare
	_fx.draw_rect(Rect2(0.0, ring_center.y - 2.0, sz.x, 4.0), Color(1.0, 1.0, 1.0, 0.14 * pulse))
	_fx.draw_rect(Rect2(cx - sz.x * 0.38, ring_center.y - 7.0, sz.x * 0.76, 14.0), Color(0.82, 0.72, 1.0, 0.10 * pulse))

	# 细紫同心环（叠在光晕上）
	var ring_radii := [sz.x * 0.15, sz.x * 0.24, sz.x * 0.33]
	var ring_alphas := [0.22, 0.14, 0.08]
	for i in ring_radii.size():
		_fx.draw_arc(ring_center, float(ring_radii[i]) * pulse, 0.0, TAU, 72, Color(0.72, 0.55, 0.96, float(ring_alphas[i])), 1.0, true)

	# 地平线强 bloom
	var main_h := maxf(1.4, sz.y * 0.0016)
	_fx.draw_rect(Rect2(0.0, horizon_y - main_h * 4.0, sz.x, main_h * 8.0), Color(HORIZON_GLOW.r, HORIZON_GLOW.g, HORIZON_GLOW.b, 0.16 * pulse))
	_fx.draw_rect(Rect2(0.0, horizon_y - main_h * 0.50, sz.x, main_h * 1.0), Color(1.0, 1.0, 1.0, 0.92 * pulse))
	_fx.draw_rect(Rect2(cx - sz.x * 0.30, horizon_y - main_h * 1.1, sz.x * 0.60, main_h * 2.2), Color(1.0, 1.0, 1.0, 0.40 * pulse))

	# 地面淡反射
	for i in 5:
		var t := float(i) / 4.0
		var y := horizon_y + main_h * 1.2 + t * sz.y * 0.04
		var a := (1.0 - t) * (1.0 - t) * 0.07
		_fx.draw_rect(Rect2(0.0, y, sz.x, maxf(2.0, sz.y * 0.003)), Color(ring_mid.r, ring_mid.g, ring_mid.b, a))


class _FigureHalo extends Control:
	func mark_dirty() -> void:
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var base := minf(size.x, size.y) * 0.42
		for i in 10:
			var t := float(i) / 9.0
			var radius := base * lerpf(1.55, 0.62, t)
			var alpha := lerpf(0.05, 0.34, 1.0 - t)
			draw_circle(center, radius, Color(0.62, 0.42, 0.92, alpha))
		draw_circle(center, base * 0.52, Color(1.0, 1.0, 1.0, 0.18))
		draw_arc(center, base * 0.78, 0.0, TAU, 72, Color(0.92, 0.96, 1.0, 0.42), 2.0, true)
