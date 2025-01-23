@tool
extends Decoration

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint(): return
	for _n in Utilities.get_all_children($Model):
		if _n is MeshInstance3D:
			_n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	$Model/Plane_002.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
