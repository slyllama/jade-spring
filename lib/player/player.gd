extends CharacterBody3D

const JADE_SOUNDS = [
	preload("res://lib/player/sounds/jade_sound_1.ogg"),
	preload("res://lib/player/sounds/jade_sound_2.ogg"),
	preload("res://lib/player/sounds/jade_sound_3.ogg"),
	preload("res://lib/player/sounds/jade_sound_4.ogg"),
	preload("res://lib/player/sounds/jade_sound_8.ogg"),
	preload("res://lib/player/sounds/jade_sound_5.ogg"),
	preload("res://lib/player/sounds/jade_sound_7.ogg"),
	preload("res://lib/player/sounds/jade_sound_6.ogg"),
	preload("res://lib/player/sounds/jade_sound_9.ogg"),
	preload("res://lib/player/sounds/jade_sound_10.ogg"),
	preload("res://lib/player/sounds/jade_sound_11.ogg"),
	preload("res://lib/player/sounds/jade_sound_12.ogg"),
	preload("res://lib/player/sounds/jade_sound_13.ogg"),
	preload("res://lib/player/sounds/jade_sound_14.ogg"),
	preload("res://lib/player/sounds/jade_sound_15.ogg"),
	preload("res://lib/player/sounds/jade_sound_16.ogg"),
	preload("res://lib/player/sounds/jade_sound_17.ogg"),
	preload("res://lib/player/sounds/jade_sound_18.ogg"),
	preload("res://lib/player/sounds/jade_sound_19.ogg"),
]

@onready var SPRINT_SOUNDS = [
	load("res://lib/player/sounds/jade_sprint_1.ogg"),
	load("res://lib/player/sounds/jade_sprint_2.ogg"),
	load("res://lib/player/sounds/jade_sprint_4.ogg"),
	load("res://lib/player/sounds/jade_sprint_5.ogg")
]

const DgFX = preload("res://lib/dispersion_golem/dg_fx.tscn")
var can_play_sprint_sound = true
var rng = RandomNumberGenerator.new()

@export var base_speed: float = 3.0
@export var smoothing: float = 7.0
var smooth_mod = 1.0 # acceleration smoothing - to be modified by command
var walking = false

@onready var anim: AnimationPlayer = get_node("PlayerMesh/AnimationPlayer")
@onready var engine_bone: BoneAttachment3D = get_node("PlayerMesh/JadeArmature/Skeleton3D/EngineRing1")
@onready var _initial_y_rotation = global_rotation.y
var _direction := Vector3.ZERO
var _calculated_speed := base_speed
var _speed := _calculated_speed
var _sprint_multiplier := 1.0
var _target_velocity := Vector3.ZERO

const LOOK_UP_DEADZONE = 10.0 # player will begin going up after this point
const LOOK_DOWN_DEADZONE = -26.0 # player will begin going down after this point
const LOOK_CLAMP = 10.0 # vertical movement derived from camera rotation won't increase past this rate
const LOOK_UP_SENSITIVITY = 0.1 # multiplier
const LOOK_DOWN_SENSITIVITY = 0.06 # multiplier

func play_jade_sound() -> void:
	var _ind = rng.randi_range(0, JADE_SOUNDS.size() - 1)
	
	var sound = AudioStreamPlayer.new()
	sound.stream = JADE_SOUNDS[_ind]
	if _ind >= 9: # accomodate different recording conditions
		sound.volume_db = linear_to_db(0.54)
	else:
		sound.volume_db = linear_to_db(0.4)
	sound.pitch_scale = 0.8 + 0.4 * rng.randf()
	if Global.miniature:
		sound.pitch_scale += 0.3
	add_child(sound)
	
	sound.finished.connect(sound.queue_free)
	sound.play()

func spawn_dgolems() -> void:
	clear_dgolems()
	var _d = DgFX.instantiate()
	_d.amount = 3
	add_child(_d)

func clear_dgolems() -> void:
	for _n in get_children():
		if "amount" in _n:
			_n.queue_free()

func update_golem_effects() -> void:
	if Utilities.has_dv_charge() or Global.get_effect_qty("discombobulator_qty") > 0:
		spawn_dgolems()
	else: clear_dgolems()

