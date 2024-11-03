class_name SkillButton extends TextureButton
# SkillButton
# Skill buttons that sit at the bottom of the screen. They simply emit their
# current ID, and show the icon associated with that ID.

signal clicked(id: String)

const RANDOM_COLORS = [ Color.BLUE, Color.RED, Color.GREEN, Color.YELLOW, Color.DEEP_PINK ]

const TEXTURES = { # associations with texture paths
	"accept": preload("res://lib/skill_button/textures/accept.png"),
	"cancel": preload("res://lib/skill_button/textures/cancel.png"),
	"empty": preload("res://lib/skill_button/textures/empty.png"),
	"select": preload("res://lib/skill_button/textures/select.png"),
	"transform_mode": preload("res://lib/skill_button/textures/transform_mode.png")
}
const UNKNOWN_TEXTURE = preload("res://lib/skill_button/textures/unknown.png")

const TOOLTIPS = {
	"select": {
		"title": "Select Decoration",
		"description": "Select a decoration for adjusting."
	},
	"cancel": {
		"title": "Cancel",
		"description": "End the current action."
	},
	"accept": {
		"title": "Apply Transformation",
		"description": "Confirm and save the current transformation."
	}
}

@export var id := "empty"
@export var title := "Skill"
@export_multiline var description := "Tooltip." # displays in tool-tip
@export var enabled := true
@export var input_binding: String

var binding_validated = false # is the exported input binding real?
var RNG = RandomNumberGenerator.new()

func set_highlight(state = true) -> void:
	$ActiveOverlay.visible = state

func set_enabled(state = true) -> void:
	enabled = state
	if !enabled: modulate = Color(0.5, 0.5, 0.5)
	else: modulate = Color.WHITE

func set_tip_text(get_title: String, get_description: String):
	$Tooltip.text = "[font_size=19]" + get_title + "[/font_size]\n" + get_description

# Flip to another skill, GW2 style - disables while animating
func switch_skill(get_id: String) -> void:
	set_enabled(false)
	set_highlight(false)
	$Animation.play("squeeze")
	
	id = get_id
	if id in TEXTURES:
		$Image.texture = TEXTURES[id]
		$Image.modulate = Color.WHITE
	else:
		$Image.texture = UNKNOWN_TEXTURE
		$Image.modulate = RANDOM_COLORS[RNG.randi_range(0, RANDOM_COLORS.size() - 1)]
	if id in TOOLTIPS:
		set_tip_text(TOOLTIPS[id].title, TOOLTIPS[id].description)
	else: set_tip_text(title, description)
	
	await $Animation.animation_finished
	$Animation.play_backwards("squeeze")
	set_enabled()

func _input(_event: InputEvent) -> void:
	if !binding_validated: return
	if Input.is_action_just_pressed(input_binding):
		_on_button_down()

func _ready() -> void:
	$Tooltip.visible = false
	set_tip_text(title, description)
	
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

func _process(_delta: float) -> void:
	if $Tooltip.visible:
		$Tooltip.global_position = get_global_mouse_position()
		$Tooltip.global_position.y -= $Tooltip.size.y

func _on_button_down() -> void:
	if enabled:
		Global.click_sound.emit()
		clicked.emit(id)

func _on_mouse_entered() -> void:
	Global.mouse_in_ui = true
	if id != "empty":
		$Tooltip.visible = true
	if enabled and id != "empty":
		$HoverBorder.visible = true

func _on_mouse_exited() -> void:
	$Tooltip.visible = false
	Global.mouse_in_ui = false
	$HoverBorder.visible = false
