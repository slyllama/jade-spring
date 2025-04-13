@tool
extends "res://lib/gadget/gadget.gd"

signal otter_animation_finished

const TEST_DIALOGUE = {
	"title": "Cid's Time Banner",
	"_entry": {
		"string": "The echo of the otter - at once a memory, a premonition, and a whisper cradled by the breeze of the present - gently calls to you.",
		"options": {
			"day": "Turn the skies to day.",
			"night": "Rotate the heavens to the night.",
			"rotate": "Rotate the sun.",
			"dismiss": "Dismiss."
		}
	},
	"rotate": { "reference": "_entry" },
	"day": { "reference": "_exit" },
	"night": { "reference": "_exit" },
	"dismiss": { "reference": "_exit" }
}

func play_animation() -> void:
	$Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting = true
	$Otter/AnimationPlayer.play("spin")

func _ready() -> void:
	play_animation()

func _on_interacted() -> void:
	var _d = Dialogue.instantiate()
	_d.data = TEST_DIALOGUE
	_d.block_played.connect(func(id):
		if id == "day":
			Global.generic_area_entered.emit()
			if !$FX.playing: $FX.play()
			in_range = true
			play_animation()
			await get_tree().create_timer(0.5).timeout
			Global.command_sent.emit("/time=day")
		elif id == "rotate":
			Global.command_sent.emit("/rotatesun")
		elif id == "night":
			# Proc achievement
			if SteamHandler.get_achievment_completion("twilight_peace") == 0:
				SteamHandler.complete_achievement("twilight_peace")
			
			Global.generic_area_entered.emit()
			if !$FX.playing: $FX.play()
			in_range = true
			play_animation()
			await get_tree().create_timer(0.5).timeout
			Global.command_sent.emit("/time=night")
		elif id == "dismiss":
			Global.generic_area_entered.emit()
			in_range = true)
	Global.hud.add_child(_d)
	_d.open()

var _c = 0
func _process(delta: float) -> void:
	_c += delta
	if !$Otter/AnimationPlayer.is_playing(): return
	if _c > 0.16:
		_c = 0.0
		if $Otter/AnimationPlayer.current_animation_position > 1.4:
			if $Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting:
				$Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting = false
