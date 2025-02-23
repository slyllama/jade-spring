extends CanvasLayer

signal closed

const PianoKey = preload("res://lib/attenuator/piano_key.tscn")
const notes = [
	{"float": 0.0,  "color": Color.CADET_BLUE},	# C
	{"float": 1.0,  "color": Color.WHITE},		# D
	{"float": 2.1,  "color": Color.WHITE},		# E
	{"float": 2.65,  "color": Color.WHITE},		# F
	{"float": 4.1,  "color": Color.WHITE},		# G
	{"float": 5.5,  "color": Color.WHITE},		# A
	{"float": 7.2,  "color": Color.WHITE},		# B
]
const PILLS_SIZE = 9

var two_oct = notes.duplicate()
var place = 0
var target_track

func _set_paint_exponent(val: float) -> void:
	$Base.material.set_shader_parameter("paint_exponent", val)
	$Base/KeyContainer.material.set_shader_parameter("paint_exponent", val)

func close() -> void:
	await get_tree().process_frame # queue for next frame so settings doesn't open
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
		_n.played.connect(func():
			if place < PILLS_SIZE - 1:
				place += 1
				$Click.play()
			else:
				pass # end of sequence
		)
		$Base/KeyContainer.add_child(_n)
	$DispulsionFX.anim_in()
	$Base/KeyContainer.get_children()[3].assign_track([1, 3, 5]) # TODO: debug
	target_track = $Base/KeyContainer.get_children()[0]
	$Base/Marker.position.x = target_track.pills[0].position.x + 24.0
	
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_exponent, 10.0, 0.0, 0.3)
	
	for _n in $Base/KeyContainer.get_children():
		if "alpha" in _n:
			_n.alpha = 1.0
		await get_tree().create_timer(0.03).timeout

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close()

func _on_close_button_down() -> void:
	close()

func _process(delta: float) -> void:
	$DispulsionFX.position.x = $Base.position.x + $Base.size.x / 2.0
	$DispulsionFX.position.y = $Base.position.y + 140.0
	
	if !target_track: return # not ready yet
	if "pills" in target_track:
		var _target = target_track.pills[place]
		$Base/Marker.position.x = lerp(
			$Base/Marker.position.x, _target.position.x + 78.0, delta * 20.0)
