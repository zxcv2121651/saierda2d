extends Control

@export var action: String = "attack"

var _touch_index: int = -1

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			if _is_point_inside(event.position):
				_touch_index = event.index
				_send_input(true)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_send_input(false)

func _is_point_inside(point: Vector2) -> bool:
	var x: bool = point.x >= get_global_position().x and point.x <= get_global_position().x + size.x
	var y: bool = point.y >= get_global_position().y and point.y <= get_global_position().y + size.y
	return x and y

func _send_input(pressed: bool) -> void:
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	Input.parse_input_event(ev)
