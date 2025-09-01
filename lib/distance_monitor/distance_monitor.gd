class_name DistanceMonitor extends Marker3D

var _c := 0.0

func _process(delta: float) -> void:
	if !Global.aggressive_culling:
		if !get_parent().visible: get_parent().visible = true
		return
	if _c < 0.75:
		_c += delta
		return
	else: _c = 0.0
	
	var _d = get_parent().global_position.distance_squared_to(Global.player.global_position)
	if _d > Global.aggressive_cull_distance_squared: get_parent().visible = false
	else: get_parent().visible = true
