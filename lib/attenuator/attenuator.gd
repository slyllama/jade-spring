extends CanvasLayer

const PianoKey = preload("res://lib/attenuator/piano_key.tscn")
signal closed

const notes = [
	{"float": 0.0,  "color": Color.CADET_BLUE},	# C
	{"float": 1.0,  "color": Color.WHITE},		# D
	{"float": 2.1,  "color": Color.WHITE},		# E
	{"float": 2.65,  "color": Color.WHITE},		# F
	{"float": 4.1,  "color": Color.WHITE},		# G
	{"float": 5.5,  "color": Color.WHITE},		# A
	{"float": 7.2,  "color": Color.WHITE},		# B
]

var two_oct = notes.duplicate()

func _set_paint_exponent(val: float) -> void:
	$DebugTitle/KeyContainer.material.set_shader_parameter("paint_exponent", val)

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
		#if _n.modulate == Color.BLACK:
			#_n.custom_minimum_size.x /= 2.0
			#_n.custom_minimum_size.y /=1.1
		$DebugTitle/KeyContainer.add_child(_n)
	$DispulsionFX.anim_in()
	
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_exponent, 10.0, 0.0, 0.3)

func _on_close_button_down() -> void:
	Global.target_music_ratio = 1.0
	
	Global.can_move = true
	Global.in_exclusive_ui = false
	Global.tool_mode = Global.TOOL_MODE_NONE
	closed.emit()
	
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_exponent, 0.0, 10.0, 0.2)
	$DispulsionFX.anim_out()
	await $DispulsionFX.anim_out_complete
	
	queue_free()

func _process(_delta: float) -> void:
	$DispulsionFX.position = get_window().size / 2.0 / Global.retina_scale
