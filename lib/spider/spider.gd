extends CharacterBody3D
# Spider
# Attached player to this to test out jumping puzzles etc

@onready var original_position = global_position

func _physics_process(_delta: float) -> void:
	velocity = Vector3.FORWARD * Global.camera_basis * Vector3(-1, 0, 1) * 2.0
	move_and_slide()
	$SpatialText.spatial_string = Utilities.fmt_vec3(global_position)
	$Placeholder.rotation_degrees.y = Global.camera_pivot_rotation_degrees.y
