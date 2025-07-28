extends "res://lib/map/map.gd"

@onready var toolbox = get_node("HUD/Toolbox")
var y_target = 0.0
var last_time = Global.time_of_day

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
		elif _cmd == "/rotatesun":
			if Global.time_of_day == "day": $Sky/Sun.global_rotation_degrees.y += 33.0
			else: $Sky/SunNight.global_rotation_degrees.y += 33.0
		elif _cmd == "/vault":
			Global.hud.fade_out()
			await Global.hud.fade_out_complete
			
			Global.command_sent.emit("/time=night")
			$BuildVault.visible = true
			$Player.global_position = $BuildVault.global_position + Vector3(0, 1, 1.6)
			$Player.get_node("PlayerMesh").rotation_degrees.y = 180.0
			$Player.get_node("Camera").set_initial_cam_rotation(Vector3(0, 0, 0))
			$Player.global_rotation_degrees.y = 0.0
			
			await get_tree().create_timer(0.5).timeout
			Global.hud.fade_in()
	)

const OCEAN_Z_MIN = 4.5
const OCEAN_Z_MAX = 10.0

func _process(delta: float) -> void:
	var _player_z = Global.player_position.z
	var _ocean_proximity = clamp((_player_z - OCEAN_Z_MIN) / (OCEAN_Z_MAX - OCEAN_Z_MIN), 0.0, 1.0)
	$Ambience/Ocean.volume_db = linear_to_db(_ocean_proximity * 0.85)
	$Decoration/PlatformInner/Waypoint.rotation.y += delta
