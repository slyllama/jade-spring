extends CharacterBody3D

const JADE_SOUNDS = [
	preload("res://lib/player/sounds/jade_sound_1.ogg"),
	preload("res://lib/player/sounds/jade_sound_2.ogg"),
	preload("res://lib/player/sounds/jade_sound_3.ogg"),
	preload("res://lib/player/sounds/jade_sound_4.ogg"),
	preload("res://lib/player/sounds/jade_sound_8.ogg"),
	preload("res://lib/player/sounds/jade_sound_5.ogg"),
	preload("res://lib/player/sounds/jade_sound_7.ogg"),
	preload("res://lib/player/sounds/jade_sound_6.ogg")
]

@export var base_speed := 2.0
@export var smoothing := 7.0
var smooth_mod = 1.0 # acceleration smoothing - to be modified by command

@onready var anim: AnimationPlayer = get_node("PlayerMesh/AnimationPlayer")
@onready var engine_bone: BoneAttachment3D = get_node("PlayerMesh/JadeArmature/Skeleton3D/EngineRing1")
var _direction := Vector3.ZERO
var _speed := base_speed
var _target_velocity := Vector3.ZERO
@onready var _initial_y_rotation = global_rotation.y

func play_jade_sound() -> void:
	var rng = RandomNumberGenerator.new()
	var _ind = rng.randi_range(0, JADE_SOUNDS.size() - 1)
	
	var sound = AudioStreamPlayer.new()
	sound.stream = JADE_SOUNDS[_ind]
	sound.volume_db = linear_to_db(0.4)
	sound.pitch_scale = 0.8 + 0.4 * rng.randf()
	add_child(sound)
	
	sound.finished.connect(sound.queue_free)
	sound.play()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_action"):
		$PlayerMesh.visible = !$PlayerMesh.visible

func _ready() -> void:
	$Follower.top_level = true
	
	Global.debug_skill_used.connect(func():
		var _dg = load(
			"res://lib/dispersion_golem/meshes/dispersion_golem.tscn").instantiate()
		$Follower.add_child(_dg)
		_dg.global_position = Global.player_position)
	
	Global.camera = $Camera.camera # reference
	Global.player = self
	
	$Camera.top_level = true
	$Camera.set_cam_rotation(Vector3(-20, 0, 0))
	Global.jade_bot_sound.connect(play_jade_sound)
	
	# Move the player to a new location using global signals
	Global.move_player.connect(func(_pos: Vector3):
		global_position = _pos)
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/hideplayer":
			$PlayerMesh.visible = false
		elif _cmd == "/showplayer":
			$PlayerMesh.visible = true
		elif "/speedratio=" in _cmd:
			var _speed_ratio = float(_cmd.replace("/speedratio=", ""))
			_speed = base_speed * clamp(_speed_ratio, 0.0, 2.0)
		elif "/playersmooth=" in _cmd:
			var _s = float(_cmd.replace("/playersmooth=", ""))
			smooth_mod = clamp(_s, 0.01, 1.0)
	)

