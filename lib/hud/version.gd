extends RichTextLabel
# Version
# Display the game's version number

const Flash = preload("res://lib/flash/flash.tscn")
@export var align_right = false
@export var show_updates = true

func _display_version(newer_version: String = Version.VER) -> void:
	var _str = "v" + Version.VER
	if newer_version != Version.VER:
		_str += " [color=#cba23b](v" + newer_version + " available)[/color]"
		var _f = Flash.instantiate()
		if align_right:
			_f.position.x += size.x
		add_child(_f)
	if align_right: text = "[right]" + _str + "[/right]"
	else: text = _str

func _ready() -> void:
	gui_input.connect(func(_event):
		if Input.is_action_just_pressed("left_click"):
			OS.shell_open("https://slyllama.net/jade-spring"))
	Version.latest_version_retrieved.connect(func(latest_version):
		if show_updates:
			_display_version(latest_version))
	_display_version()
