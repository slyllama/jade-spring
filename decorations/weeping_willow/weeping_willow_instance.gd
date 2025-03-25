@tool
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _m: MeshInstance3D in $Leaves.get_children():
		_m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
