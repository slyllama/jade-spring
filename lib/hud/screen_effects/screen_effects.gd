extends CanvasLayer
# ScreenEffects
# Illustrate states like being in Dragonvoid, around bugs, etc

var bug_state = false
var dv_state = false
var bug_tween: Tween
var dv_tween: Tween

func _set_bugs_exponent(val) -> void:
	var _e = ease(val, 2.0)
	_e = 0.8 + 9.2 * _e
	$Bugs.material.set_shader_parameter("alpha_exponent", _e)

func _set_dragonvoid_exponent(val) -> void:
	var _e = ease(val, 2.0)
	_e = 0.8 + 9.2 * _e
	$Dragonvoid.material.set_shader_parameter("alpha_exponent", _e)

func _ready() -> void:
	_set_bugs_exponent(10.0)
	_set_dragonvoid_exponent(10.0)
	$Bugs.visible = false
	$Dragonvoid.visible = false
	
	Global.dragonvoid_crumb_entered.connect(func():
		dv_state = true
		$Dragonvoid.visible = true
		dv_tween = create_tween()
		dv_tween.tween_method(
			_set_dragonvoid_exponent, 1.0, 0.0, 0.15))
	
	Global.dragonvoid_crumb_left.connect(func():
		dv_state = false
		$Dragonvoid.visible = true
		dv_tween = create_tween()
		dv_tween.tween_method(
			_set_dragonvoid_exponent, 0.0, 1.0, 0.15)
		
		dv_tween.tween_callback(func():
			if !dv_state: $Dragonvoid.visible = false))
	
	Global.bug_crumb_entered.connect(func():
		bug_state = true
		$Bugs.visible = true
		bug_tween = create_tween()
		bug_tween.tween_method(
			_set_bugs_exponent, 1.0, 0.0, 0.15))
	
	Global.bug_crumb_left.connect(func():
		bug_state = false
		$Bugs.visible = true
		bug_tween = create_tween()
		bug_tween.tween_method(
			_set_bugs_exponent, 0.0, 1.0, 0.15)
		
		bug_tween.tween_callback(func():
			if !bug_state: $Bugs.visible = false))
