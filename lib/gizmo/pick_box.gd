class_name PickBox extends Area3D
# Small, convenient class for making static bodies

var enabled = true
var active = false
var coll = CollisionShape3D.new()
var shape = BoxShape3D.new()

signal drag_started
signal drag_ended

func set_size(size: Vector3) -> void:
	shape.size = size

# If set, the camera won't orbit when dragging in this shape
func make_ui_component() -> void:
	mouse_entered.connect(func():
		if enabled:
			Global.mouse_in_ui = true)
	mouse_exited.connect(func():
		Global.mouse_in_ui = false)

func _input(_event: InputEvent) -> void:
	if active:
		if Input.is_action_just_released("left_click"):
			active = false
			drag_ended.emit()

func _ready() -> void:
	coll.shape = shape
	add_child(coll)
	
	input_event.connect(func(_c, _e, _p, _n, _i):
		if active: return
		if Input.is_action_just_pressed("left_click"):
			active = true
			drag_started.emit())
