extends "res://lib/gadget/gadget.gd"
# Pulley
# Script for the character Pulley-4!

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")

const intro_dialogue_data = {
	"_entry": {
		"string": "F-f-friend, good morning! Thirty-three, seven. The magnetic realignment h-h-helped overnight, it did, twelve?",
		"options": {
			"new_bot": "All three rods seem to be floating just right, P-4; I feel like a new bot."
		}
	},
	"new_bot": {
		"string": "Four, four, four! Magnificent! So uh (ahem, twenty-three)... want to t-t-take them for a spin?",
		"options": {
			"icky": "Sounds like someone has an icky job lined up for an idle set of jade rods, huh."
		}
	},
	"icky": {
		"string": "I just... These rotten weeds and b-b-bugs, one, one, one! I can't. The static! Swooping and d-d-diving. Worse than the Unchained.",
		"options": {
			"handle": "It's okay, Pull. I'll handle it, starting with the weeds."
		}
	},
	"handle": {
		"reference": "_exit"
	}
}

func _ready() -> void:
	# Quick fix to an ambient occlusion issue
	$PulleyMesh/GolemSkeleton/Skeleton3D/ArmBase_L/ArmBase_L.rotation_degrees.y = 180.0
	$PulleyMesh/GolemSkeleton/Skeleton3D/Armpivot_L/Armpivot_L.rotation_degrees.y = 180.0
	
	$PulleyMesh/AnimationPlayer.play("Base")

func _on_interacted() -> void:
	if Global.in_exclusive_ui: return
	
	if Save.data.story_point == "game_start":
		var _d = Dialogue.instantiate()
		_d.data = intro_dialogue_data
		Global.hud.add_child(_d)
		_d.closed.connect(func():
			Save.advance_story())
		_d.open()
