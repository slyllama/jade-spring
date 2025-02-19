extends HBoxContainer

const HIGHLIGHT = Color("b13087")
const FILL_TEX = preload("res://lib/attenuator/textures/pill_filled.png")

var alpha = 0.0
var pills: Array[TextureRect] = []
signal played

@export var pitch = 1.0:
	get: return(pitch)
	set(_val):
		pitch = _val
		$Note.pitch_scale = pitch

func assign_track(notes: Array) -> void:
	for note in notes:
		if int(note) < pills.size():
			pills[int(note)].texture = FILL_TEX
			pills[int(note)].get_node("Glow").visible = true

func _ready() -> void:
	modulate = Color("b13087")
	
	for _i in 9:
		var _r: TextureRect = $Rect.duplicate()
		add_child(_r)
		pills.append(_r)

func _on_button_down() -> void:
	modulate = HIGHLIGHT
	$Note.play()
	played.emit()

func _on_mouse_entered() -> void:
	if Input.is_action_pressed("left_click"):
		modulate = HIGHLIGHT
		$Note.play()
		played.emit()

func _process(delta: float) -> void:
	modulate = lerp(modulate, Color.WHITE, delta * 4.0)
	modulate.a = lerp(modulate.a, alpha, delta * 4.0)
