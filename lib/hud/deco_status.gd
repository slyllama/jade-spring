extends Label

func _ready() -> void:
	Global.deco_load_status_updated.connect(func(status: String):
		text = status)
