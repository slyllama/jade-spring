extends Area3D
# Gadget
# A simple area that can handle interactions and events.

signal interacted

@export var active = true
## If true, the 'interact' label disappears on use and the player must enter
## the gadget's area to use it again.
@export var reset_on_interact = true
var in_range = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if active and in_range:
			interacted.emit()
			if reset_on_interact:
				in_range = false
				Global.generic_area_left.emit()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_range = true
		if active:
			Global.generic_area_entered.emit()

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_range = false
		Global.generic_area_left.emit()
