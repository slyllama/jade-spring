class_name SkillButton extends TextureButton
# SkillButton
# Skill buttons that sit at the bottom of the screen. They simply emit their
# current ID, and show the icon associated with that ID.

signal clicked(id: String)

const RANDOM_COLORS = [ Color.CYAN, Color.ORANGE_RED, Color.GREEN, Color.YELLOW, Color.DEEP_PINK ]
const TEXTURES = { # associations with texture paths
	"accept": preload("res://lib/skill_button/textures/accept.png"),
	"edit_selection": preload("res://lib/skill_button/textures/accept.png"),
	"delete": preload("res://lib/skill_button/textures/delete.png"),
	"deco_test": preload("res://lib/skill_button/textures/deco.png"),
	"adjust_mode_rotate": preload("res://lib/skill_button/textures/rotate.png"),
	"empty": preload("res://lib/skill_button/textures/empty.png"),
	"select": preload("res://lib/skill_button/textures/select.png"),
	"cancel": preload("res://lib/skill_button/textures/cancel.png"),
	"vault_leave": preload("res://lib/skill_button/textures/cancel.png"),
	"snap_enable": preload("res://lib/skill_button/textures/snap_disable.png"),
	"snap_disable": preload("res://lib/skill_button/textures/snap_enable.png"),
	"snap_forbidden": preload("res://lib/skill_button/textures/snap_forbidden.png"),
	"transform_mode": preload("res://lib/skill_button/textures/transform_mode.png"),
	"reset_adjustment": preload("res://lib/skill_button/textures/reset_adjustment.png"),
	"fishing_left": preload("res://lib/skill_button/textures/fishing_left.png"),
	"fishing_right": preload("res://lib/skill_button/textures/fishing_right.png"),
	"rotate_left": preload("res://lib/skill_button/textures/rotate_minus_90.png"),
	"rotate_right": preload("res://lib/skill_button/textures/rotate_90.png"),
	"eyedropper": preload("res://lib/skill_button/textures/duplicate.png"),
	"adjust_mode_translate": preload("res://lib/skill_button/textures/move_scale.png"),
	"toggle_gravity": preload("res://lib/skill_button/textures/toggle_gravity.png"),
	"ping": preload("res://lib/skill_button/textures/ping.png"),
	"select_multiple": preload("res://lib/skill_button/textures/select_multiple.png")
}
const UNKNOWN_TEXTURE = preload("res://lib/skill_button/textures/unknown.png")
const TOOLTIPS = {
	"select": {
		"title": "Select Decoration",
		"description": "Select a decoration for adjusting."
	},
	"delete": {
		"title": "Delete Decorations",
		"description": "Remove items."
	},
	"deco_test": {
		"title": "Decoration Pane",
		"description": "Open a comprehensive catalogue of placeable items!"
	},
	"cancel": {
		"title": "Cancel",
		"description": "End the current action."
	},
	"vault_leave": {
		"title": "Exit Enclave",
		"description": "Exit the Enclave and return to the garden."
	},
	"accept": {
		"title": "Apply Transformation",
		"description": "Confirm the current transformation."
	},
	"edit_selection": {
		"title": "Edit Selection",
		"description": "Move the current selection."
	},
	"duplicate_edit_selection": {
		"title": "Duplicate and Edit Selection",
		"description": "Duplicate and move the current selection."
	},
	"transform_mode": {
		"title": "Toggle Transformation Basis",
		"description": "Switch between object axes and world axes."
	},
	"adjust_mode_translate": {
		"title": "Move",
		"description": "Switch to movement controls."
	},
	"adjust_mode_rotate": {
		"title": "Rotate",
		"description": "Switch to rotation controls."
	},
	"snap_enable": {
		"title": "Enable Snapping",
		"description": "Snap transformation."
	},
	"snap_disable": {
		"title": "Disable Snapping",
		"description": "Allow free transformation."
	},
	"snap_forbidden": {
		"title": "Snapping Disabled",
		"description": "Snapping works while in world Transform mode."
	},
	"reset_adjustment": {
		"title": "Reset Decoration",
		"description": "Reset rotation and scale of decoration."
	},
	"toggle_gravity": {
		"title": "Toggle Gravity",
		"description": "Turn physics on or off. Useful for jumping puzzles!"
	},
	"rotate_left": {
		"title": "Rotate Left",
		"description": "Rotate the decoration left by 90 degrees."
	},
	"rotate_right": {
		"title": "Rotate Right",
		"description": "Rotate the decoration right by 90 degrees."
	},
	"debug_skill": {
		"title": "((Debug Skill))",
		"description": "((Debug skill.))"
	},
	"eyedropper": {
		"title": "Copy Decoration",
		"description": "Copy an existing decoration, along with its rotation and scale."
	},
	"fishing_left": {
		"title": "Adjust Left",
		"description": "Move the Attenuation gauge left."
	},
	"fishing_right": {
		"title": "Adjust Right",
		"description": "Move the Attenuation gauge right."
	},
	"ping": {
		"title": "Garden Sense",
		"description": "Use radar to find the nearest weeds, bugs, and Dragonvoid which need dealing with."
	},
	"select_multiple": {
		"title": "Select Multiple",
		"description": "Add multiple decorations to selection (and move them as a group)."
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
	$LockedOverlay.visible = !state
	enabled = state
	if !enabled: $Image.modulate = Color(0.27, 0.27, 0.27)
	else: $Image.modulate = Color.WHITE

func set_tip_text(get_title: String, get_description: String):
	$Tooltip.text = "[font_size=19]" + get_title + "[/font_size]\n" + get_description
	$Tooltip.size.y = 0

# Flip to another skill, GW2 style - disables while animating
func switch_skill(get_id: String) -> void:
	#set_enabled(false)
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
	
	if get_id == "empty":
		set_enabled()
	
	await $Animation.animation_finished
	$Animation.play_backwards("squeeze")

func _input(_event: InputEvent) -> void:
	if Global.bindings_pane_open or Global.dialogue_open or Global.dragging: return
	if Global.popup_open or !binding_validated or !enabled: return
	if Input.is_action_just_pressed(input_binding):
		fx_down()
	elif Input.is_action_just_released(input_binding):
		Global.skill_button_up.emit(id)

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
	$Tooltip.visible = false
	set_tip_text(title, description)
	
	Global.skill_button_up.connect(func(up_id):
		if !up_id != id and $Image.modulate == Color(0.5, 0.5, 0.5):
			$Image.modulate = Color(1.0, 1.0, 1.0)
			$Image.scale = Vector2(0.5, 0.5))
	
	#Global.controller_skill.connect(func(_node):
		#if _node == self:
			#if Global.bindings_pane_open or Global.dialogue_open: return
			#if Global.popup_open or !binding_validated or !enabled: return
			#fx_down()
			#await get_tree().process_frame
			#_on_button_up())
	
	_display_binding()
	Global.bindings_updated.connect(_display_binding)

func _process(_delta: float) -> void:
	if $Tooltip.visible:
		$Tooltip.global_position = get_global_mouse_position()
		$Tooltip.global_position.y -= $Tooltip.size.y

func _on_button_down() -> void:
	if Global.bindings_pane_open: return
	if enabled:
		if (!Global.in_exclusive_ui or id == "cancel"
			or id == "fishing_left" or id == "fishing_right"):
			fx_down()

func _on_button_up() -> void:
	if enabled:
		if (!Global.in_exclusive_ui or id == "cancel"
			or id == "fishing_left" or id == "fishing_right"):
			fx_up()
			$Tooltip.visible = false
			if !Global.on_skill_cooldown:
				Global.click_sound.emit()
				Global.do_skill_cooldown()
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

func fx_down() -> void:
	Global.skill_button_down.emit(id)
	$Image.modulate = Color(0.5, 0.5, 0.5)
	$Image.scale = Vector2(0.4, 0.4)

func fx_up() -> void:
	Global.skill_button_up.emit(id)
	$Image.modulate = Color(1.0, 1.0, 1.0)
	$Image.scale = Vector2(0.5, 0.5)
