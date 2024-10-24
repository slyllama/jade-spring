@icon("res://lib/decoration/icon_decoration.svg")
class_name Decoration extends Node3D

@export var collision_box: PhysicsBody3D

var last_position: Vector3

func start_adjustment() -> void:
	Global.active_decoration = self
	Global.adjustment_started.emit()
	Global.tool_mode = Global.TOOL_MODE_ADJUST
	
	last_position = position
	collision_box.input_ray_pickable = false
	collision_box.set_collision_layer_value(1, 0)
	$Gizmo.activate()


func apply_adjustment() -> void:
	if Global.active_decoration == self:
		Global.active_decoration = null
		
		collision_box.set_collision_layer_value(1, 1)
		$Gizmo.deactivate()
		collision_box.input_ray_pickable = true

func cancel_adjustment() -> void:
	if Global.active_decoration == self:
		Global.active_decoration = null
		
		collision_box.set_collision_layer_value(1, 1)
		$Gizmo.deactivate()
		collision_box.input_ray_pickable = true
		
		position = last_position

func _ready() -> void:
	Global.adjustment_canceled.connect(cancel_adjustment)
	Global.adjustment_applied.connect(apply_adjustment)
	
	if collision_box != null:
		collision_box.input_event.connect(func(_c, _e, _p, _n, _i):
			if Global.tool_mode != Global.TOOL_MODE_SELECT: return
			if Global.active_decoration != null: return
			if Input.is_action_just_pressed("left_click"):
				start_adjustment())
