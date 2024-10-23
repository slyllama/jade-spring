extends CanvasLayer

func _process(_delta: float) -> void:
	# Debug stuff
	$Debug.text = ("Global.tool_mode = "
		+ str(Global.tool_identities[Global.tool_mode]))
	$Debug.text += ("\nGlobal.foliage_count = "
		+ str(Global.foliage_count))
	if Global.active_decoration != null:
		$Debug.text += ("\nGlobal.active_decoration = "
		+ str(Global.active_decoration))
