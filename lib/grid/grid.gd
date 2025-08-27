extends Node3D

var _count = 28
var _duration = 0.15
@onready var _increment = Global.SNAP_INCREMENT * 2.0

func appear() -> void:
	var _t = create_tween()
	_t.set_ease(Tween.EASE_IN_OUT)
	_t.tween_property(
		self, "scale", Vector3(1.0, 1.0, 1.0), _duration)

func disappear() -> void:
	var _t = create_tween()
	_t.set_ease(Tween.EASE_IN_OUT)
	_t.tween_property(
		self, "scale", Vector3(0.01, 0.01, 0.01), _duration)
	_t.tween_callback(queue_free)

func _ready() -> void:
	scale = Vector3(0.01, 0.01, 0.01)
	$X/GridLine.mesh.size.y = _increment * _count
	
	for _i in _count:
		var _gx = $X/GridLine.duplicate()
		_gx.position.x = _i * _increment
		$X.add_child(_gx)
		
		var _gz = $Z/GridLine.duplicate()
		_gz.position.z = _i * _increment
		$Z.add_child(_gz)
		
	for _gx in $X.get_children():
		_gx.position.x -= _increment * _count / 2.0
	for _gz in $Z.get_children():
		_gz.position.z -= _increment * _count / 2.0
	
	await get_tree().process_frame
	appear()
