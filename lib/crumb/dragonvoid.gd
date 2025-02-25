@tool
extends Crumb
var rng = RandomNumberGenerator.new()

func clear() -> void:
	Global.announcement_sent.emit("The air lightens as the Flux disperses the somber void.")
	Global.remove_effect.emit("dv_charge")
	Global.bug_crumb_left.emit()
	super()

func process_custom_data() -> void:
	super()
	$SpatialText/FG/Title/CollectionIcon.texture = load(
		"res://lib/hud/fx_list/textures/fx_d_" + custom_data + ".png")

func _ready() -> void:
	super()
	$DragonvoidArc/AnimationPlayer.play("Wobble")
	body_entered.connect(func(body):
		#if Save.data.story_point == "game_start": return # not unlocked yet
		if body is CharacterBody3D:
			Global.dragonvoid_crumb_entered.emit())
	
	body_exited.connect(func(body):
		#if Save.data.story_point == "game_start": return # not unlocked yet
		if body is CharacterBody3D:
			Global.dragonvoid_crumb_left.emit())

func interact() -> void:
	if (Save.data.story_point == "game_start" or Save.data.story_point == "pick_weeds"
		or Save.data.story_point == "clear_bugs"):
		Global.announcement_sent.emit(
			"This streak of Dragonvoid casts a looming shadow over the garden.")
		return # not unlocked yet
	else:
		if "dv_charge" in Global.current_effects:
			var _f = FishingInstance.instantiate()
			_f.completed.connect(clear)
			_f.canceled.connect(func():
				Global.remove_effect.emit("dv_charge"))
			add_child(_f)
		else:
			Global.announcement_sent.emit(
				"This streak of Dragonvoid casts a looming shadow over the garden. I'll need Attuned Dispersion Flux to dispel it.")
