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

func _set_tint_color(_val) -> void:
	var _mat = $VisualArea.get_active_material(0).duplicate()
	$VisualArea.set_surface_override_material(0, _mat)
	_mat.set_shader_parameter("color", _val)

@export var tint_color = Color("ff7b00"):
	get: return(tint_color)
	set(_val):
		tint_color = _val
		_set_tint_color(_val)

func spawn_dialogue(data: Dictionary, advance = false) -> void:
	var _d = Dialogue.instantiate()
	_d.data = data
	Global.hud.add_child(_d)
	_d.closed.connect(func():
		Global.generic_area_entered.emit()
		if advance:
			Save.advance_story())
	_d.open()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var _unique_mesh = $VisualArea.mesh.duplicate(true)
	var _unique_collision = $Collision.shape.duplicate(true)
	
	$VisualArea.mesh = _unique_mesh
	$Collision.shape = _unique_collision
	
	$Collision.shape.radius = radius
	$VisualArea.mesh.top_radius = radius
	$VisualArea.mesh.bottom_radius = radius
	_set_tint_color(tint_color)
	
	Global.close_story_panel.connect(func():
		if overlaps_body(Global.player):
			Global.current_gadget = self
			in_range = true
			if active:
				Global.generic_area_entered.emit())

func _input(_event: InputEvent) -> void:
	if Global.tool_mode != Global.TOOL_MODE_NONE: return
	if !Global.can_move: return
	if Input.is_action_just_pressed("interact"):
		if active and in_range and Global.current_gadget == self:
			interacted.emit()
			if reset_on_interact:
				in_range = false
				Global.generic_area_left.emit()

func _on_body_entered(body: Node3D) -> void:
	if Global.current_crumb or Global.in_exclusive_ui: return
	if body is CharacterBody3D:
		Global.current_gadget = self
		in_range = true
		if active:
			Global.generic_area_entered.emit()

func _on_body_exited(body: Node3D) -> void:
	if Global.current_gadget == self:
		Global.current_gadget = null
	if body is CharacterBody3D:
		in_range = false
		Global.generic_area_left.emit()
