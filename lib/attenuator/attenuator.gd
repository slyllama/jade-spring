extends CanvasLayer

const PianoKey = preload("res://lib/attenuator/piano_key.tscn")
signal closed

const notes = [
	{"float": 0.0,  "color": Color.CADET_BLUE},	# C
	{"float": 0.5,  "color": Color.BLACK},		# C#
	{"float": 1.0,  "color": Color.WHITE},		# D
	{"float": 1.5,  "color": Color.BLACK},		# D#
	{"float": 2.1,  "color": Color.WHITE},		# E
	{"float": 2.65,  "color": Color.WHITE},		# F
	{"float": 3.5,  "color": Color.BLACK},		# F#
	{"float": 4.1,  "color": Color.WHITE},		# G
	{"float": 5.0,  "color": Color.BLACK},		# G#
	{"float": 5.5,  "color": Color.WHITE},		# A
	{"float": 6.5,  "color": Color.BLACK},		# Bb
	{"float": 7.2,  "color": Color.WHITE},		# B
]

var two_oct = notes.duplicate()

func _ready() -> void:
	Global.target_music_ratio = 0.0
	
	Global.can_move = false
	Global.in_exclusive_ui = true
	Global.action_cam_disable.emit()
	Global.tool_mode = Global.TOOL_MODE_FISH
	
	for _i in notes:
		two_oct.append({"float": _i.float * 2.0 + 8.0, "color": _i.color})
	two_oct.append({"float": notes[0].float * 4.0 + 24.0, "color": notes[0].color})
	
	for _i in two_oct:
		var _n = PianoKey.instantiate()
		_n.pitch = 1.0 + _i.float * (1.0 / 8.0)
		_n.modulate = _i.color
		if _n.modulate == Color.BLACK:
			_n.custom_minimum_size.x /= 2.0
			_n.custom_minimum_size.y /=1.1
		$DebugTitle/KeyConrainer.add_child(_n)
	$DebugTitle/DispulsionFX.anim_in()

func _on_close_button_down() -> void:
	Global.target_music_ratio = 1.0
	
	Global.can_move = true
	Global.in_exclusive_ui = false
	Global.tool_mode = Global.TOOL_MODE_NONE
	closed.emit()
	queue_free()
