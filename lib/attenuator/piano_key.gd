extends HBoxContainer

@export var pitch = 1.0:
	get: return(pitch)
	set(_val):
		pitch = _val
		$Note.pitch_scale = pitch

func _ready() -> void:
	modulate = Color.MAGENTA
	
	for _i in 5:
		var _r = $Rect.duplicate()
		add_child(_r)

func _on_button_down() -> void:
	modulate = Color.MAGENTA
	$Note.play()

func _on_mouse_entered() -> void:
	if Input.is_action_pressed("left_click"):
		modulate = Color.MAGENTA
		$Note.play()

func _process(delta: float) -> void:
	modulate = lerp(modulate, Color.WHITE, delta * 4.0)
