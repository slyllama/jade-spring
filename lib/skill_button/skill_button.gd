class_name SkillButton extends TextureButton
# SkillButton
# Skill buttons that sit at the bottom of the screen. They simply emit their
# current ID, and show the icon associated with that ID.

signal clicked(id: String)
const TEXTURES = { # associations with texture paths
	"accept": preload("res://lib/skill_button/textures/accept.png"),
	"add": preload("res://lib/skill_button/textures/add.png"),
	"cancel": preload("res://lib/skill_button/textures/cancel.png"),
	"empty": preload("res://lib/skill_button/textures/empty.png"),
	"rotate": preload("res://lib/skill_button/textures/rotate.png"),
	"select": preload("res://lib/skill_button/textures/select.png"),
	"translate": preload("res://lib/skill_button/textures/translate.png")
}

@export var id := "empty"
@export var enabled := true

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

func _on_button_down() -> void:
	if enabled:
		clicked.emit(id)

func _on_mouse_entered() -> void:
	Global.mouse_in_ui = true
	if enabled and id != "empty":
		$HoverBorder.visible = true

func _on_mouse_exited() -> void:
	Global.mouse_in_ui = false
	$HoverBorder.visible = false
