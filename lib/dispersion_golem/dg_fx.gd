extends Node3D

const DispersionGolem = preload("res://lib/dispersion_golem/meshes/dispersion_golem.tscn")
@export_range(1, 3 ,1) var amount: int = 1

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true
	
	for i in amount:
		var _n = Node3D.new()
		_n.rotation_degrees.y = 120.0 * i
		add_child(_n)
		
		var _d = DispersionGolem.instantiate()
		_d.position.x = 0.55
		_d.position.y = rng.randf_range(-0.3, 0.3)
		_n.add_child(_d)
		
		await get_tree().create_timer(0.1).timeout

func _physics_process(delta: float) -> void:
	global_position = lerp(
		global_position, get_parent().global_position, delta * 4.0)
