extends RichTextLabel
# Version
# Display the game's version number

const Flash = preload("res://lib/flash/flash.tscn")
@export var align_right = false
@export var show_updates = true
var updated = false

func _display_version(newer_version: Dictionary = {"release": Version.VER, "prerelease": "1.999b"}) -> void:
	var _prefix = "v" + Version.VER
	var _str
	
	if Version.VER != newer_version["release"]:
		_str = _prefix + " [color=#cba23b](v" + newer_version["release"] + " available)[/color]"
		var _f = Flash.instantiate()
		if align_right:
			_f.position.x += size.x
		add_child(_f)
	else: _str = _prefix
	if Version.VER == newer_version["prerelease"]:
		_str = _prefix + " [color=#abd141](pre-release)[/color]"
	
	if align_right: text = "[right]" + _str + "[/right]"
	else: text = _str

func _init() -> void:
	text = ""

func _ready() -> void:
	gui_input.connect(func(_event):
		if Input.is_action_just_pressed("left_click"):
			if _c <= 0.0:
				_c = 0.3
				OS.shell_open("https://slyllama.net/jade-spring"))
	Version.latest_version_retrieved.connect(func(latest_version):
		if show_updates and !updated:
			updated = true
			_display_version(latest_version))
	
	if show_updates:
		Version.request_latest_version()
	else: _display_version()

var _c = 0.0
func _process(delta: float) -> void:
	if _c > 0.0: _c -= delta
