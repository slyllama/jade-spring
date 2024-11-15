extends CanvasLayer
# ScreenEffects
# Illustrate states like being in Dragonvoid, around bugs, etc

var bug_state = false

func _set_bugs_exponent(val) -> void:
	var _e = ease(val, 2.0)
	_e = 0.8 + 9.2 * _e
	$Bugs.material.set_shader_parameter("alpha_exponent", _e)

func _ready() -> void:
	_set_bugs_exponent(10.0)
	$Bugs.visible = false
	
	Global.bug_crumb_entered.connect(func():
		bug_state = true
		$Bugs.visible = true
		var bug_fade_in = create_tween()
		bug_fade_in.tween_method(
			_set_bugs_exponent, 1.0, 0.0, 0.15))
	
	Global.bug_crumb_left.connect(func():
		bug_state = false
		$Bugs.visible = true
		var bug_fade_out = create_tween()
		bug_fade_out.tween_method(
			_set_bugs_exponent, 0.0, 1.0, 0.15)
		
		bug_fade_out.tween_callback(func():
			if !bug_state: $Bugs.visible = false))
