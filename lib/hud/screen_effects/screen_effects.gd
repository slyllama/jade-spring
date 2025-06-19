extends CanvasLayer
# ScreenEffects
# Illustrate states like being in Dragonvoid, around bugs, etc

var bug_state = false
var bug_val = 1.0
var dv_state = false
var dv_val = 1.0
var flowers_state = false
var flowers_val = 1.0
var bug_tween: Tween
var dv_tween: Tween

func _ripple() -> void:
	var ripple_tween = create_tween()
	ripple_tween.tween_method(_set_ripple, 0.0, 1.0, 5.0)

func _set_ripple(val: float) -> void:
	var _e = ease(val, 0.2)
	$ScreenShader.material.set_shader_parameter("ripple_force", (1 - _e) * 0.026)
	$ScreenShader.material.set_shader_parameter("ripple_size", _e * 2.0)
	$ScreenShader.material.set_shader_parameter("displacement", 1 - _e)

func _aberrate() -> void:
	var abr_tween = create_tween()
	abr_tween.tween_method(_set_aberration, 7.0, 0.0, 0.45)

func _show_flowers() -> void:
	flowers_state = true
	$Flowers.visible = true
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_flowers_exponent, flowers_val, 0.0, 0.1)

func _hide_flowers() -> void:
	flowers_state = false
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_flowers_exponent, flowers_val, 1.0, 0.45)
	fade_tween.tween_callback(func():
		if !flowers_state:
			$Flowers.visible = false)

func _set_aberration(val: float) -> void:
	$ScreenShader.material.set_shader_parameter("displacement", val)

func _set_anime_alpha(val: float) -> void:
	$Anime.material.set_shader_parameter("modulate_a", val)

func _set_flowers_exponent(val: float) -> void:
	flowers_val = val
	var _e = ease(val, 2.0)
	_e = 10.0 * _e
	$Flowers.material.set_shader_parameter("alpha_exponent", _e)

func _set_bugs_exponent(val: float) -> void:
	bug_val = val
	var _e = ease(val, 2.0)
	_e = 0.8 + 9.2 * _e
	$Bugs.material.set_shader_parameter("alpha_exponent", _e)

func _set_dragonvoid_exponent(val: float) -> void:
	dv_val = val
	var _e = ease(val, 2.0)
	_e = 0.8 + 9.2 * _e
	$Dragonvoid.material.set_shader_parameter("alpha_exponent", _e)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("sprint"):
		if get_window().gui_get_focus_owner() is LineEdit: return
		var _f = create_tween()
		_f.tween_method(_set_anime_alpha, 0.0, 0.5, 0.1)
	elif Input.is_action_just_released("sprint"):
		var _f = create_tween()
		_f.tween_method(_set_anime_alpha, $Anime.material.get_shader_parameter("modulate_a"), 0.0, 0.1)
	
	if Input.is_action_just_pressed("toggle_hud"):
		if $Debug.visible:
			$Debug.visible = false
		else:
			if Global.map_name == "debug":
				$Debug.visible = true

func _ready() -> void:
	_set_bugs_exponent(1.0)
	_set_dragonvoid_exponent(1.0)
	_set_flowers_exponent(1.0)
	
	$Bugs.visible = false
	$Dragonvoid.visible = false
	$Underlay.visible = false
	$Flowers.visible = false
	
	if Global.map_name == "debug": $Debug.visible = true
	else: $Debug.visible = false
	
	get_window().focus_exited.connect(func():
		if $Anime.material.get_shader_parameter("modulate_a") > 0.0:
			var _f = create_tween()
			_f.tween_method(_set_anime_alpha, 0.5, 0.0, 0.1))
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/ping":
			_aberrate()
		elif cmd == "/screenshot":
			$Debug.visible = false
			for _x in 2: await get_tree().process_frame
			if Global.map_name == "debug":
				$Debug.visible = true
		elif cmd == "/mini=true":
			_aberrate())
	
	Global.dragonvoid_crumb_entered.connect(func():
		dv_state = true
		$Dragonvoid.visible = true
		dv_tween = create_tween()
		dv_tween.tween_method(
			_set_dragonvoid_exponent, dv_val, 0.0, 0.15))
	
	Global.dragonvoid_crumb_left.connect(func():
		dv_state = false
		$Dragonvoid.visible = true
		dv_tween = create_tween()
		dv_tween.tween_method(
			_set_dragonvoid_exponent, dv_val, 1.0, 0.15)
		
		dv_tween.tween_callback(func():
			if !dv_state: $Dragonvoid.visible = false))
	
	Global.bug_crumb_entered.connect(func():
		bug_state = true
		$Bugs.visible = true
		bug_tween = create_tween()
		bug_tween.tween_method(
			_set_bugs_exponent, bug_val, 0.0, 0.15))
	
	Global.bug_crumb_left.connect(func():
		bug_state = false
		$Bugs.visible = true
		bug_tween = create_tween()
		bug_tween.tween_method(
			_set_bugs_exponent, bug_val, 1.0, 0.15)
		
		bug_tween.tween_callback(func():
			if !bug_state: $Bugs.visible = false))
	
	Global.ripple.connect(_ripple)
	Global.gravity_entered.connect(_aberrate)
	Global.flowers_show.connect(_show_flowers)
	Global.flowers_hide.connect(_hide_flowers)
