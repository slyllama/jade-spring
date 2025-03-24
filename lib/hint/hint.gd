class_name HintPanel extends Panel

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
			_text += ("[color=#ffc573][u]("
				+ Utilities.get_binding_str(_t.replace("@", ""))
				+ ")[/u][/color]")
		else: _text += _t
	$VBox/Body.text = _text

func close() -> void:
	var fade_out = create_tween()
	fade_out.tween_method(_set_dissolve, 1.0, 0.0, 0.3)
	await fade_out.finished
	queue_free()

func _ready() -> void:
	var _mat = material.duplicate(true)
	material = _mat # unique material
	
	await get_tree().process_frame
	var fade_in = create_tween()
	fade_in.tween_method(_set_dissolve, 0.0, 1.0, 0.3)

func _on_close_button_button_down() -> void:
	Global.click_sound.emit()
	close()
