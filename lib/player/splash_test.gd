extends RayCast3D

var target_splash_vol = 0.0
@onready var splash_vol = target_splash_vol

var last_over_water = false

signal entered_gravity_water
signal left_gravity_water

func enter_gravity_water() -> void:
	$Salmon/SalmonMesh.visible = true
	$Salmon/Splash.restart()
	$Salmon/FishSplash.play()
	entered_gravity_water.emit()

func leave_gravity_water() -> void:
	$Salmon/SalmonMesh.visible = false
	$Salmon/Splash.restart()
	left_gravity_water.emit()

func _ready() -> void:
	$SplashArm/Foam.emitting = false
	$Salmon/SalmonMesh.visible = false
	
	Global.gravity_entered.connect(func():
		if last_over_water:
			enter_gravity_water())
	
	Global.gravity_exited.connect(func():
		if last_over_water:
			leave_gravity_water())

func _process(delta: float) -> void:
	splash_vol = lerp(
		splash_vol, target_splash_vol, Utilities.critical_lerp(delta, 6.0))
	$SplashSound.volume_db = linear_to_db(splash_vol)
	
	if $SplashArm.get_hit_length() > $SplashArm.spring_length:
		$SplashArm/Foam.emitting = false
	
	if get_collider():
		if !last_over_water:
			if "gravity" in Global.current_effects:
				enter_gravity_water()
		
		if !$SplashArm/Foam.emitting:
			target_splash_vol = 0.35
		$SplashArm/Foam.emitting = true
		last_over_water = true
	else:
		if last_over_water:
			if "gravity" in Global.current_effects:
				leave_gravity_water()
		if $SplashArm/Foam.emitting:
			target_splash_vol = 0.0
		$SplashArm/Foam.emitting = false
		last_over_water = false
