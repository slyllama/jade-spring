extends Button

@export var pitch = 1.0:
	get: return(pitch)
	set(_val):
		pitch = _val
		$Note.pitch_scale = pitch

func _on_button_down() -> void:
	$Note.play()

func _on_mouse_entered() -> void:
	if Input.is_action_pressed("left_click"):
		$Note.play()
