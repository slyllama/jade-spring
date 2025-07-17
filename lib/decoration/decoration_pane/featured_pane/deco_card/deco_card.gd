@tool
extends Panel

@export var title: String = "((Untitled))"
@export var id: String = ""
@export var image: Texture2D
@export_tool_button("Update Preview") var update_button = update

func update() -> void:
	$Title.text = title
	$Image.texture = image

func _init() -> void:
	modulate.a = 0.9

func _ready() -> void:
	update()

func _on_mouse_entered() -> void: modulate.a = 1.2
func _on_mouse_exited() -> void: modulate.a = 0.9
