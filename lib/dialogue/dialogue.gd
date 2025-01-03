extends CanvasLayer

signal closed
signal block_played(id)
var has_closed = false

var data = { # default (blank) script
	"_entry": {
		"string": "((Empty dialogue.))",
		"options": {
			"close": "Exit."
		}
	},
	"close": {
		"reference": "_exit"
	}
}

func _set_paint_val(val: float) -> void:
	$Base.material.set_shader_parameter("value", val)

func _set_exposure_val(val: float) -> void:
	$Base.material.set_shader_parameter("exposure", val)

func render_block(block_data: Dictionary) -> void:
	for _n in $Base/Box.get_children():
		if _n is Button: _n.queue_free() # clear out previous buttons
	
	var _exp_tween = create_tween() # exposure flash
	_exp_tween.tween_method(_set_exposure_val, 2.0, 1.0, 0.31).set_ease(Tween.EASE_IN_OUT)
	
	if "string" in block_data:
		$Base/Box/Text.text = block_data.string
	
	if "options" in block_data:
		for _o in block_data.options:
			var _b = $Base/TemplateButton.duplicate()
			_b.text = block_data.options[_o]
			_b.visible = true
			$Base/Box.add_child(_b)
			
			_b.button_down.connect(func():
				block_played.emit(_o)
				if _o in data:
					var _new_block_data = data[_o]
					if "reference" in _new_block_data:
						if _new_block_data.reference == "_exit":
							close()
						if _new_block_data.reference in data:
							render_block(data[_new_block_data.reference])
					else: render_block(_new_block_data))

func open() -> void:
	Global.in_exclusive_ui = true
	Global.can_move = false
	if "_entry" in data:
		render_block(data._entry)
	if "_texture" in data:
		$Base/Sticker.texture = load("res://generic/textures/stickers/" + str(data._texture) + ".png")
	
	$Player.play("Enter")
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_val, -1.0, 1.0, 0.3)

func close() -> void:
	if has_closed: return
	has_closed = true
	
	closed.emit()
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_val, 1.0, -1.0, 0.3)
	
	await fade_tween.finished
	await get_tree().process_frame
	Global.in_exclusive_ui = false
	Global.can_move = true
	queue_free()

func _ready() -> void:
	#$Player.play("RESET")
	$Base.modulate.a = 1.0

func _on_done_button_down() -> void:
	close()
