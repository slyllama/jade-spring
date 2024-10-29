extends Node3D

func _ready() -> void:
	$JadeBot/JadeArmature/Skeleton3D/EngineGlowCard.visible = false
	
	$JadeBot/AnimationPlayer.animation_finished.connect(func(_anim):
		$JadeBot/AnimationPlayer.play("dance"))
	$JadeBot/AnimationPlayer.play("dance")
