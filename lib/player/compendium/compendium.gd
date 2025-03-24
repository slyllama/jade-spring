@tool
extends Node3D

@onready var anim: AnimationPlayer = $Compendium/AnimationPlayer
@onready var mat_cover: ShaderMaterial = $Compendium/BookSkeleton/Skeleton3D/CornerPiece/CornerPiece.get_active_material(0)
@onready var mat_page: ShaderMaterial = $Compendium/BookSkeleton/Skeleton3D/Cube_001/Cube_001.get_active_material(0)

var is_open = false
var _target_rune_scale = 0.0

func _set_dissolve_value(value: float) -> void:
	mat_cover.set_shader_parameter("dissolveSlider", value)
	mat_page.set_shader_parameter("dissolveSlider", value)

@export var open_compendium = false:
	get: return(open_compendium)
	set(_value):
		open_compendium = false
		open()

func _ready() -> void:
	$Rune.top_level = true
	if Engine.is_editor_hint(): return
	
	Global.adjustment_started.connect(open)
	Global.deco_placement_started.connect(open)
	Global.deco_deletion_started.connect(open)
	
	Global.adjustment_canceled.connect(close)
	Global.adjustment_applied.connect(close)
	Global.deco_placement_canceled.connect(close)
	Global.deco_deletion_canceled.connect(close)
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/togglebook":
			if is_open: close()
			else: open())
	
	if Engine.is_editor_hint():
		anim.play("float")
	else:
		visible = false

func open() -> void:
	is_open = true
	_target_rune_scale = 1.0
	if !visible:
		visible = true
	
	$Stars.emitting = true
	var dissolve_tween = create_tween()
	dissolve_tween.tween_method(_set_dissolve_value, 1.0, 0.0, 0.8)
	
	anim.play("open")
	anim.set_blend_time("open", "float", 0.6)
	await dissolve_tween.finished
	anim.play("float")

func close() -> void:
	_target_rune_scale = 0.0
	is_open = false
	
	$Stars.emitting = false
	anim.set_blend_time("float", "open", 0.2)
	anim.play_backwards("float")
	
	var dissolve_tween = create_tween()
	dissolve_tween.tween_method(_set_dissolve_value, 0.0, 1.0, 0.8)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	$Rune.scale = lerp(
		$Rune.scale,
		Vector3(_target_rune_scale, _target_rune_scale, _target_rune_scale),
		Utilities.critical_lerp(delta, 10.0))
	
	$Rune.global_rotation.x = 0.0
	$Rune.global_rotation.z = 0.0
	$Rune.global_rotation.y += delta * 1.0
	$Rune.global_position = lerp(
		$Rune.global_position, $Compendium/OffsetAnchor.global_position, Utilities.critical_lerp(delta, 25.0))
