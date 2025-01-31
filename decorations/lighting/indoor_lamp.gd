extends CSGSphere3D

func set_color() -> void:
	var hue = get_parent().rotation_degrees.y / 360.0 * 2.0
	$Light.light_color = Color.from_hsv(abs(hue) + 0.17, 0.35, 0.9)

func set_intensity() -> void:
	$Light.light_energy = get_parent().scale.x

func _set_mesh_visiblity(state = false) -> void:
	set_layer_mask_value(1, state)

func _ready() -> void:
	#set_disable_scale(true)
	await get_tree().process_frame
	set_intensity()
	set_color()
	
	Global.selection_started.connect(_set_mesh_visiblity.bind(true))
	Global.selection_canceled.connect(_set_mesh_visiblity)
	Global.adjustment_applied.connect(_set_mesh_visiblity)
	Global.adjustment_canceled.connect(_set_mesh_visiblity)

func _process(_delta: float) -> void:
	if Global.active_decoration == get_parent():
		set_intensity()
		set_color() 
