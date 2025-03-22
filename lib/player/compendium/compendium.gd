@tool
extends Node3D

@onready var anim: AnimationPlayer = $Compendium/AnimationPlayer
@onready var mat_cover: ShaderMaterial = $Compendium/BookSkeleton/Skeleton3D/CornerPiece/CornerPiece.get_active_material(0)
@onready var mat_page: ShaderMaterial = $Compendium/BookSkeleton/Skeleton3D/Cube_001/Cube_001.get_active_material(0)

func _set_dissolve_value(value: float) -> void:
	mat_cover.set_shader_parameter("dissolveSlider", value)
	mat_page.set_shader_parameter("dissolveSlider", value)

@export var open_compendium = false:
	get: return(open_compendium)
	set(_value):
		open_compendium = false
		open()

func _ready() -> void:
	if !Engine.is_editor_hint():
		open()
	else:
		anim.play("float")

func open() -> void:
	var dissolve_tween = create_tween()
	dissolve_tween.tween_method(_set_dissolve_value, 1.0, 0.0, 0.8)
	
	anim.play("open")
	anim.set_blend_time("open", "float", 0.6)
	await dissolve_tween.finished
	anim.play("float")
	
	await get_tree().create_timer(2.0).timeout
	close()

func close() -> void:
	anim.set_blend_time("float", "open", 0.2)
	anim.play_backwards("float")
	
	var dissolve_tween = create_tween()
	dissolve_tween.tween_method(_set_dissolve_value, 0.0, 1.0, 0.8)
	
	await get_tree().create_timer(1.0).timeout
	open()
