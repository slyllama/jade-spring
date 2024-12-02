class_name CursorArea extends Area3D

var collision = CollisionShape3D.new()
var shape = SphereShape3D.new()

func _ready() -> void:
	collision.shape = shape
	
	add_child(collision)
	input_ray_pickable = false
	set_collision_layer_value(4, 0)
	set_collision_mask_value(4, 0)
