extends RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SplashArm/Foam.emitting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_collider():
		$SplashArm/Foam.emitting = true
	else: $SplashArm/Foam.emitting = false
