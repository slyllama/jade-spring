extends Node3D

func _ready() -> void:
	for _n in Utilities.get_all_children(self):
		if _n is MeshInstance3D: # disable all shadows
			_n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	$Model/Tree.set("parameters/proc_appear/active",
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
