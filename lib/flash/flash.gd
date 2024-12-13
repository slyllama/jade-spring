extends Node2D

func _ready() -> void:
	$Player.speed_scale = 1.05
	await get_tree().process_frame
	$Player.play("flash")
	await $Player.animation_finished
	queue_free()
