extends CanvasLayer

func _set_shader_value(val: float) -> void: # 0-1
	var _e = ease(val, 0.2)
	$Base.material.set_shader_parameter("paint_mask_exponent", (1 - _e) * 10)

func open(title = "1. A Helping Hand", description = "Nayos was not easy on us; the force of that Kryptis turret's blast left my plating cracked and my servos crushed and fragmented. Repair and recovery will be a slow process and, as grateful as I am for my jade tech\u00ADnicians, it pains me to be away from the Commander for so long. Though perhaps, as I rehabilitate, I too can help build something meaningful.\n[font_size=9] [/font_size]\n[color=white]Talk to Mr. Scruff about tending to your new Canthan home.[/color]"):
	$Base/Content/Title.text = "[center]" + title + "[/center]"
	$Base/Content/Description.text = description
	
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_shader_value, 0.0, 1.0, 0.27)
	var content_fade_tween = create_tween()
	content_fade_tween.tween_property($Base/Content, "modulate:a", 1.0, 0.27)
	content_fade_tween.set_parallel()
	
	await get_tree().process_frame
	await get_tree().process_frame # wait for command line to process
	Global.in_exclusive_ui = true
	
	await get_tree().create_timer(0.1).timeout
	$JadeWingsBase/JadeAnim.play("float")

func close():
	Global.in_exclusive_ui = false
	
	# Do closing stuff
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_shader_value, 1.0, 0.0, 0.27)
	var content_fade_tween = create_tween()
	content_fade_tween.tween_property($Base/Content, "modulate:a", 0.0, 0.27)
	content_fade_tween.set_parallel()
	$JadeWingsBase/JadeAnim.play_backwards("float")
	
	await fade_tween.finished
	queue_free()

func _ready() -> void:
	$Base/Content.modulate.a = 0.0
	$JadeWingsBase/JadeWings.modulate.a = 0.0
	$JadeWingsBase/JadeWings.position.y = 10.0

func _process(_delta: float) -> void:
	# TODO: test on a retina display
	$JadeWingsBase.global_position = (
		get_window().size / 2.0 * (1.0 / Global.retina_scale) + Vector2(0, -200))
