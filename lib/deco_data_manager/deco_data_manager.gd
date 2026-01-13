@tool
extends Window


func _init() -> void:
	if !Engine.is_editor_hint():
		visible = false

func _ready() -> void:
	get_window().size = Vector2i(300, 600)
	get_window().title = "Decoration Data Manager"
	
	if Engine.is_editor_hint(): return
	get_window().position = (DisplayServer.screen_get_position()
		+ Vector2i(30, 60))
