extends Decoration

const _mat_exp_ray = preload("res://decorations/light_ray/materials/mat_exp_ray.tres")

func _ready():
	super()
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/time=night": $LightRay.visible = false
		elif _cmd == "/time=day": $LightRay.visible = true)
