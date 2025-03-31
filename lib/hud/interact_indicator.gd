extends TextureButton

var input_binding = "interact"
var binding_validated = false
var binding_string = ""

func _display_binding() -> String: # show the key the skill is associated with
	if InputMap.has_action(input_binding):
		binding_validated = true
		var key_string = ""
		
		# If the input is a key, show its keycode string as a hint above the skill
		if InputMap.action_get_events(input_binding)[0] is InputEventKey:
			key_string = OS.get_keycode_string(
				InputMap.action_get_events(input_binding)[0].physical_keycode)
		return(key_string)
	else: return("")

func update() -> void:
	await get_tree().process_frame
	$Text.text = Utilities.format_binding(_display_binding()) + " " + Global.interact_hint

func clear() -> void:
	Global.interact_hint = "Inspect"

func _ready() -> void:
	clear()
	update()
	Global.bindings_updated.connect(update)
	
	Global.generic_area_entered.connect(update)
	Global.dragonvoid_crumb_entered.connect(update)
	Global.bug_crumb_entered.connect(update)
	Global.weed_crumb_entered.connect(update)
	
	Global.generic_area_left.connect(clear)
	Global.dragonvoid_crumb_left.connect(clear)
	Global.bug_crumb_left.connect(clear)
	Global.weed_crumb_left.connect(clear)
