@tool
extends Node3D

@export var duration = 0.5
@export_range(0.0, 1.0) var min_strength = 0.5
@export_range(0.0, 1.0) var max_strength = 1.0
var direction = false

func set_emission(val: float) -> void:
	$FrontEmission.get_active_material(0).emission_energy_multiplier = val

func glow():
	direction = !direction
	if !direction:
		var _t = create_tween()
		_t.tween_method(set_emission, min_strength, max_strength, duration)
		_t.tween_callback(glow)
	else:
		var _t = create_tween()
		_t.tween_method(set_emission, max_strength, min_strength, duration)
		_t.tween_callback(glow)

func _ready():
	glow()
