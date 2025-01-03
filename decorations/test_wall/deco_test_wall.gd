@tool
extends Decoration

@export var wall_color = Color.MAGENTA:
	get: return(wall_color)
	set(_val):
		if "wall_ornament" in dye_materials:
			set_dye_channel("wall_ornament", _val)
		wall_color = _val

func _ready() -> void:
	assign_dye_channel("wall_ornament")
	set_dye_channel("wall_ornament", wall_color)
	super()
	#for _n in Utilities.get_all_children($Wall):
		#if _n is MeshInstance3D:
			#var _m = _n.get_active_material(0)
			#if _m is StandardMaterial3D:
				#if "ornament" in _m.resource_path:
					#_m.albedo_color = Color(0.299, 0.461, 0.471)
