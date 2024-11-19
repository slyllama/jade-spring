@icon("res://lib/gizmo/icon_gizmo.svg")
class_name GizmoScale extends Node3D

var grabber = PickBox.new()

func _ready() -> void:
	grabber.set_size(Vector3(0.8, 0.5, 0.5))
	grabber.make_ui_component()
	add_child(grabber)
