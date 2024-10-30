class_name SkillButton extends TextureButton
# SkillButton
# Skill buttons that sit at the bottom of the screen. They simply emit their
# current ID, and show the icon associated with that ID.

signal clicked(id: String)
const TEXTURES = { # associations with texture paths
	"accept": preload("res://lib/skill_button/textures/accept.png"),
	"cancel": preload("res://lib/skill_button/textures/cancel.png"),
	"empty": preload("res://lib/skill_button/textures/empty.png"),
	"select": preload("res://lib/skill_button/textures/select.png")
}

@export var id := "empty"
@export var enabled := true
@export var input_binding: String

var binding_validated = false # is the exported input binding real?

func set_highlight(state = true) -> void:
	$ActiveOverlay.visible = state

func set_enabled(state = true) -> void:
	enabled = state
	if !enabled: modulate = Color(0.5, 0.5, 0.5)
	else: modulate = Color.WHITE

# Flip to another skill, GW2 style - disables while animating
func switch_skill(get_id: String) -> void:
	set_enabled(false)
	set_highlight(false)
	$Animation.play("squeeze")
	
	id = get_id
	$Image.texture = TEXTURES[id]
	
	await $Animation.animation_finished
	$Animation.play_backwards("squeeze")
	set_enabled()

func _input(_event: InputEvent) -> void:
	if !binding_validated: return
	if Input.is_action_just_pressed(input_binding):
		_on_button_down()

func _ready() -> void:
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

func _on_button_down() -> void:
	if enabled:
		Global.click_sound.emit()
		clicked.emit(id)

func _on_mouse_entered() -> void:
	Global.mouse_in_ui = true
	if enabled and id != "empty":
		$HoverBorder.visible = true

func _on_mouse_exited() -> void:
	Global.mouse_in_ui = false
	$HoverBorder.visible = false
