extends Node3D

func _ready() -> void:
	# Set up retina
	if DisplayServer.screen_get_size().x > 2000:
		get_window().size *= 2
		get_window().content_scale_factor = 2
		# macOS already configures the cursor for retina
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://generic/textures/cursor_2x.png"))

func _process(_delta: float) -> void:
	# Debug stuff
	$FG/Debug.text = ("Global.tool_mode = "
		+ str(Global.tool_identities[Global.tool_mode]))
	if Global.active_decoration != null:
		$FG/Debug.text += ("\nGlobal.active_decoration = "
		+ str(Global.active_decoration))
