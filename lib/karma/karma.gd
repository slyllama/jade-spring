extends Node3D

var picked_up = false

func _on_pick_up_area_body_entered(body: Node3D) -> void:
	if picked_up: return
	if body is CharacterBody3D:
		picked_up = true
		Save.add_karma(1)
		
		queue_free()

func _process(_delta: float) -> void:
	$Orb.global_position.y = $YCast.get_collision_point().y + 0.65
