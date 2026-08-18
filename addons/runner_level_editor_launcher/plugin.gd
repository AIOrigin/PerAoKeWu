@tool
extends EditorPlugin

const EDITOR_SCENE := "res://assets/maps/route_levels/runner_60s/level_editor/runner_level_editor.tscn"

var _toolbar_btn: Button


func _enter_tree() -> void:
	add_tool_menu_item("运行跑道关卡编辑器", _run_level_editor)
	_toolbar_btn = Button.new()
	_toolbar_btn.text = "▶ 关卡编辑器"
	_toolbar_btn.tooltip_text = "运行跑道关卡编辑器（F5 只会进游戏主页，请用此按钮或 F6）"
	_toolbar_btn.pressed.connect(_run_level_editor)
	add_control_to_container(CONTAINER_TOOLBAR, _toolbar_btn)


func _exit_tree() -> void:
	remove_tool_menu_item("运行跑道关卡编辑器")
	if _toolbar_btn != null:
		remove_control_from_container(CONTAINER_TOOLBAR, _toolbar_btn)
		_toolbar_btn.queue_free()
		_toolbar_btn = null


func _run_level_editor() -> void:
	if not ResourceLoader.exists(EDITOR_SCENE):
		push_error("找不到关卡编辑器场景：%s" % EDITOR_SCENE)
		return
	# 只运行场景，不要先 open_scene_from_path——切换标签会弹出「保存未保存更改」
	# 对话框，与 play 冲突并触发 window.cpp exclusive child 报错。
	EditorInterface.play_custom_scene(EDITOR_SCENE)
