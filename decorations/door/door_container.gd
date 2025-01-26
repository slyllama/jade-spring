extends Node3D
# DoorContainer
# Ensure that the animation is set properly in the preview and cursor

@export var live = false
var delay_complete = false

var door_state = -1.0
var target_door_state = -1.0

# -1: closed, 1: open
func _set_door_state(state: float) -> void:
	$Door/Anim.set("parameters/blend_position", state)

func _ready() -> void:
	target_door_state = -1.0
	
	Global.deco_deletion_started.connect(func():
		$Area/Collision.disabled = true)
	Global.deco_deletion_canceled.connect(func():
		$Area/Collision.disabled = false)
	
	Global.selection_started.connect(func():
		$Area/Collision.disabled = true)
	Global.selection_canceled.connect(func():
		$Area/Collision.disabled = false)
	
	Global.adjustment_applied.connect(func():
		$Area/Collision.disabled = false)
	Global.adjustment_canceled.connect(func():
		$Area/Collision.disabled = false)
	
	if live:
		$Delay.start()

func _process(delta: float) -> void:
	door_state = lerp(door_state, target_door_state, delta * 2.0)
	_set_door_state(door_state)

func _on_area_body_entered(body: Node3D) -> void:
	if delay_complete and body == Global.player:
		target_door_state = 1.0

func _on_area_body_exited(body: Node3D) -> void:
	if delay_complete and body == Global.player:
		target_door_state = -1.0

func _on_delay_timeout() -> void:
	delay_complete = true
