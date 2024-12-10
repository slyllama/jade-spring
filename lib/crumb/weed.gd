@tool
extends Crumb

func _ready() -> void:
	super()
	body_entered.connect(func(body):
		if body is CharacterBody3D:
			Global.weed_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if body is CharacterBody3D:
			Global.weed_crumb_left.emit())

func interact() -> void:
	Global.add_qty_effect("weed")
	Global.announcement_sent.emit("((Weed picked))")
	queue_free()
