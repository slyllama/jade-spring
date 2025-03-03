extends CanvasLayer

signal closed
signal block_played(id)

var has_closed = false
var camera_last_orbiting = false

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
	_exp_tween.tween_method(_set_exposure_val, 1.2, 1.0, 0.31).set_ease(Tween.EASE_IN_OUT)
	
	if "string" in block_data:
		$Base/Box/Text.text = block_data.string
	
	var _first = false
	
	if "options" in block_data:
		for _o in block_data.options:
			var _b: Button = $Base/TemplateButton.duplicate()
			_b.text = block_data.options[_o]
			_b.visible = true
			_b.modulate.a = 0.0
			$Base/Box.add_child(_b)
			if !_first:
				_b.grab_focus()
				_first = true
			
			_b.button_down.connect(func():
				block_played.emit(_o)
				Global.click_sound.emit()
				if _o in data:
					var _new_block_data = data[_o]
					if "reference" in _new_block_data:
						if _new_block_data.reference == "_exit":
							close()
						if _new_block_data.reference in data:
							render_block(data[_new_block_data.reference])
					else: render_block(_new_block_data))
	
	for _b: Node in $Base/Box.get_children():
		if !is_instance_valid(_b): continue
		if _b is Button:
			var _t = create_tween()
			_t.tween_property(_b, "modulate:a", 1.0, 0.2)
			await get_tree().create_timer(0.07).timeout

func _set_buttons_enabled(state: bool) -> void:
	for _n in $Base/Box.get_children():
		if _n is Button:
			_n.disabled = !state

func open() -> void:
	Global.can_move = false
	Global.dialogue_open = true
	Global.action_cam_disable.emit()
	
	$PlayDialogue.play()
	if "_entry" in data:
		render_block(data._entry)
	if "_texture" in data:
		$Base/Sticker.texture = load(
			"res://generic/textures/stickers/" + str(data._texture) + ".png")
	
	$Player.play("Enter")
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_val, -1.0, 1.0, 0.3)

func close() -> void:
	if has_closed: return
	has_closed = true
	
	# Fade buttons out one-by-one
	for _b: Node in $Base/Box.get_children():
		if !is_instance_valid(_b): continue
		if _b is Button:
			var _t = create_tween()
			_t.tween_property(_b, "modulate:a", 0.0, 0.1)
			await get_tree().create_timer(0.03).timeout
	
	closed.emit()
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_val, 1.0, -1.0, 0.3)
	
	await fade_tween.finished
	await get_tree().process_frame
	Global.dialogue_open = false
	Global.can_move = true
	Global.action_cam_enable.emit()
	queue_free()

func _ready() -> void:
	$Base.modulate.a = 1.0

func _process(_delta: float) -> void:
	if Global.camera_orbiting:
		if !camera_last_orbiting:
			camera_last_orbiting = true
			_set_buttons_enabled(false)
	else:
		if camera_last_orbiting:
			camera_last_orbiting = false
			_set_buttons_enabled(true)

func _on_done_button_down() -> void:
	close()
