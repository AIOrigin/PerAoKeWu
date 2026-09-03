extends VBoxContainer

## 结算标题区：胜利青蓝 / 失败紫粉

var outpost_title := "Water Station"
var _headline: Label
var _t := 0.0
var _is_failure := false


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 6)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 5


func _process(_delta: float) -> void:
	pass


func configure(outpost_name: String, failed: bool = false, fail_reason_en: String = "DELIVERY LOST", fail_reason_cn: String = "") -> void:
	outpost_title = outpost_name if outpost_name != "" else "Destination"
	_is_failure = failed
	for child in get_children():
		child.queue_free()
	_headline = null
	if failed:
		_build_failure_labels(fail_reason_en, fail_reason_cn)
	else:
		_build_success_labels()


func _build_success_labels() -> void:
	_headline = Label.new()
	_headline.name = "MissionCompleteHeadline"
	_headline.text = "MISSION COMPLETE"
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.add_theme_font_size_override("font_size", 72)
	_headline.add_theme_color_override("font_color", Color("#FFFFFF"))
	_headline.add_theme_color_override("font_outline_color", Color("#FFFFFF", 0.0))
	_headline.add_theme_constant_override("outline_size", 0)
	_headline.add_theme_color_override("font_shadow_color", Color("#000000", 0.42))
	_headline.add_theme_constant_override("shadow_offset_x", 0)
	_headline.add_theme_constant_override("shadow_offset_y", 2)
	_headline.add_theme_constant_override("letter_spacing", 4)
	add_child(_headline)

	var subtitle_row := HBoxContainer.new()
	subtitle_row.alignment = BoxContainer.ALIGNMENT_CENTER
	subtitle_row.add_theme_constant_override("separation", 8)
	add_child(subtitle_row)

	var loc := Label.new()
	loc.text = outpost_title.to_upper()
	loc.add_theme_font_size_override("font_size", 22)
	loc.add_theme_color_override("font_color", Color("#FFFFFF"))
	loc.add_theme_color_override("font_outline_color", Color("#060910", 0.0))
	loc.add_theme_constant_override("outline_size", 0)
	loc.add_theme_color_override("font_shadow_color", Color("#000000", 0.35))
	loc.add_theme_constant_override("shadow_offset_x", 0)
	loc.add_theme_constant_override("shadow_offset_y", 1)
	loc.add_theme_constant_override("letter_spacing", 2)
	subtitle_row.add_child(loc)

	var sep := Label.new()
	sep.text = "//"
	sep.add_theme_font_size_override("font_size", 22)
	sep.add_theme_color_override("font_color", Color("#68C8F0"))
	sep.add_theme_constant_override("outline_size", 0)
	sep.add_theme_color_override("font_outline_color", Color("#060910", 0.0))
	sep.add_theme_color_override("font_shadow_color", Color("#000000", 0.25))
	sep.add_theme_constant_override("shadow_offset_x", 0)
	sep.add_theme_constant_override("shadow_offset_y", 1)
	subtitle_row.add_child(sep)

	var secured := Label.new()
	secured.text = "DELIVERY SECURED"
	secured.add_theme_font_size_override("font_size", 22)
	secured.add_theme_color_override("font_color", Color("#68C8F0"))
	secured.add_theme_color_override("font_outline_color", Color("#060910", 0.0))
	secured.add_theme_constant_override("outline_size", 0)
	secured.add_theme_color_override("font_shadow_color", Color("#000000", 0.35))
	secured.add_theme_constant_override("shadow_offset_x", 0)
	secured.add_theme_constant_override("shadow_offset_y", 1)
	secured.add_theme_constant_override("letter_spacing", 2)
	subtitle_row.add_child(secured)


func _build_failure_labels(fail_reason_en: String, fail_reason_cn: String = "") -> void:
	_headline = Label.new()
	_headline.name = "DeliveryFailedHeadline"
	_headline.text = "DELIVERY FAILED"
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.add_theme_font_size_override("font_size", 72)
	_headline.add_theme_color_override("font_color", Color("#FFD0F8"))
	_headline.add_theme_color_override("font_outline_color", Color("#D060E8", 0.95))
	_headline.add_theme_constant_override("outline_size", 12)
	_headline.add_theme_color_override("font_shadow_color", Color("#8040A8", 0.70))
	_headline.add_theme_constant_override("shadow_offset_x", 0)
	_headline.add_theme_constant_override("shadow_offset_y", 5)
	_headline.add_theme_constant_override("letter_spacing", 4)
	add_child(_headline)

	var subtitle_row := HBoxContainer.new()
	subtitle_row.alignment = BoxContainer.ALIGNMENT_CENTER
	subtitle_row.add_theme_constant_override("separation", 10)
	add_child(subtitle_row)

	var loc := Label.new()
	loc.text = outpost_title.to_upper()
	loc.add_theme_font_size_override("font_size", 28)
	loc.add_theme_color_override("font_color", Color("#F8E8FF"))
	loc.add_theme_color_override("font_outline_color", Color("#060910", 0.75))
	loc.add_theme_constant_override("outline_size", 4)
	loc.add_theme_constant_override("letter_spacing", 2)
	subtitle_row.add_child(loc)

	var sep := Label.new()
	sep.text = "//"
	sep.add_theme_font_size_override("font_size", 28)
	sep.add_theme_color_override("font_color", Color("#D878F0"))
	sep.add_theme_constant_override("outline_size", 3)
	sep.add_theme_color_override("font_outline_color", Color("#060910", 0.6))
	subtitle_row.add_child(sep)

	var reason := Label.new()
	reason.text = fail_reason_en.to_upper()
	reason.add_theme_font_size_override("font_size", 28)
	reason.add_theme_color_override("font_color", Color("#FFB8E8"))
	reason.add_theme_color_override("font_outline_color", Color("#060910", 0.75))
	reason.add_theme_constant_override("outline_size", 4)
	reason.add_theme_constant_override("letter_spacing", 2)
	subtitle_row.add_child(reason)

	if fail_reason_cn.strip_edges() != "" and GameLocale.is_zh():
		var cn := Label.new()
		cn.name = "FailureReasonCN"
		cn.text = fail_reason_cn
		cn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cn.add_theme_font_size_override("font_size", 26)
		cn.add_theme_color_override("font_color", Color("#FFE0F4"))
		cn.add_theme_color_override("font_outline_color", Color("#060910", 0.8))
		cn.add_theme_constant_override("outline_size", 5)
		cn.add_theme_color_override("font_shadow_color", Color("#602080", 0.55))
		cn.add_theme_constant_override("shadow_offset_x", 0)
		cn.add_theme_constant_override("shadow_offset_y", 2)
		add_child(cn)
