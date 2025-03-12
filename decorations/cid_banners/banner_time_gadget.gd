@tool
extends "res://lib/gadget/gadget.gd"

signal otter_animation_finished

const TEST_DIALOGUE = {
	"_entry": {
		"string": "The echo of the otter - at once a memory, a premonition, and a whisper cradled by the breeze of the present - gently calls to you.",
		"options": {
			"day": "Turn the skies to day.",
			"night": "Rotate the heavens to the night.",
			"test": "Dismiss."
		}
	},
	"day": { "reference": "_exit" },
	"night": { "reference": "_exit" },
	"test": { "reference": "_exit" }
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
			await get_tree().create_timer(0.5).timeout
			Global.command_sent.emit("/time=day")
		elif id == "night":
			Global.generic_area_entered.emit()
			if !$FX.playing: $FX.play()
			in_range = true
			await get_tree().create_timer(0.5).timeout
			Global.command_sent.emit("/time=night"))
	_d.closed.connect(play_animation)
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
