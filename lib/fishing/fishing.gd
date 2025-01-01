extends CanvasLayer
# Fishing
# Minigame to clear bugs, dragonvoid, etc

signal completed
signal canceled

@export var width := 240.0
@export var threshold := 30.0
@export var move_speed := 1.5

@export var fish_min_speed := 1.3
@export var fish_max_speed := 1.95
@export var fish_min_time := 0.55
@export var fish_max_time := 2.7
@export var progress_increase_rate := 0.24
@export var progress_decrease_rate := 0.19

@onready var center_pos = _get_center()

var fish_speed = 0.0
var rng = RandomNumberGenerator.new()
var progress = 50.0
var dir = 1
var has_completed = false
var has_succeeded = false

func _get_x_left() -> float: # get the position of the left end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale - width / 2.0)

func _get_x_right() -> float: # get the position of the right end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale + width / 2.0)

func _get_center() -> Vector2:
	return(Vector2(
		get_window().size.x / 2.0 / Global.retina_scale,
		$BG/CenterMarker.global_position.y))

func end():
	if has_completed: return
	has_completed = true
	
	#Global.remove_effect.emit("discombobulator")
	Global.jade_bot_sound.emit()
	Global.tool_mode = Global.TOOL_MODE_NONE
	
	await get_tree().create_timer(0.2).timeout
	var fade_out = create_tween()
	fade_out.tween_property($BG, "modulate:a", 0.0, 0.4)
	await fade_out.finished
	
	Global.in_exclusive_ui = false
	Global.can_move = true
	if has_succeeded:
		completed.emit()
	else:
		canceled.emit()
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

func _ready() -> void:
	$BG.modulate.a = 0
	var fade_in = create_tween()
	fade_in.tween_property($BG, "modulate:a", 1.0, 0.2)
	
	get_window().size_changed.connect(resize)
	Global.fishing_canceled.connect(end)
	
	Global.fishing_started.emit()
	Global.jade_bot_sound.emit()
	Global.in_exclusive_ui = true
	Global.can_move = false
	Global.tool_mode = Global.TOOL_MODE_FISH
	Global.set_cursor(false)
	
	resize()
	switch_direction()
	$BG/Progress.value = progress

func _process(delta: float) -> void:
	if has_completed: return
	
	if Input.is_action_pressed("move_left"):
		$BG/Player.global_position.x -= move_speed * delta * 60.0
	elif Input.is_action_pressed("move_right"):
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
	progress += _s
	
	if progress > 99.5:
		has_succeeded = true
		end()
	progress = clamp(progress, 0.0, 100.0)
	
	$BG/Progress.value = lerp($BG/Progress.value, float(progress), delta * 40)

func _on_timer_timeout() -> void:
	switch_direction()

func _on_completed() -> void:
	Global.fishing_canceled.emit()
