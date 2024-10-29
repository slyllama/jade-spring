@tool
class_name Crumb extends Area3D

func _ready() -> void:
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	collision.shape = shape
	add_child(collision)
	
	area_entered.connect(func(area):
		print(area))
