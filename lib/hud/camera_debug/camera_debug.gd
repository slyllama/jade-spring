extends PanelContainer
# CameraDebug
# Some useful debugging info for the weird moving camera

var _c = 0.0
func _process(delta: float) -> void:
	if _c < 0.1:
		_c += delta
		return
	else: _c = 0
	
	var _t = ""
	if "camera_orbiting" in Global:
		_t += "camera_orbiting = " + str(Global.camera_orbiting)
	if Global.orbit_handler:
		var _tr = Global.orbit_handler.target_rotation
		var _trs = str(snapped(_tr.x, 0.1)) + ", " + str(snapped(_tr.y, 0.1)) + ", " + str(snapped(_tr.z, 0.1))
		
		_t += "\nOrbitHandler.action_cam_active = " + str(Global.orbit_handler.action_cam_active)
		_t += "\nOrbitHandler.mouse_delta = " + str(Global.orbit_handler._last_mouse_delta)
		_t += "\nOrbitHandler.target_rotation = " + _trs
	_t += "\nDetected controllers: " + str(Input.get_connected_joypads().size())
	$Box/Debug.text = _t
