extends Node2D

var active = false

# Set shader values on a scale of 0-1 with easings
func _set_val(val: float, node: Sprite2D) -> void:
	if active: return
	var _mat = node.material
	_mat.set_shader_parameter("paint_mask_exponent", 0.1 + (1 - ease(val, 0.25)) * 9.9)
	_mat.set_shader_parameter("value", ease(val, 2.0))
	_mat.get_shader_parameter("paint_mask_gradient").fill_to.x = val
	_mat.get_shader_parameter("paint_mask_gradient").fill_from.x = val * 0.5 + 0.5

func _ready() -> void:
	# Duplicate shaders so that their functionality is independent
	# Set initial visibilities and shader configurations
	$Words1.material = $Words1.material.duplicate(true)
	$Words2.material = $Words2.material.duplicate(true)
	$Words1.visible = false
	$Words2.visible = false
	
	$JadeBotRoot/Anim.play("RESET")
	
	_set_val(0.0, $Words1)
	_set_val(0.0, $Words2)
	
	# Start delay
	$StartDelay.start()
	await $StartDelay.timeout
	$Words1.visible = true
	$Words2.visible = true
	
	# Handle animations
	var words_1_tween = create_tween()
	words_1_tween.tween_method(
		_set_val.bind($Words1), 0.0, 1.0, 0.9
	).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.25).timeout
	
	$Dust.emitting = true
	$ClipBase/ClipMotes.emitting = true
	$JadeBotRoot/Anim.play("Float")
	
	var words_2_tween = create_tween()
	words_2_tween.tween_method(
		_set_val.bind($Words2), 0.0, 1.0, 0.94
	).set_ease(Tween.EASE_OUT)
