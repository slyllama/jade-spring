class_name HintPanel extends Panel

var can_close = false
var has_closed = false

func _set_dissolve(value: float) -> void:
	material.set_shader_parameter("paint_exponent", (1.0 - ease(value, 0.2)) * 10.0)

func set_text(data: Dictionary) -> void:
	$VBox/Header/Title.text = "[center]" + data.title + "[/center]"
	var _tokens = []
	var _flip = false
	var _token = ""
	
	if "anchor_preset" in data:
		set_anchors_preset(data.anchor_preset)
	
	if "arrow" in data:
		if data.arrow == "left":
			$Arrow_W.visible = true
		elif data.arrow == "right":
			$Arrow_E.visible = true
		elif data.arrow == "up":
			$Arrow_N.visible = true
		elif data.arrow == "down":
			$Arrow_S.visible = true
	
	for _c in data.text:
		if _c == "|":
			_tokens.append(_token)
			_token = ""
			if !_flip: _token += "@" # reached the first pipe
			_flip = !_flip # flip either way
		else: _token += _c
	_tokens.append(_token)
	
	var _text = ""
	for _t in _tokens:
		if _t[0] == "@": # this is an input binding token
			_text += Utilities.format_binding(
				Utilities.get_binding_str(_t.replace("@", "")))
		else: _text += _t
	$VBox/Body.text = _text

func close() -> void:
	if has_closed: # prevent from closing twice
		return
	else:
		has_closed = true
	
	var fade_out = create_tween()
	fade_out.tween_method(_set_dissolve, 1.0, 0.0, 0.3)
	await fade_out.finished
	queue_free()

func _input(_event: InputEvent) -> void:
	if !can_close: return
	if Input.is_action_just_pressed("right_click"):
		close()

func _ready() -> void:
	var _mat = material.duplicate(true)
	material = _mat # unique material
	
	$Flash.visible = true
	await get_tree().process_frame
	
	var fade_in = create_tween()
	fade_in.tween_method(_set_dissolve, 0.0, 1.0, 0.3)
	var flash_out = create_tween()
	flash_out.tween_property($Flash, "modulate:a", 0.0, 0.3)
	flash_out.set_parallel()
	
	await fade_in.finished
	can_close = true

func _on_close_button_button_down() -> void:
	if !can_close: return
	Global.click_sound.emit()
	close()

func _on_dismiss_button_down() -> void:
	if !can_close: return
	Global.click_sound.emit()
	close()
