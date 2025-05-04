extends CanvasLayer
# Fishing
# Minigame to clear bugs, dragonvoid, etc

signal completed
signal canceled

@export var width = 250.0
@export var threshold = 35.0
@export var move_speed = 1.95

@export var fish_min_speed = 1.3
@export var fish_max_speed = 1.95
@export var fish_min_time = 0.65
@export var fish_max_time = 2.7
@export var progress_increase_rate = 0.31
@export var progress_decrease_rate = 0.20

@onready var center_pos = _get_center()

var fish_speed = 0.0
var rng = RandomNumberGenerator.new()
var progress = 39.0
var dir = 1

var fishing_left_down = false
var fishing_right_down = false

var has_started = false
var has_completed = false
var has_succeeded = false

func _set_tutorial_dissolve(val: float) -> void:
	var _e = ease(val, 0.2)
	$BG/CenterMarker/TutorialPanel.material.set_shader_parameter(
		"paint_exponent", 10.0 - _e * 10.0)

func _set_dissolve(val: float):
	var _e = ease(val, 0.2)
	$BG.material.set_shader_parameter("paint_exponent", 10.0 - _e * 10.0)

func _get_x_left() -> float: # get the position of the left end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale - width / 2.0)

func _get_x_right() -> float: # get the position of the right end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale + width / 2.0)

func _get_center() -> Vector2:
	return(Vector2(
		get_window().size.x / 2.0 / Global.retina_scale,
		$BG/CenterMarker.global_position.y))

func end(instant = false):
	if has_completed: return
	has_completed = true
	
	Global.jade_bot_sound.emit()
	Global.tool_mode = Global.TOOL_MODE_NONE
	$BG/CenterMarker/DispulsionFX.anim_out()
	
	if !instant:
		await get_tree().create_timer(0.2).timeout
		var fade_out = create_tween()
		fade_out.tween_method(_set_dissolve, 1.0, 0.0, 0.5)
		var tut_fade_tween = create_tween()
		tut_fade_tween.tween_method(_set_tutorial_dissolve, 1.0, 0.0, 0.5)
		tut_fade_tween.set_parallel()
		await fade_out.finished
	
	Global.in_exclusive_ui = false
	Global.can_move = true
	Global.action_cam_enable.emit()
	if has_succeeded:
		Global.hearts_emit.emit()
		completed.emit()
	else:
		canceled.emit()
	
	Global.player.update_golem_effects()
	queue_free()

func resize() -> void:
	center_pos = _get_center()
	
	$BG/Player.global_position = center_pos
	$BG/Fish.global_position = center_pos

func switch_direction() -> void:
	fish_speed = rng.randf_range(fish_min_speed, fish_max_speed)
	fish_speed *= dir
	dir *= -1 # reverse
	$Timer.wait_time = rng.randf_range(fish_min_time, fish_max_time)
	$Timer.start()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("right_click"):
		_on_tutorial_done()
	if Input.is_action_just_pressed("interact"):
		if $BG/CenterMarker/TutorialPanel.visible and !has_started:
			_on_tutorial_done()

func _ready() -> void:
	$Underlay.queue_free()
	$BG/CenterMarker/TutorialPanel/VBox/Done.disabled = true
	
	Global.skill_button_down.connect(func(id):
		if id == "fishing_left": fishing_left_down = true
		if id == "fishing_right": fishing_right_down = true)
	Global.skill_button_up.connect(func(id):
		if id == "fishing_left": fishing_left_down = false
		if id == "fishing_right": fishing_right_down = false)
	
	_set_dissolve(0.0)
	
	$BG.material.set_shader_parameter("alpha", 1.0)
	var fade_in = create_tween()
	fade_in.tween_method(_set_dissolve, 0.0, 1.0, 0.5)
	var tut_fade_tween = create_tween()
	tut_fade_tween.tween_method(_set_tutorial_dissolve, 0.0, 1.0, 0.5)
	tut_fade_tween.set_parallel()
	
	$BG/TestRect.size.x = progress * 2.53
	
	if Save.data.fishing_tutorial_played: # go straight to gameplay if the tutorial has already played
		$BG/CenterMarker/TutorialPanel.visible = false
		Save.save_to_file()
		has_started = true
	else:
		Save.data.fishing_tutorial_played = true
		for _x in 2: await get_tree().process_frame
		$BG/CenterMarker/TutorialPanel/VBox/Done.disabled = false
		$BG/CenterMarker/TutorialPanel/VBox/Done.grab_focus()
	
	get_window().size_changed.connect(resize)
	Global.fishing_canceled.connect(end)
	
	Global.fishing_started.emit()
	Global.jade_bot_sound.emit()
	Global.in_exclusive_ui = true
	Global.can_move = false
	Global.tool_mode = Global.TOOL_MODE_FISH
	Global.action_cam_disable.emit()
	Global.set_cursor(false)
	
	$BG/CenterMarker/DispulsionFX.anim_in(0.18)
	
	resize()
	switch_direction()

var _d = 0.0
var last_progress = 0.0

func _process(delta: float) -> void:
	last_progress = progress
	if has_completed or !has_started: return
	if _d < 0.45: # short delay before starting
		_d += delta
		return
	
	if Input.is_action_pressed("move_left") or fishing_left_down:
		$BG/Player.global_position.x -= move_speed * delta * 60.0
	elif Input.is_action_pressed("move_right") or fishing_right_down:
		$BG/Player.global_position.x += move_speed * delta * 60.0
	
	$BG/Fish.global_position.x += fish_speed * delta * 60.0
	if $BG/Fish.global_position.x < _get_x_left():
		$BG/Fish.global_position.x += 3.0
		switch_direction()
	elif $BG/Fish.global_position.x > _get_x_right():
		$BG/Fish.global_position.x -= 3.0
		switch_direction()
	
	$BG/Player.global_position.x = clamp(
		$BG/Player.global_position.x, _get_x_left(), _get_x_right())
	
	var diff = abs($BG/Player.global_position.x - $BG/Fish.global_position.x)
	
	var _s = 0.0 # position change
	if diff < threshold: _s = progress_increase_rate
	else: _s = -progress_decrease_rate
	progress += _s * Utilities.critical_lerp(delta, 55.0)
	
	if progress > 99.9:
		has_succeeded = true
		end()
	elif progress < 0.5:
		Global.fishing_canceled.emit()
	$BG/TestRect.size.x = progress * 2.53

func _on_timer_timeout() -> void:
	switch_direction()

func _on_completed() -> void:
	Global.fishing_canceled.emit()

func _on_tutorial_done() -> void:
	if has_started: return # can't click twice
	Global.click_sound.emit()
	has_started = true
	var tut_fade_tween = create_tween()
	tut_fade_tween.tween_method(_set_tutorial_dissolve, 1.0, 0.0, 0.5)
	tut_fade_tween.tween_callback(func():
		$BG/CenterMarker/TutorialPanel.visible = false)
