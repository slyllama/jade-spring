@tool
extends "res://lib/gadget/gadget.gd"

signal otter_animation_finished

const TEST_DIALOGUE = {
	"title": "Cid's Miniaturization Banner",
	"_entry": {
		"string": "Cutting through your hazy memories, this otter's energy evokes the same sensations your as Mists Fractal journeys once did.",
		"options": {
			"mini": "Emsmallen me.",
			"return": "Return me to a normal size.",
			"dismiss": "Dismiss."
		}
	},
	"mini": { "reference": "_exit", "type": "action" },
	"return": { "reference": "_exit", "type": "action" },
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
		if id == "mini": _do_command("/mini=true")
		elif id == "return": _do_command("/mini=false"))
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
