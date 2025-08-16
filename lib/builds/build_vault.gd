extends Node3D

const BuildPane = preload("res://lib/builds/design_pane/design_pane.tscn")

var build_pane_open = false

func _ready() -> void:
	$BuildsGadget/Compendium.rotation_degrees.y = 180.0
	
	Global.vault_entered.connect(func():
		$BuildsGadget/Compendium/AnimationPlayer.play("float")
		
		# Handle music
		$Ambience.play()
		Global.target_music_ratio = 0.0
		$Ambience/Volume.play("louden"))
	
	Global.vault_left.connect(func():
		$BuildsGadget/Compendium/AnimationPlayer.stop()
		
		# Handle music
		Global.target_music_ratio = 1.0
		$Ambience/Volume.play("unlouden"))

func _on_builds_gadget_interacted() -> void:
	if build_pane_open: return
	
	build_pane_open = true
	var _b = BuildPane.instantiate()
	Global.hud.get_node("BuildCanvas").add_child(_b)
	Global.can_move = false
	
	_b.closed.connect(func():
		Global.can_move = true
		build_pane_open = false)

func _on_volume_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unlouden":
		$Ambience/Volume.stop()
