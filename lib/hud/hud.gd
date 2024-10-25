extends CanvasLayer

func _render_fps() -> String: # pretty formatting of FPS values
	var color = "green"
	var _fps = Engine.get_frames_per_second()
	if _fps < 60:
		color = "yellow"
	elif _fps < 10:
		color = "red"
	return("[color=" + color + "]" + str(_fps) + "fps[/color]")

func _process(_delta: float) -> void:
	# Debug stuff
	$Debug.text = _render_fps()
	$Debug.text += "\nPrimitives: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	$Debug.text += "\n"
	$Debug.text += ("\nTool mode: " + str(Global.tool_identities[Global.tool_mode]))
	$Debug.text += ("\nFoliage count: " + str(Global.foliage_count))
	if Global.active_decoration != null:
		$Debug.text += ("\n[color=yellow]Active decoration: " + str(Global.active_decoration) + "[/color]")