var hearts_playing = false
func play_hearts() -> void:
	if !$PlayerMesh/HeartParticles.visible:
		$PlayerMesh/HeartParticles.visible = true
	
	hearts_playing = true
	$PlayerMesh/HeartParticles.emitting = true
	$HeartTimer.start()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_action"):
		if !Global.debug_allowed: return
		$PlayerMesh.visible = !$PlayerMesh.visible
	
	if Input.is_action_just_pressed("sprint"):
		if can_play_sprint_sound and velocity.length() > 0.0:
			can_play_sprint_sound = false
			$SprintSoundCD.start()
			$SprintSoundPlayer.stream = SPRINT_SOUNDS.pick_random()
			if Global.miniature: $SprintSoundPlayer.pitch_scale = 1.3
			else: $SprintSoundPlayer.pitch_scale = 1.0
			$SprintSoundPlayer.play()

var gift_state = false

func toggle_gift_visibility(state: bool) -> void:
	gift_state = state
	$PlayerMesh/JadeArmature/Skeleton3D/PlushBase.visible = state
	$PlayerMesh/JadeArmature/Skeleton3D/PlushBorder.visible = state
	$PlayerMesh/JadeArmature/Skeleton3D/PlushEars.visible = state
	$PlayerMesh/JadeArmature/Skeleton3D/PlushSides.visible = state
	$PlayerMesh/JadeArmature/Skeleton3D/PlushTail.visible = state

func _ready() -> void:
	$PlayerMesh/Karma.animate_out()
	
	SPRINT_SOUNDS.append_array(JADE_SOUNDS)
	toggle_gift_visibility(false)
	$Spider/AnimationPlayer.play("walk")
	
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		if parameter == "show_gift_item":
			if Save.is_at_story_point(Save.GIFT_STORY_POINT):
				if _value == "show": toggle_gift_visibility(true)
				else: toggle_gift_visibility(false))

	# Spawn/clear golems in different circumstances
	Global.debug_skill_used.connect(spawn_dgolems)
	Global.add_effect.connect(func(id):
		if id == "discombobulator" or id == "dv_charge":
			spawn_dgolems())
	Global.fishing_canceled.connect(clear_dgolems)
	Global.remove_effect.connect(func(_fx):
		if _fx == "discombobulator" or _fx == "dv_charge":
			clear_dgolems())
	
	Global.hearts_emit.connect(play_hearts)
	Global.camera = $Camera.camera # reference
	Global.player = self
	
	# TODO: working on DOF here
	var _cam_attrs = CameraAttributesPractical.new()
	_cam_attrs.dof_blur_amount = 0.012
	Global.camera.attributes = _cam_attrs
	
	Global.command_sent.connect(func(_cmd):
		if "/dof=" in _cmd: # set DOF strength
			var _dof = float(_cmd.split("=")[1])
			_cam_attrs.dof_blur_amount = _dof)
	
	SettingsHandler.setting_changed.connect(func(_param):
		if _param == "dof":
			var _v = SettingsHandler.settings[_param]
			if _v == "on": _cam_attrs.dof_blur_far_enabled = true
			else: _cam_attrs.dof_blur_far_enabled = false)
	
	$Camera.top_level = true
	$Camera.set_cam_rotation(Vector3(-20, 0, 0))
	Global.jade_bot_sound.connect(play_jade_sound)
	
	get_window().focus_exited.connect(func():
		_sprint_multiplier = 1.0
		$Camera.added_fov = 0.0)
	
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
			_calculated_speed = base_speed * clamp(_speed_ratio, 0.0, 2.0)
		elif "/playersmooth=" in _cmd:
			var _s = float(_cmd.replace("/playersmooth=", ""))
			smooth_mod = clamp(_s, 0.01, 1.0)
		elif _cmd == "/collision=off":
			$Collision.disabled = true
			Global.announcement_sent.emit("((Collision disabled))")
		elif _cmd == "/collision=on":
			$Collision.disabled = false
			Global.announcement_sent.emit("((Collision re-enabled))")
		elif _cmd == "/time=night":
			$PlayerMesh/NightLight.visible = true
		elif _cmd == "/time=day":
			$PlayerMesh/NightLight.visible = false
		elif _cmd == "/mini=true":
			Global.miniature = true
			Global.add_effect.emit("miniature")
			$PlayerMesh/Tree.set("parameters/time_scale/scale", 1.7)
			scale = Vector3(0.5, 0.5, 0.5)
		elif _cmd == "/mini=false":
			Global.miniature = false
			Global.remove_effect.emit("miniature")
			$PlayerMesh/Tree.set("parameters/time_scale/scale", 1.0)
			scale = Vector3(1.0, 1.0, 1.0)
	)
	
	$PlayerMesh/HeartParticles.emitting = true
	await get_tree().process_frame
	$PlayerMesh/HeartParticles.emitting = false
	$PlayerMesh/HeartParticles.visible = false

