extends HBoxContainer

const HIGHLIGHT = Color("b13087")

var FILL_TEX = load("res://lib/attenuator/textures/pill_filled.png")
var KEY_UP_TEX = load("res://lib/attenuator/textures/piano_key.png")
var KEY_DOWN_TEX = load("res://lib/attenuator/textures/piano_key_press.png")

var alpha = 0.0
var pills: Array[TextureRect] = []
var is_disabled = false

signal played

@export var note_name = "_"
@export var id = -1 # to be replaced with array ID

func set_pills_color(color: Color) -> void:
	for _p in pills:
		_p.modulate = color

func set_pills_size(pills_size: int) -> void:
	for _i in pills_size:
		var _r: TextureRect = $Rect.duplicate()
		add_child(_r)
		pills.append(_r)

func assign_track(notes: Array) -> void:
	for note in notes:
		if int(note) < pills.size():
			pills[int(note)].texture = FILL_TEX
			pills[int(note)].get_node("Glow").visible = true

func disable() -> void:
	is_disabled = true
	$Button.disabled = true

func _ready() -> void:
	modulate = Color("b13087")
	$NoteIdent.texture = load("res://lib/attenuator/textures/notes/note_" + note_name[0] + ".png")
	$Rect.queue_free()

func _on_button_down() -> void:
	if is_disabled: return
	modulate = HIGHLIGHT
	$Note.play()
	played.emit()

func _on_mouse_entered() -> void:
	if is_disabled: return
	modulate.a = 2.0
	$Button.self_modulate = Color.DARK_SLATE_GRAY
	if Input.is_action_pressed("left_click"):
		$Button.texture_normal = KEY_DOWN_TEX
		modulate = HIGHLIGHT
		$Note.play()
		played.emit()

func _on_button_mouse_exited() -> void:
	$Button.self_modulate = Color.WHITE
	$Button.texture_normal = KEY_UP_TEX

func _on_button_button_up() -> void:
	if is_disabled: return
	$Button.texture_normal = KEY_UP_TEX

func _process(delta: float) -> void:
	modulate = lerp(modulate, Color.WHITE, delta * 4.0)
	modulate.a = lerp(modulate.a, alpha, delta * 4.0)
