@tool
extends "res://lib/gadget/gadget.gd"

signal otter_animation_finished

const TEST_DIALOGUE = {
	"title": "Cid's Alteration Banner",
	"_entry": {
		"string": "At your command, the breath of the otter's spirit will reshape the garden as you please. Once you have committed your choice, however, there is no going back. (The game might lag momentarily if any of these changes are applied.)",
		"options": {
			"clear": "Clear all decorations.",
			"reset": "Reset decorations to default.",
			"dismiss": "Dismiss."
		}
	},
	"clear": {
		"string": "This will remove all decorations from the map, resulting in an empty garden. You won't be able to undo this change. Are you sure you want to proceed?",
		"options": {
			"clear_confirm": "Proceed.",
			"root": "Actually, I changed my mind."
		}
	},
	"reset": {
		"string": "This will reset all decorations in the map, reverting its layout (but not the story) to its default configuration. You won't be able to undo this change. Are you sure you want to proceed?",
		"options": {
			"reset_confirm": "Proceed.",
			"root": "Actually, I changed my mind."
		}
	},
	"clear_confirm": { "reference": "_exit", "type": "action" },
	"reset_confirm": { "reference": "_exit", "type": "action" },
	"root": { "reference": "_entry" },
	"dismiss": { "reference": "_exit" }
}

func play_animation() -> void:
	$Otter/OtterArmature/Skeleton3D/BubblesAttach/Bubbles.emitting = true
	$Otter/AnimationPlayer.play("spin")

func _ready() -> void:
	play_animation()

func _do_command(cmd: String) -> void:
	Global.generic_area_entered.emit()
	if !$FX.playing: $FX.play()
	in_range = true
	play_animation()
	await get_tree().create_timer(0.1).timeout
	
	Global.command_sent.emit(cmd)
	
	Global.generic_area_entered.emit()
	in_range = true

func _on_interacted() -> void:
	var _d = Dialogue.instantiate()
	_d.data = TEST_DIALOGUE
	_d.block_played.connect(func(id):
		if id == "clear_confirm": _do_command("/cleardeco")
		elif id == "reset_confirm": _do_command("/resetdeco"))
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
