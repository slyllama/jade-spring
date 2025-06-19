@tool
extends Decoration

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
