@tool
extends "res://lib/gadget/gadget.gd"

signal otter_animation_finished

const TEST_DIALOGUE = {
	"_entry": {
		"string": "((Test))",
		"options": {
			"day": "((Day))",
			"night": "((Night))",
			"test": "((OK))"
		}
	},
	"day": { "reference": "_exit" },
	"night": { "reference": "_exit" },
	"test": { "reference": "_exit" }
}

func _ready() -> void:
	$Otter/AnimationPlayer.animation_finished.connect(func(_anim):
		$Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting = true
		$Otter/AnimationPlayer.play("spin"))
	$Otter/AnimationPlayer.play("spin")

func _on_interacted() -> void:
	var _d = Dialogue.instantiate()
	_d.data = TEST_DIALOGUE
	_d.block_played.connect(func(id):
		if id == "day":
			Global.command_sent.emit("/time=day")
			Global.generic_area_entered.emit()
			in_range = true
		elif id == "night":
			Global.command_sent.emit("/time=night")
			Global.generic_area_entered.emit()
			in_range = true)
	Global.hud.add_child(_d)
	_d.open()

var _c = 0
func _process(delta: float) -> void:
	_c += delta
	if _c > 0.2:
		_c = 0.0
		if $Otter/AnimationPlayer.current_animation_position > 1.4:
			if $Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting:
				$Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting = false
