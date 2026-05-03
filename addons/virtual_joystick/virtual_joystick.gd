extends Control

@export var action_left: String = "move_left"
@export var action_right: String = "move_right"
@export var action_up: String = "move_up"
@export var action_down: String = "move_down"

@export var deadzone_size: float = 10.0
@export var clampzone_size: float = 75.0

@export var joystick_mode: int = 0 # 0: FIXED, 1: DYNAMIC

var _touch_index: int = -1
var _center: Vector2
var _base_pos: Vector2

@onready var _base: TextureRect = $Base
@onready var _tip: TextureRect = $Base/Tip

func _ready() -> void:
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		# Hide on non-mobile platforms unless explicitly testing
		# For prototyping, we'll keep it visible but transparent or just keep it
		pass
	_base_pos = _base.position
	_center = _base.position + _base.size / 2

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1:
				if _is_point_inside_joystick_area(event.position):
					_touch_index = event.index
					if joystick_mode == 1:
						_base.position = event.position - _base.size / 2
						_center = event.position
					else:
						_update_joystick(event.position)
		elif event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)

func _is_point_inside_joystick_area(point: Vector2) -> bool:
	var x: bool = point.x >= get_global_position().x and point.x <= get_global_position().x + size.x
	var y: bool = point.y >= get_global_position().y and point.y <= get_global_position().y + size.y
	return x and y

func _update_joystick(touch_position: Vector2) -> void:
	var center_global = _base.global_position + _base.size / 2
	var vector: Vector2 = touch_position - center_global

	if vector.length() > clampzone_size:
		vector = vector.normalized() * clampzone_size

	_tip.position = _base.size / 2 + vector - _tip.size / 2

	if vector.length() > deadzone_size:
		_send_input(vector.normalized())
	else:
		_send_input(Vector2.ZERO)

func _reset() -> void:
	_touch_index = -1
	_tip.position = _base.size / 2 - _tip.size / 2
	_base.position = _base_pos
	_send_input(Vector2.ZERO)

func _send_input(vector: Vector2) -> void:
	var ev_left = InputEventAction.new()
	ev_left.action = action_left
	ev_left.pressed = vector.x < 0
	Input.parse_input_event(ev_left)

	var ev_right = InputEventAction.new()
	ev_right.action = action_right
	ev_right.pressed = vector.x > 0
	Input.parse_input_event(ev_right)

	var ev_up = InputEventAction.new()
	ev_up.action = action_up
	ev_up.pressed = vector.y < 0
	Input.parse_input_event(ev_up)

	var ev_down = InputEventAction.new()
	ev_down.action = action_down
	ev_down.pressed = vector.y > 0
	Input.parse_input_event(ev_down)
