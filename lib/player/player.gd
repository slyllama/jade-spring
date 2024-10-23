extends CharacterBody3D

@export var base_speed := 2.0
@export var smoothing := 7.0

var _direction := Vector3.ZERO
var _speed := base_speed
var _target_velocity := Vector3.ZERO

func _ready() -> void:
	Global.camera = $Camera.camera # reference
	$Camera.top_level = true
	
	$PlayerMesh/AnimationPlayer.play("dance")

func _physics_process(delta: float) -> void:
	# Process inputs
	if Input.is_action_pressed("move_forward"): _direction.x = 1
	elif Input.is_action_pressed("move_back"): _direction.x = -1
	else: _direction.x = 0
	
	if Input.is_action_pressed("move_right"): _direction.z = 1
	elif Input.is_action_pressed("move_left"): _direction.z = -1
	else: _direction.z = 0
	
	if Input.is_action_pressed("move_up"): _direction.y = 1
	elif Input.is_action_pressed("move_down"): _direction.y = -1
	else: _direction.y = 0
	
	var _camera_direction = $Camera.rotation_degrees.y
	var _camera_basis = $Camera.global_transform.basis
	
	# Multiply inputs by the movement vector and orbit rotation
	# This could be improved, but it works
	_target_velocity = (Vector3.FORWARD * _camera_basis * Vector3(-1, 0, 1) * _direction.x)
	_target_velocity += (Vector3.RIGHT * _camera_basis * Vector3(1, 0, -1) * _direction.z)
	_target_velocity += (Vector3.UP * _camera_basis * Vector3(0, 1, 0) * _direction.y)
	_target_velocity = _target_velocity.normalized() * _speed
	
	velocity.x = lerp(velocity.x, _target_velocity.x, smoothing * 0.6 * delta)
	velocity.y = lerp(velocity.y, _target_velocity.y, smoothing * 0.5 * delta)
	velocity.z = lerp(velocity.z, _target_velocity.z, smoothing * delta)
	move_and_slide()
	
	if _direction.length() > 0:
		$PlayerMesh.rotation.y = lerp(
			$PlayerMesh.rotation.y, $Camera.rotation.y - PI, smoothing * delta)
	$PlayerMesh.rotation.x = lerp(
		$PlayerMesh.rotation.x, _direction.x * -0.2, smoothing * 0.4 * delta)
	$PlayerMesh.rotation.z = lerp(
		$PlayerMesh.rotation.z, _direction.z * -0.2, smoothing * 0.4 * delta)

func _process(delta: float) -> void:
	$Camera.global_position.x = global_position.x
	$Camera.global_position.z = global_position.z
	$Camera.global_position.y = lerp(
		$Camera.global_position.y, global_position.y, smoothing * delta)
	
	$Camera.mouse_in_ui = Global.mouse_in_ui
