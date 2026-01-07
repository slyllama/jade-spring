extends Node3D

@onready var original_position = global_position

func _proc_story() -> void:
	if Save.is_at_story_point("stewardship"):
		$Sphere/VaultMote.emitting = true
		global_position = original_position
	else: global_position.y -= 10.0

func _ready() -> void:
	$Sphere/VaultMote.emitting = false
	
	Save.story_advanced.connect(_proc_story)
	await get_tree().process_frame
	_proc_story()

func _on_gadget_interacted() -> void:
	Global.command_sent.emit("/vault")
