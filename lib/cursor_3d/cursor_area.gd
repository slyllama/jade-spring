class_name CursorArea extends Area3D

var collision = CollisionShape3D.new()
var shape = SphereShape3D.new()

func _ready() -> void:
	collision.shape = shape
	
	add_child(collision)
	input_ray_pickable = false
