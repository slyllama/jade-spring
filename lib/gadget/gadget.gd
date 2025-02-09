@tool
extends Area3D
# Gadget
# A simple area that can handle interactions and events.

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")
signal interacted

@export var active = true
## If true, the 'interact' label disappears on use and the player must enter
## the gadget's area to use it again.
@export var reset_on_interact = true
var in_range = false

@export var radius = 0.6:
	get: return(radius)
	set(_val):
		radius = _val
		$Collision.shape.radius = radius
		$VisualArea.mesh.top_radius = radius
		$VisualArea.mesh.bottom_radius = radius

@export var show_area = false:
	get: return(show_area)
	set(_val):
		show_area = _val
		$VisualArea.visible = show_area

@export var tint_color = Color("ff7b00"):
	get: return(tint_color)
	set(_val):
		var _mat = $VisualArea.get_active_material(0).duplicate()
		$VisualArea.set_surface_override_material(0, _mat)
		tint_color = _val
		_mat.set_shader_parameter("color", _val)

func spawn_dialogue(data: Dictionary, advance = false) -> void:
	var _d = Dialogue.instantiate()
	_d.data = data
	Global.hud.add_child(_d)
	_d.closed.connect(func():
		Global.generic_area_entered.emit()
		if advance:
			Save.advance_story())
	_d.open()

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
