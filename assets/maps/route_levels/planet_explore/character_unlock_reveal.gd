class_name CharacterUnlockReveal
extends Control

signal view_runner_pressed
signal dismissed

const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const CharacterPortraitDisc = preload(
	"res://assets/maps/route_levels/mobile_home/character_portrait_disc.gd"
)

const BG := Color(0.02, 0.04, 0.08, 0.88)
const GOLD := Color(0.98, 0.84, 0.42)
const CYAN := Color(0.557, 0.882, 0.969)


static func play(parent: Control, character_name: String, on_view_runner: Callable = Callable()) -> CharacterUnlockReveal:
	var overlay := CharacterUnlockReveal.new()
	overlay.set_anchors_preset(PRESET_FULL_RECT)
	overlay.z_index = 200
	overlay.mouse_filter = MOUSE_FILTER_STOP
	parent.add_child(overlay)
	if on_view_runner.is_valid():
		overlay.view_runner_pressed.connect(on_view_runner)
	overlay.start(character_name)
	return overlay


func start(character_name: String) -> void:
	var character_id := character_name.to_lower()
	var character := CharacterRoster.get_character(character_id)
	if character.is_empty():
		character = CharacterRoster.get_character(CharacterRoster.CHAR_ROOK)

	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(420, 520)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.10, 0.16, 0.96)
	card_style.border_color = GOLD
	card_style.set_border_width_all(2)
	card_style.set_corner_radius_all(18)
	card_style.shadow_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.35)
	card_style.shadow_size = 24
	card_style.content_margin_left = 24
	card_style.content_margin_right = 24
	card_style.content_margin_top = 28
	card_style.content_margin_bottom = 24
	card.add_theme_stylebox_override("panel", card_style)
	center.add_child(card)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(col)

	var badge := Label.new()
	badge.text = "NEW RUNNER UNLOCKED · 新角色解锁"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 16)
	badge.add_theme_color_override("font_color", GOLD)
	col.add_child(badge)

	var portrait_host := CenterContainer.new()
	portrait_host.custom_minimum_size = Vector2(220, 220)
	col.add_child(portrait_host)
	var portrait := CharacterPortraitDisc.new()
	var tex := CharacterRoster.load_texture(String(character.get("hero_path", "")))
	portrait.setup(tex, 200, false)
	portrait_host.add_child(portrait)

	var name_lbl := Label.new()
	name_lbl.text = String(character.get("name_en", character_name.to_upper()))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 42)
	name_lbl.add_theme_color_override("font_color", Color(0.902, 0.988, 1.0))
	name_lbl.add_theme_color_override("font_shadow_color", Color(CYAN.r, CYAN.g, CYAN.b, 0.45))
	col.add_child(name_lbl)

	var sub := Label.new()
	sub.text = "Swipe to Rook on the Runner page · 可在角色页滑动查看"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86))
	col.add_child(sub)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(btn_row)

	var view_btn := Button.new()
	view_btn.text = "VIEW RUNNER"
	view_btn.focus_mode = FOCUS_NONE
	view_btn.custom_minimum_size = Vector2(180, 48)
	_style_btn(view_btn, Color(0.314, 0.549, 0.745, 0.85), CYAN, 18)
	view_btn.pressed.connect(_on_view_runner)
	btn_row.add_child(view_btn)

	var later_btn := Button.new()
	later_btn.text = "LATER"
	later_btn.focus_mode = FOCUS_NONE
	later_btn.custom_minimum_size = Vector2(120, 48)
	_style_btn(later_btn, Color(0.10, 0.12, 0.16, 0.9), Color(0.58, 0.64, 0.72), 16)
	later_btn.pressed.connect(_close)
	btn_row.add_child(later_btn)

	modulate.a = 0.0
	card.scale = Vector2(0.82, 0.82)
	card.pivot_offset = card.custom_minimum_size * 0.5
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_view_runner() -> void:
	view_runner_pressed.emit()
	_close()


func _close() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.18)
	tw.finished.connect(func():
		dismissed.emit()
		queue_free()
	)


func _style_btn(button: Button, fill: Color, border: Color, font_size: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color(0.902, 0.988, 1.0))
