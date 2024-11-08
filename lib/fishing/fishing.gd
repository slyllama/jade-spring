extends CanvasLayer
# Fishing
# Minigame to clear bugs, dragonvoid, etc

@export var move_speed := 150.0
@export var width := 200.0

func _ready() -> void:
	Global.in_exclusive_ui = true
	$Player.position = get_window().size / 2.0
	
	$Base.size.x = width
	$Base.position.x = get_window().size.x / 2.0 - width / 2.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		$Player.position.x -= move_speed * delta
	elif Input.is_action_pressed("move_right"):
		$Player.position.x += move_speed * delta
	
	$Player.position.x = clamp(
		$Player.position.x,
		get_window().size.x / 2.0 - width / 2.0,
		get_window().size.x / 2.0 + width / 2.0)
