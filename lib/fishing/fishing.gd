extends CanvasLayer
# Fishing
# Minigame to clear bugs, dragonvoid, etc

signal completed

@export var move_speed := 90.0
@export var width := 240.0
@export var fish_speed := 150.0
@export var threshold := 30

@onready var center_pos = _get_center()
var rng = RandomNumberGenerator.new()
var progress = 50.0
var dir = 1

func _get_x_left() -> float: # get the position of the left end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale - width / 2.0)

func _get_x_right() -> float: # get the position of the right end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale + width / 2.0)

func _get_center() -> Vector2:
	return(Vector2(
		get_window().size.x / 2.0/ Global.retina_scale,
		$BG/CenterMarker.global_position.y))

func end():
	await get_tree().create_timer(0.2).timeout
	var fade_out = create_tween()
	fade_out.tween_property($BG, "modulate:a", 0.0, 0.4)
	await fade_out.finished
	
	Global.jade_bot_sound.emit()
	Global.in_exclusive_ui = false
	Global.can_move = true
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.adjustment_canceled.emit() # just in case
	completed.emit()
	queue_free()

func resize() -> void:
	center_pos = _get_center()
	
	$BG/Player.global_position = center_pos
	$BG/Fish.global_position = center_pos

func switch_direction() -> void:
	fish_speed = rng.randf_range(50.0, 96.0)
	fish_speed *= dir
	dir *= -1 # reverse
	$Timer.wait_time = rng.randf_range(1.0, 3.0)
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
	if Input.is_action_pressed("move_left"):
		$BG/Player.global_position.x -= move_speed * delta
	elif Input.is_action_pressed("move_right"):
		$BG/Player.global_position.x += move_speed * delta
	
	$BG/Fish.global_position.x += fish_speed * delta
	if $BG/Fish.global_position.x < _get_x_left():
		$BG/Fish.global_position.x += 3
		switch_direction()
	elif $BG/Fish.global_position.x > _get_x_right():
		$BG/Fish.global_position.x -= 3
		switch_direction()
	
	$BG/Player.global_position.x = clamp(
		$BG/Player.global_position.x, _get_x_left(), _get_x_right())
	
	var diff = abs($BG/Player.global_position.x - $BG/Fish.global_position.x)
	if diff < threshold:
		progress += delta * 18
	else:
		progress -= delta * 10
	if progress > 99:
		end()
	progress = clamp(progress, 0.0, 100.0)
	
	$BG/Progress.value = lerp($BG/Progress.value, float(progress), delta * 10)

func _on_timer_timeout() -> void:
	switch_direction()

func _on_completed() -> void:
	Global.fishing_canceled.emit()
