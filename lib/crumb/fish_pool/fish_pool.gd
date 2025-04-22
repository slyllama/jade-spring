@tool
extends Node3D

const FishingInstance = preload("res://lib/fishing/fishing.tscn")
const ICON_ACTIVE = preload("res://lib/crumb/fish_pool/materials/textures/fish_icon.png")
const ICON_INACTIVE = preload("res://lib/crumb/fish_pool/materials/textures/fish_icon_inactive.png")

var rng = RandomNumberGenerator.new()

@export var awake = true:
	get: return(awake)
	set(_val):
		set_awake(_val)
		awake = _val

func set_awake(state = awake) -> void:
	$PoolGadget.active = state
	$PoolGadget.visible = state
	$Ripples/Motes.visible = state
	$SleepParticles.emitting = !state
	if state:
		$Title.spatial_string = "Le Fishe"
		$Icon.texture = ICON_ACTIVE
	else:
		$Title.spatial_string = "Le Fishe (Le Sleepee)"
		$Icon.texture = ICON_INACTIVE

func cooldown() -> void:
	Global.spawn_karma.emit(
		rng.randi_range(Global.kv_fish_min, Global.kv_fish_max),
		global_position + Vector3(0, 0.2, 0))
	awake = false
	set_awake()
	
	# 2 - 4 minute wait time
	$CooldownTimer.wait_time = rng.randf_range(60.0 * 2, 60.0 * 4)
	$CooldownTimer.start()

func proc_story() -> void:
	if Save.is_at_story_point("ratchet_gratitude"): awake = true
	else: awake = false
	set_awake()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Save.story_advanced.connect(proc_story)
	await get_tree().process_frame
	proc_story()

func _update_interact_text() -> void:
	if "discombobulator" in Global.current_effects:
			Global.interact_hint = "Feed Fish"

func _on_gadget_interacted() -> void:
	if !awake:
		Global.announcement_sent.emit(
			"These fish are just resting for now")
		return
	if Save.is_at_story_point("ratchet_gratitude"):
		if "fish_food" in Global.current_effects:
			Global.remove_effect.emit("fish_food")
			var _f = FishingInstance.instantiate()
			_f.completed.connect(cooldown)
			add_child(_f)
		else:
			Global.announcement_sent.emit(
				"These are protected fish, but they don't know that. All they want to do is eat.")
	else:
		Global.announcement_sent.emit(
			"These fish are just resting for now, but they might have something to offer you later.")

func _on_gadget_body_entered(body: Node3D) -> void:
	if Global.story_panel_open: return
	if body is CharacterBody3D:
		_update_interact_text()

func _on_cooldown_timer_timeout() -> void:
	awake = true
	set_awake()