var _fs = 0 # forward state (if > 0, a 'forward' key (including strafe) is down)
var _ss = 0 # strafe state
var _blend_target = 1.0
var _strafe_target = 0.0
var _elongate_target = 0.0
var _blend_state = _blend_target

var _time_since_on_floor = 0.0
var _gravity_last_in_current_effects = false
var _double_jump_state = 0

func _physics_process(delta: float) -> void:
	if _gravity_last_in_current_effects and !"gravity" in Global.current_effects:
		_elongate_target = 2.0
		velocity.y = 1.0
	
	if is_on_floor():
		_time_since_on_floor = 0.0
		_double_jump_state = 0
	else:
		_time_since_on_floor += delta
	# Handle animations
	var _query_fs = _fs
	var _query_ss = _ss # query strafe state
	if Input.is_action_just_pressed("move_forward"): _query_fs += 1
	if Input.is_action_just_released("move_forward"): _query_fs -= 1
	
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
	
	if Input.get_action_strength("axis_move_forward") > 0.001:
		_direction.x = Input.get_action_strength("axis_move_forward")
	elif Input.is_action_pressed("move_forward"):
		_direction.x = 1
	elif Input.get_action_strength("axis_move_back") > 0.001:
		_direction.x = -Input.get_action_strength("axis_move_back")
	elif Input.is_action_pressed("move_back"):
		_direction.x = -1
	else: _direction.x = 0
	
	if SettingsHandler.check_value("direction_control", "strafe"):
		if Input.get_action_strength("axis_move_right") > 0.001:
			_direction.z = Input.get_action_strength("axis_move_right")
		elif Input.is_action_pressed("move_right"):
			_direction.z = 1
		elif Input.get_action_strength("axis_move_left") > 0.001:
			_direction.z = -Input.get_action_strength("axis_move_left")
		elif Input.is_action_pressed("move_left"):
			_direction.z = -1
		else: _direction.z = 0
	else: # use rotation controls
		if Input.is_action_pressed("move_right"):
			$Camera.get_node("OrbitHandler").target_rotation.y -= delta * 120.0
		elif Input.is_action_pressed("move_left"):
			$Camera.get_node("OrbitHandler").target_rotation.y += delta * 120.0
	
	if !"gravity" in Global.current_effects:
		if Input.is_action_pressed("move_up"): _direction.y = 1
		elif Input.is_action_pressed("move_down"): _direction.y = -1
		else: _direction.y = 0
	
	var _camera_direction = $Camera.rotation_degrees.y
	var _camera_basis = $Camera.global_transform.basis
	Global.camera_basis = _camera_basis
	Global.camera_pivot_rotation_degrees = $Camera.rotation_degrees
	
	# Get player sprint multiplier
	if Input.is_action_pressed("sprint"):
		_sprint_multiplier = 1.95
	else:
		_sprint_multiplier = 1.0
		$Camera.added_fov = 0.0
	_speed = _calculated_speed
	_speed *= _sprint_multiplier
	
	# Multiply inputs by the movement vector and orbit rotation
	# This could be improved, but it works
	if Global.can_move:
		_target_velocity = (Vector3.FORWARD * _camera_basis * Vector3(-1, 0, 1) * _direction.x)
		_target_velocity += (Vector3.RIGHT * _camera_basis * Vector3(1, 0, -1) * _direction.z)
		_target_velocity += (Vector3.UP * _camera_basis * Vector3(0, 1, 0) * _direction.y)
		
		if $Camera.rotation_degrees.x > LOOK_UP_DEADZONE:
			if _direction.y == 0:
				var _target_angle = clamp($Camera.rotation_degrees.x - LOOK_UP_DEADZONE, 0.0, LOOK_CLAMP)
				_target_velocity.y += _target_angle * LOOK_UP_SENSITIVITY * _direction.x
		elif $Camera.rotation_degrees.x < LOOK_DOWN_DEADZONE:
			if _direction.y == 0 and !$Collision/FloorCast.is_colliding():
				var _target_angle = clamp($Camera.rotation_degrees.x - LOOK_DOWN_DEADZONE, -LOOK_CLAMP, 0.0)
				_target_velocity.y += _target_angle * LOOK_DOWN_SENSITIVITY * _direction.x
		_target_velocity = _target_velocity.normalized() * Vector3(_speed, _speed * 1.12, _speed)
	else: _target_velocity = Vector3.ZERO
	
	if $Collision/FloorCast.is_colliding():
		_target_velocity.y = clamp(_target_velocity.y, 0, INF)
	
	velocity.x = lerp(velocity.x, _target_velocity.x, smoothing * 0.6 * delta * smooth_mod)
	velocity.z = lerp(velocity.z, _target_velocity.z, smoothing * delta * smooth_mod)
	
	# Apply gravity
	if "gravity" in Global.current_effects:
		$Collision.position.y = -0.08
		$PlayerMesh.global_position = $Spider/Armature/Skeleton3D/Cylinder.global_position
		$PlayerMesh.position.y += 0.35
		motion_mode = MotionMode.MOTION_MODE_GROUNDED
		if !is_on_floor():
			if Input.is_action_pressed("move_forward"):
				velocity += 10.0 * delta * Vector3.FORWARD * _camera_basis * Vector3(-1, 0, 1)
			velocity.y -= 27.0 * delta
		else:
			if Vector3(velocity * Vector3(1, 0, 1)).length() > 1.5:
				if !walking:
					walking = true
					$Walk.play()
			else:
				walking = false
		if Input.is_action_just_pressed("move_up"):
			if !Global.deco_pane_open and !get_viewport().gui_get_focus_owner() is LineEdit:
				if _double_jump_state < 2:
					$Jump.pitch_scale = 0.9 + rng.randf() * 0.2
					$Jump.play()
					walking = false
					
					if _double_jump_state == 1: velocity.y = 10.0
					else: velocity.y = 10.0
					_double_jump_state += 1
		
		velocity.x = lerp(velocity.x, _target_velocity.x, Utilities.critical_lerp(delta, 15.0))
		velocity.z = lerp(velocity.z, _target_velocity.z, Utilities.critical_lerp(delta, 15.0))
	else:
		$Collision.position.y = 0
		if walking:
			walking = false
		axis_lock_linear_x = false
		axis_lock_linear_z = false
		velocity.x = lerp(velocity.x, _target_velocity.x, smoothing * 0.6 * delta * smooth_mod)
		velocity.y = lerp(velocity.y, _target_velocity.y, smoothing * 0.5 * delta * smooth_mod)
		velocity.z = lerp(velocity.z, _target_velocity.z, smoothing * delta * smooth_mod)
	
	move_and_slide()
	
	Global.player_position = global_position
	Global.player_y_rotation = global_rotation.y
	_fs = _query_fs
	
	$Camera.rotation_degrees.y = fmod($Camera.rotation_degrees.y, 360.0);
	if Vector3(velocity * Vector3(1, 0, 1)).length() > 1.0:
		# "Naturalise" rotations of both camera and mesh by subtracting
		# 360deg until they are each less than 360deg
		if $Camera.rotation_degrees.y < 0:
			$Camera.rotation_degrees.y += 360.0;
		
		# Rotate the player mesh (and spider) to match the player's
		# direction - lerps faster when gravity is enabled
		if !"gravity" in Global.current_effects:
			$PlayerMesh.rotation.y = lerp_angle(
				$PlayerMesh.rotation.y,
				$Camera.rotation.y - _initial_y_rotation + PI,
				Utilities.critical_lerp(delta, smoothing * 0.6))
		else:
			$PlayerMesh.rotation.y = lerp_angle(
				$PlayerMesh.rotation.y,
				$Camera.rotation.y - _initial_y_rotation + PI,
				Utilities.critical_lerp(delta, smoothing * 2.0))
		$Spider.rotation.y = $PlayerMesh.rotation.y
	
	if Global.can_move:
		if _direction.x > 0 or _direction.z != 0:
			if _sprint_multiplier > 1.0:
				$Camera.added_fov = 14.0
		
		if !"gravity" in Global.current_effects:
			$PlayerMesh.rotation.z = lerp(
				$PlayerMesh.rotation.z,
				_direction.z * 0.4,
				smoothing * 0.2 * delta)
		else: $PlayerMesh.rotation.z = 0.0
	
	# Interpolating camera movements on physics tick seems to be smoother when
	# playing with unlimited frames
	$Camera.global_position.y = lerp(
		$Camera.global_position.y, global_position.y, smoothing * delta)
	$Camera.global_position.x = global_position.x
	$Camera.global_position.z = global_position.z
	_gravity_last_in_current_effects = "gravity" in Global.current_effects

