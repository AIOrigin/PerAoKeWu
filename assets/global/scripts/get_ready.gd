class_name GetReady
extends Node

## 条件为真后执行回调并自毁（替代已移除的 godot_core_system 工具）

var _condition: Callable
var _on_ready: Callable


func _init(condition: Callable = Callable(), on_ready: Callable = Callable()) -> void:
	_condition = condition
	_on_ready = on_ready


func _process(_delta: float) -> void:
	if not _condition.is_valid():
		queue_free()
		return
	var ok = _condition.call()
	if ok:
		if _on_ready.is_valid():
			_on_ready.call()
		queue_free()
