extends Node3D

var spiral_mat: ShaderMaterial
var rng = RandomNumberGenerator.new()
var draw_pass
const EMOTES = [
	preload("res://lib/dispersion_golem/materials/textures/emote_1.png"),
	preload("res://lib/dispersion_golem/materials/textures/emote_2.png"),
	preload("res://lib/dispersion_golem/materials/textures/emote_3.png")
]

func set_shader_pos(val: float) -> void:
	spiral_mat.set_shader_parameter("h_position", val)

func emote() -> void:
	if rng.randf() < 0.25: return
	var _mat: StandardMaterial3D = draw_pass.surface_get_material(0)
	_mat.albedo_texture = EMOTES.pick_random()
	await get_tree().create_timer(rng.randf_range(0.2, 1.5)).timeout
	$Model/Emote.emitting = true

func _ready() -> void:
	visible = false
	spiral_mat = $Spiral/Spiral.get_active_material(0).duplicate()
	$Spiral/Spiral.set_surface_override_material(0, spiral_mat)
	$Model/Tree.libraries = $Model/Tree.libraries.duplicate()
	
	draw_pass = $Model/Emote.draw_pass_1.duplicate(true)
	$Model/Emote.draw_pass_1 = draw_pass
	
	for _n in Utilities.get_all_children(self):
		if _n is MeshInstance3D: # disable all shadows
			_n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	$Model/Tree.set("parameters/proc_appear/active",
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	Global.fishing_started.connect(emote)
	emote()
	
	await get_tree().process_frame
	var spiral_tween = create_tween()
	spiral_tween.tween_method(set_shader_pos, 1.0, -1.0, 1.0)
	visible = true
