extends CanvasLayer
# Fishing
# Minigame to clear bugs, dragonvoid, etc

@export var move_speed := 90.0
@export var width := 240.0
@export var fish_speed := 150.0

@onready var center_pos = get_window().size / 2.0
var rng = RandomNumberGenerator.new()
var dir = 1

func resize() -> void:
	center_pos = get_window().size / 2.0
	
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
	Global.in_exclusive_ui = true
	get_window().size_changed.connect(resize)
	
	resize()
	switch_direction()

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		$Player.position.x -= move_speed * delta
	elif Input.is_action_pressed("move_right"):
		$Player.position.x += move_speed * delta
	
	$Fish.position.x += fish_speed * delta
	if $Fish.position.x < get_window().size.x / 2.0 - width / 2.0:
		$Fish.position.x += 3
		switch_direction()
	elif $Fish.position.x > get_window().size.x / 2.0 + width / 2.0:
		$Fish.position.x -= 3
		switch_direction()
	
	$Player.position.x = clamp(
		$Player.position.x,
		get_window().size.x / 2.0 - width / 2.0,
		get_window().size.x / 2.0 + width / 2.0)

func _on_timer_timeout() -> void:
	switch_direction()
