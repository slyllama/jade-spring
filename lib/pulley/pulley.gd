extends "res://lib/gadget/gadget.gd"
# Pulley
# Script for the character Pulley-4!

func _ready() -> void:
	$PulleyMesh/AnimationPlayer.play("Base")

func _on_interacted() -> void:
	if Save.data.story_point == "bulwark_gyro":
		print("This will only work on the 2nd story step")
