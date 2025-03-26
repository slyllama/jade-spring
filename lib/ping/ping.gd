extends Node3D

var _target_speed = 20.0
var _speed = _target_speed

func _ready() -> void:
	_target_speed = 6.0
	$PingMesh.scale.z = 0.01
	var _scale_in = create_tween()
	_scale_in.tween_property($PingMesh, "scale:z", 2.0, 0.4)

func _physics_process(delta: float) -> void:
	_speed = lerp(_speed, _target_speed, Utilities.critical_lerp(delta, 10.0))
	$PingMesh.position.z -= delta * _speed

func _on_timer_timeout() -> void:
	var _scale_out = create_tween()
	_scale_out.tween_property($PingMesh, "scale", Vector3(0.01, 0.01, 0.01), 0.4)
	queue_free()
