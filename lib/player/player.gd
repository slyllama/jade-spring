extends CharacterBody3D

@export var base_speed := 2.0
@export var smoothing := 7.0

@onready var anim: AnimationPlayer = get_node("PlayerMesh/AnimationPlayer")
@onready var engine_bone: BoneAttachment3D = get_node("PlayerMesh/JadeArmature/Skeleton3D/EngineRing1")
var _direction := Vector3.ZERO
var _speed := base_speed
var _target_velocity := Vector3.ZERO

func _ready() -> void:
	Global.camera = $Camera.camera # reference
	$Camera.top_level = true

var _fs = 0 # forward state (if > 0, a 'forward' key (including strafe) is down)
var _blend_target = 1.0
var _blend_state = _blend_target
func _physics_process(delta: float) -> void:
	# Handle animations
	var _query_fs = _fs
	if Input.is_action_just_pressed("move_forward"): _query_fs += 1
	if Input.is_action_just_pressed("move_up"): _query_fs += 1
	if Input.is_action_just_pressed("move_left"): _query_fs += 1
	if Input.is_action_just_pressed("move_right"): _query_fs += 1
	
	if Input.is_action_just_released("move_forward"): _query_fs -= 1
	if Input.is_action_just_released("move_up"): _query_fs -= 1
	if Input.is_action_just_released("move_left"): _query_fs -= 1
	if Input.is_action_just_released("move_right"): _query_fs -= 1
	
	if _query_fs > 0 and _fs == 0:
		_blend_target = -1.0
		#$PlayerMesh/Tree.set(
			#"parameters/test_transition/transition_request", "accelerate")
	elif _query_fs == 0 and _fs > 0:
		_blend_target = 1.0
		#$PlayerMesh/Tree.set(
			#"parameters/test_transition/transition_request", "dance")
	
	if _fs != 0:
		if velocity.length() < 0.1:
			_fs = 0 # reset forward state (for animations) if it gets stuck
	
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
	_target_velocity = _target_velocity.normalized() * Vector3(_speed, _speed * 1.5, _speed)
	
	velocity.x = lerp(velocity.x, _target_velocity.x, smoothing * 0.6 * delta)
	velocity.y = lerp(velocity.y, _target_velocity.y, smoothing * 0.5 * delta)
	velocity.z = lerp(velocity.z, _target_velocity.z, smoothing * delta)
	
	move_and_slide()
	Global.player_position = global_position
	_fs = _query_fs
	
	if _direction.x > 0 or _direction.z != 0:
		$PlayerMesh.rotation.y = lerp(
			$PlayerMesh.rotation.y, $Camera.rotation.y - PI, smoothing * 0.6 * delta)
	$PlayerMesh.rotation.z = lerp(
		$PlayerMesh.rotation.z, _direction.z * 0.4, smoothing * 0.2 * delta)

func _process(delta: float) -> void:
	$Stars.global_position = engine_bone.global_position
	$Camera.global_position.x = global_position.x
	$Camera.global_position.z = global_position.z
	$Camera.global_position.y = lerp(
		$Camera.global_position.y, global_position.y, smoothing * delta)
	$Camera.mouse_in_ui = Global.mouse_in_ui
	
	# TODO: animation tests
	_blend_state = lerp(_blend_state, _blend_target, 2.0 * delta)
	$PlayerMesh/Tree.set("parameters/test_blend/blend_position", _blend_state)
