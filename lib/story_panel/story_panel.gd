extends CanvasLayer

func _set_shader_value(val: float) -> void: # 0-1
	var _e = ease(val, 0.2)
	$Base.material.set_shader_parameter("paint_mask_exponent", (1 - _e) * 10)

func open():
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_shader_value, 0.0, 1.0, 0.27)
	
	await get_tree().process_frame
	await get_tree().process_frame # wait for command line to process
	Global.in_exclusive_ui = true
	Global.can_move = false
	
	await get_tree().create_timer(0.1).timeout
	$JadeWingsBase/JadeAnim.play("float")

func close():
	Global.in_exclusive_ui = false
	if Global.tool_mode != Global.TOOL_MODE_FISH:
		Global.can_move = true
	
	# Do closing stuff
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_shader_value, 1.0, 0.0, 0.27)
	$JadeWingsBase/JadeAnim.play_backwards("float")
	
	await fade_tween.finished
	queue_free()

func _ready() -> void:
	$JadeWingsBase/JadeWings.modulate.a = 0.0
	$JadeWingsBase/JadeWings.position.y = 10.0

func _process(_delta: float) -> void:
	$JadeWingsBase.global_position = get_window().size / 2.0 + Vector2(0, -200)
