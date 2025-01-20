extends RichTextLabel
# Version
# Display the game's version number

const Version = preload("res://version.gd")
@export var align_right = false

func _display_version() -> void:
	var _str = "v" + Version.VER
	if align_right: text = "[right]" + _str + "[/right]"
	else: text = _str

func _ready() -> void:
	_display_version()
