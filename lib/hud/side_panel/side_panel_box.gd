@tool
extends VBoxContainer

@export var title = "((Title))":
	get:
		return(title)
	set(_v):
		title = _v
		set_title(_v)
@export var description = "((Description))":
	get:
		return(description)
	set(_v):
		description = _v
		set_description(_v)

func set_title(get_text: String) -> void:
	$Title.text = get_text

func set_description(get_text: String) -> void:
	$Text.text = get_text

func _ready() -> void:
	set_title(title)
	set_description(description)
