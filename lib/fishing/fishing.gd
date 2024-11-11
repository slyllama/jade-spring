extends CanvasLayer
# Fishing
# Minigame to clear bugs, dragonvoid, etc

signal completed

@export var move_speed := 90.0
@export var width := 240.0
@export var fish_speed := 150.0
@export var threshold := 30

@onready var center_pos = get_window().size / 2.0
var rng = RandomNumberGenerator.new()
var progress = 50.0
var dir = 1

func _get_x_left() -> float: # get the position of the left end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale - width / 2.0)

func _get_x_right() -> float: # get the position of the right end of the bar
	return(get_window().size.x / 2.0 / Global.retina_scale + width / 2.0)

func end():
	Global.jade_bot_sound.emit()
	Global.in_exclusive_ui = false
	Global.can_move = true
	Global.tool_mode = Global.TOOL_MODE_NONE
	queue_free()

func resize() -> void:
	center_pos = get_window().size / 2.0 / Global.retina_scale
	
	$Player.position = center_pos
	$Fish.position = center_pos
	$Base.size.x = width
	$Base.position.x = center_pos.x - width / 2.0

func switch_direction() -> void:
	fish_speed = rng.randf_range(50.0, 96.0)
	fish_speed *= dir
	dir *= -1 # reverse
	$Timer.wait_time = rng.randf_range(1.0, 3.0)
	$Timer.start()

func _ready() -> void:
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
	$Progress.value = progress

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		$Player.position.x -= move_speed * delta
	elif Input.is_action_pressed("move_right"):
		$Player.position.x += move_speed * delta
	
	$Fish.position.x += fish_speed * delta
	if $Fish.position.x < _get_x_left():
		$Fish.position.x += 3
		switch_direction()
	elif $Fish.position.x > _get_x_right():
		$Fish.position.x -= 3
		switch_direction()
	
	$Player.position.x = clamp(
		$Player.position.x, _get_x_left(), _get_x_right())
	
	var diff = abs($Player.position.x - $Fish.position.x)
	if diff < threshold:
		progress += delta * 18
	else:
		progress -= delta * 10
	if progress > 99:
		completed.emit()
	progress = clamp(progress, 0.0, 100.0)
	
	$Progress.value = lerp($Progress.value, float(progress), delta * 10)

func _on_timer_timeout() -> void:
	switch_direction()

func _on_completed() -> void:
	Global.fishing_canceled.emit()
