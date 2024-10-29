class_name CursorArea extends Area3D

func _ready() -> void:
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	collision.shape = shape
	
	add_child(collision)
	input_ray_pickable = false