var _target_jump_anim = 0.0

func _process(delta: float) -> void:
	$PlayerMesh/Motes.global_position = $PlayerMesh/MotesAnchor.global_position
	
	if $Camera.axis.spring_length < 0.5:
		if !Global.in_first_person:
			Global.in_first_person = true
			Global.first_person_entered.emit()
			
			$PlayerMesh/Stars.visible = false
			$PlayerMesh/Compendium.visible = false
			$Spider.visible = false
	else:
		if Global.in_first_person:
			Global.in_first_person = false
			Global.first_person_left.emit()
			
			$PlayerMesh/Stars.visible = true
			if $PlayerMesh/Compendium.is_open:
				$PlayerMesh/Compendium.visible = true
			if "gravity" in Global.current_effects:
				$Spider.visible = true
	
	$PlayerMesh/Stars.global_position = engine_bone.global_position
	$Camera.popup_open = Global.popup_open
	$Camera.mouse_in_ui = Global.mouse_in_ui
	
	if Global.can_move:
		_blend_state = lerp(_blend_state, _blend_target, 3.7 * delta)
		if !"gravity" in Global.current_effects:
			_strafe_target = lerp(_strafe_target, -_direction.z, 5.2 * delta)
			_elongate_target = lerp(_elongate_target, _direction.y * 1.2, 3.7 * delta)
		else:
			_elongate_target = 0.0
			_strafe_target = 0.5
	else: # gently reset when locking position
		_blend_state = lerp(_blend_state, 0.0, 2.0 * delta)
		if !"gravity" in Global.current_effects:
			_strafe_target = lerp(_strafe_target, 0.0, 2.0 * delta)
			_elongate_target = lerp(_elongate_target, 0.0, 2.0 * delta)
	$PlayerMesh/Tree.set("parameters/test_blend/blend_position", _blend_state)
	$PlayerMesh/Tree.set("parameters/strafe/add_amount", _strafe_target)
	$PlayerMesh/Tree.set("parameters/set_elongate/add_amount", _elongate_target)
	_target_jump_anim = abs(velocity.y) / 7.0
	$Spider.set_jump_scale(
		lerp($Spider.get_jump_scale(), _target_jump_anim, Utilities.critical_lerp(delta, 21.0)))
	if abs(velocity.y) < 1.0:
		$Spider.set_anim_speed(Vector3(velocity * Vector3(1, 0, 1)).length() * 0.9)
	else: $Spider.set_anim_speed(0.0)
	
	var _target_pitch_scale: float = (1.0
		+ Vector3(velocity * Vector3(1, 0, 1)).length() / base_speed * 0.5)
	if "gravity" in Global.current_effects:
		_target_pitch_scale = 0.7
	if Global.miniature:
		_target_pitch_scale += 0.2
	$EngineSound.pitch_scale = lerp($EngineSound.pitch_scale, _target_pitch_scale, 0.07)

func _on_sprint_sound_cd_timeout() -> void:
	can_play_sprint_sound = true

func _on_heart_timer_timeout() -> void:
	if hearts_playing:
		hearts_playing = false
		$PlayerMesh/HeartParticles.emitting = false

func _on_walk_finished() -> void:
	if !walking: return
	$Walk.pitch_scale = 0.8 + rng.randf() * 0.1
	if $Spider.visible:
		$Walk.volume_db = linear_to_db(0.3 + rng.randf() * 0.2)
	else:
		$Walk.volume_db = -80
	$Walk.play()

func _on_splash_test_entered_gravity_water() -> void:
	$PlayerMesh/JadeArmature.visible = false
	await get_tree().process_frame
	$Spider.visible = false

func _on_splash_test_left_gravity_water() -> void:
	$PlayerMesh/JadeArmature.visible = true
	$Spider.visible = true
