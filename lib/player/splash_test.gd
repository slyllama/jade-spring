extends RayCast3D

var target_splash_vol = 0.0
@onready var splash_vol = target_splash_vol

func _ready() -> void:
	$SplashArm/Foam.emitting = false

func _process(delta: float) -> void:
	splash_vol = lerp(
		splash_vol, target_splash_vol, Utilities.critical_lerp(delta, 6.0))
	$SplashSound.volume_db = linear_to_db(splash_vol)
	
	if get_collider():
		if !$SplashArm/Foam.emitting:
			target_splash_vol = 0.35
		$SplashArm/Foam.emitting = true
	else:
		if $SplashArm/Foam.emitting:
			target_splash_vol = 0.0
		$SplashArm/Foam.emitting = false
