extends TextureButton

var input_binding = "interact"
var binding_validated = false

func _display_binding() -> void: # show the key the skill is associated with
	if InputMap.has_action(input_binding):
		binding_validated = true
		var key_string = ""
		
		# If the input is a key, show its keycode string as a hint above the skill
		if InputMap.action_get_events(input_binding)[0] is InputEventKey:
			key_string = OS.get_keycode_string(
				InputMap.action_get_events(input_binding)[0].physical_keycode)
		key_string = "[center]" + key_string + "[/center]"
		$InputKeyBox/InputKey.text = key_string
	else: $InputKeyBox.visible = false # only show input hint if valid

func _ready() -> void:
	_display_binding()
	Global.bindings_updated.connect(_display_binding)