var _fs = 0 # forward state (if > 0, a 'forward' key (including strafe) is down)
var _ss = 0 # strafe state
var _blend_target = 1.0
var _strafe_target = 0.0
var _elongate_target = 0.0
var _blend_state = _blend_target
func _physics_process(delta: float) -> void:
	# Handle animations
	var _query_fs = _fs
	var _query_ss = _ss # query strafe state
	if Input.is_action_just_pressed("move_forward"): _query_fs += 1
	#if Input.is_action_just_pressed("move_up"): _query_fs += 1
	#if Input.is_action_just_pressed("move_left"): _query_fs += 1
	#if Input.is_action_just_pressed("move_right"): _query_fs += 1
	
	if Input.is_action_just_released("move_forward"): _query_fs -= 1
	#if Input.is_action_just_released("move_up"): _query_fs -= 1
	#if Input.is_action_just_released("move_left"): _query_fs -= 1
	#if Input.is_action_just_released("move_right"): _query_fs -= 1
	
	if _query_fs > 0 and _fs == 0:
		_blend_target = -1.0
	elif _query_fs == 0 and _fs > 0:
		_blend_target = 1.0
	
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
	Global.camera_basis = _camera_basis
	Global.camera_pivot_rotation_degrees = $Camera.rotation_degrees
	
	# Multiply inputs by the movement vector and orbit rotation
	# This could be improved, but it works
	if Global.can_move:
		_target_velocity = (Vector3.FORWARD * _camera_basis * Vector3(-1, 0, 1) * _direction.x)
		_target_velocity += (Vector3.RIGHT * _camera_basis * Vector3(1, 0, -1) * _direction.z)
		_target_velocity += (Vector3.UP * _camera_basis * Vector3(0, 1, 0) * _direction.y)
		_target_velocity = _target_velocity.normalized() * Vector3(_speed, _speed * 1.5, _speed)
	else: _target_velocity = Vector3.ZERO
	
	velocity.x = lerp(velocity.x, _target_velocity.x, smoothing * 0.6 * delta * smooth_mod)
	velocity.y = lerp(velocity.y, _target_velocity.y, smoothing * 0.5 * delta * smooth_mod)
	velocity.z = lerp(velocity.z, _target_velocity.z, smoothing * delta * smooth_mod)
	
	if !Global.in_walk_mode:
		move_and_slide()
	else:
		if Global.walk_mode_target != null:
			global_position = Global.walk_mode_target.global_position + Vector3(0, 1, 0)
	Global.player_position = global_position
	Global.player_y_rotation = global_rotation.y
	_fs = _query_fs
	
	if Global.can_move:
		#var _b = $PlayerMesh.rotation.y
		#while _b > 0: _b -= deg_to_rad(360.0)
		#var _a = $Camera.rotation.y - PI - _initial_y_rotation
		#while _a > 0: _a -= deg_to_rad(360.0)
		
		if _direction.x > 0 or _direction.z != 0 or Global.in_walk_mode:
			$PlayerMesh.rotation.y = lerp(
				$PlayerMesh.rotation.y,
				$Camera.rotation.y - PI - _initial_y_rotation,
				smoothing * 0.6 * delta)
		$PlayerMesh.rotation.z = lerp(
			$PlayerMesh.rotation.z, _direction.z * 0.4, smoothing * 0.2 * delta)

func _process(delta: float) -> void:
	$Follower.global_position = lerp(
		$Follower.global_position, self.global_position, delta * 2.0)
	
	$PlayerMesh/Stars.global_position = engine_bone.global_position
	$Camera.global_position.x = global_position.x
	$Camera.global_position.z = global_position.z
	$Camera.global_position.y = lerp(
		$Camera.global_position.y, global_position.y, smoothing * delta)
	
	$Camera.popup_open = Global.popup_open
	$Camera.mouse_in_ui = Global.mouse_in_ui
	
	if Global.can_move:
		_blend_state = lerp(_blend_state, _blend_target, 3.7 * delta)
		_strafe_target = lerp(_strafe_target, -_direction.z, 5.2 * delta)
		_elongate_target = lerp(_elongate_target, _direction.y * 1.2, 3.7 * delta)
	else: # gently reset when locking position
		_blend_state = lerp(_blend_state, 0.0, 2.0 * delta)
		_strafe_target = lerp(_strafe_target, 0.0, 2.0 * delta)
		_elongate_target = lerp(_elongate_target, 0.0, 2.0 * delta)
	$PlayerMesh/Tree.set("parameters/test_blend/blend_position", _blend_state)
	$PlayerMesh/Tree.set("parameters/strafe/add_amount", _strafe_target)
	$PlayerMesh/Tree.set("parameters/set_elongate/add_amount", _elongate_target)
	
	var _target_pitch_scale: float = (1.0
		+ Vector3(velocity * Vector3(1, 0, 1)).length() / base_speed * 0.5)
	#if Global.in_exclusive_ui: _target_pitch_scale = 1.0
	$EngineSound.pitch_scale = lerp($EngineSound.pitch_scale, _target_pitch_scale, 0.07)
