extends Decoration

func _ready() -> void:
	super()
	
	await get_tree().process_frame
	$IndoorLamp/Light.light_energy = scale.x

func _process(_delta: float) -> void:
	if Global.active_decoration == self:
		$IndoorLamp/Light.light_energy = scale.x
