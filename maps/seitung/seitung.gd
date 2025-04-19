extends "res://lib/map/map.gd"

@onready var toolbox = get_node("HUD/Toolbox")
var y_target = 0.0

func _ready() -> void:
	$Landscape/LandscapeCol.set_collision_layer_value(2, true)
	var _dg = load(
		"res://lib/dispersion_golem/meshes/dispersion_golem.tscn").instantiate()
	$Player.add_child(_dg)
	_dg.position.z -= 0.5
	await get_tree().process_frame
	_dg.queue_free()
	super()
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/time=night":
			$Sky/SunNight.visible = true
			$Sky/Sun.visible = false
			
			$Landscape/Sea.get_active_material(0).set_shader_parameter("primary_color", Color("2c5963"))
			$Landscape/Sea.get_active_material(0).set_shader_parameter("metallic", 0.96)
			$Landscape/Sea.get_active_material(0).set_shader_parameter("normal_strength", 0.3)
			for _n in $Decoration/LightRays.get_children(): _n.visible = false
			update_saturation()
		elif _cmd == "/time=day":
			$Sky/SunNight.visible = false
			$Sky/Sun.visible = true
			
			$Landscape/Sea.get_active_material(0).set_shader_parameter("primary_color", Color("152b30"))
			$Landscape/Sea.get_active_material(0).set_shader_parameter("metallic", 1.0)
			$Landscape/Sea.get_active_material(0).set_shader_parameter("normal_strength", 0.6)
			for _n in $Decoration/LightRays.get_children(): _n.visible = true
			update_saturation()
	)

const OCEAN_Z_MIN = 4.5
const OCEAN_Z_MAX = 10.0

func _process(delta: float) -> void:
	var _player_z = Global.player_position.z
	var _ocean_proximity = clamp((_player_z - OCEAN_Z_MIN) / (OCEAN_Z_MAX - OCEAN_Z_MIN), 0.0, 1.0)
	$Ambience/Ocean.volume_db = linear_to_db(_ocean_proximity * 0.85)
	$Decoration/PlatformInner/Waypoint.rotation.y += delta
