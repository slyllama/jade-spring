extends CSGSphere3D

func set_color(custom_rotation_degrees = null) -> void:
	var hue = get_parent().rotation_degrees.y / 360.0 * 2.0
	$Light.light_color = Color.from_hsv(abs(hue) + 0.17, 0.35, 0.9)

func set_intensity() -> void:
	$Light.light_energy = get_parent().scale.x

func _ready() -> void:
	set_disable_scale(true)
	await get_tree().process_frame
	set_intensity()
	set_color()

func _process(delta: float) -> void:
	if Global.active_decoration == get_parent():
		set_intensity()
		set_color() 
