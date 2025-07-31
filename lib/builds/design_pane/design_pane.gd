extends Panel

signal closed

func _set_dissolve(val):
	var _i = 4.0 - val * 4.0
	material.set_shader_parameter("paint_exponent", _i)

# Repopulate pane with accurate data
func update() -> void:
	$VBox/Debug.text = "Current design: " + SettingsHandler.settings.current_design
	for _i in $VBox/SlotsRoot.get_children(): _i.queue_free()
	for _d in Global.design_handler.get_slots():
		var _b = Button.new()
		var _design_name = _d.replace(".dat", "")
		_b.text = _design_name
		_b.button_down.connect(func():
			Global.click_sound.emit()
			Global.design_handler.create_design_slot()
			
			await get_tree().process_frame
			Global.design_handler.load_slot(_design_name)
			update())
		$VBox/SlotsRoot.add_child(_b)

func open() -> void:
	$PaperSound.play()
	Global.dismiss_hints()
	var _fade_tween = create_tween()
	_fade_tween.tween_method(_set_dissolve, 0.0, 1.0, 0.1)
	
	update()

func close() -> void:
	closed.emit()
	var _fade_tween = create_tween()
	_fade_tween.tween_method(_set_dissolve, 1.0, 0.0, 0.1)
	_fade_tween.tween_callback(queue_free)

func _ready() -> void:
	Global.vault_left.connect(close)
	open()

func _on_close_button_up() -> void:
	Global.click_sound.emit()
	close()

func _on_mouse_entered() -> void: Global.mouse_in_ui = true
func _on_mouse_exited() -> void: Global.mouse_in_ui = false

func _on_test_get_slots_button_down() -> void:
	update()

func _on_test_save_slot_button_down() -> void:
	Global.design_handler.create_design_slot(SettingsHandler.settings.current_design)
	update()

func _on_test_new_slot_button_down() -> void:
	Global.design_handler.create_design_slot($VBox/NewSlotBox/SlotNameInput.text.replace(" ", "_"))
	update()
