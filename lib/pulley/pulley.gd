extends "res://lib/gadget/gadget.gd"
# Pulley
# Script for the character Pulley-4!

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")

func _ready() -> void:
	# Quick fix to an ambient occlusion issue
	$PulleyMesh/GolemSkeleton/Skeleton3D/ArmBase_L/ArmBase_L.rotation_degrees.y = 180.0
	$PulleyMesh/GolemSkeleton/Skeleton3D/Armpivot_L/Armpivot_L.rotation_degrees.y = 180.0
	
	$PulleyMesh/AnimationPlayer.play("Base")

func _on_interacted() -> void:
	if Global.in_exclusive_ui: return
	
	if Save.data.story_point == "game_start":
		var _d = Dialogue.instantiate()
		add_child(_d)
		_d.closed.connect(func():
			Save.advance_story())
		_d.open()
