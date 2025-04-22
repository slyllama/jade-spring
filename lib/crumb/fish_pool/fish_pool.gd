@tool
extends Node3D

const ICON_ACTIVE = preload("res://lib/crumb/fish_pool/materials/textures/fish_icon.png")
const ICON_INACTIVE = preload("res://lib/crumb/fish_pool/materials/textures/fish_icon_inactive.png")

@export var awake = true:
	get: return(awake)
	set(_val):
		set_awake(_val)
		awake = _val

func set_awake(state: bool) -> void:
	$PoolGadget.active = state
	$PoolGadget.visible = state
	$SleepParticles.emitting = !state
	if state:
		$Icon.texture = ICON_ACTIVE
	else:
		$Icon.texture = ICON_INACTIVE

func _update_interact_text() -> void:
	if "discombobulator" in Global.current_effects:
			Global.interact_hint = "Play With Fish"

func _on_gadget_interacted() -> void:
	if "discombobulator" in Global.current_effects:
		pass # TODO: fish
	else:
		Global.announcement_sent.emit(
			"These are protected fish, but they don't know that. All they want to do is eat.")

func _on_gadget_body_entered(body: Node3D) -> void:
	if Global.story_panel_open: return
	if body is CharacterBody3D:
		_update_interact_text()
