extends Panel

const DesignSlot = preload("res://lib/builds/design_handler/design_slot/design_slot.tscn")

signal closed

func _set_dissolve(val):
	var _i = 4.0 - val * 4.0
	material.set_shader_parameter("paint_exponent", _i)

# Repopulate pane with accurate data
func update() -> void:
	for _i in $VBox/Scroll/SlotsRoot.get_children(): _i.queue_free()
	for _d in Global.design_handler.get_slots():
		var _design_name: String = _d.replace(".dat", "")
		var _ds = DesignSlot.instantiate()
		_ds.design_name = _design_name
		$VBox/Scroll/SlotsRoot.add_child(_ds)
		
		_ds.activated.connect(func():
			Global.design_handler.create_design_slot()
			await get_tree().process_frame
			Global.design_handler.load_slot(_ds.design_name)
			update())
		
		_ds.slot_renamed.connect(func(_new_name):
			if _ds.design_name == SettingsHandler.settings.current_design:
				SettingsHandler.update("current_design", _new_name)
				SettingsHandler.save_to_file()
			Global.design_handler.rename_slot(_ds.design_name, _new_name)
			await get_tree().process_frame
			update())
		
		_ds.slot_deleted.connect(update)

func open() -> void:
	Global.design_pane_open = true
	#Global.in_exclusive_ui = true
	Global.design_handler.create_design_slot()
	
	$PaperSound.play()
	Global.dismiss_hints()
	var _fade_tween = create_tween()
	_fade_tween.tween_method(_set_dissolve, 0.0, 1.0, 0.1)
	
	update()

func close() -> void:
	Global.design_pane_open = false
	Global.in_exclusive_ui = false
	closed.emit()
	var _fade_tween = create_tween()
	_fade_tween.tween_method(_set_dissolve, 1.0, 0.0, 0.1)
	_fade_tween.tween_callback(queue_free)

func _ready() -> void:
	get_window().files_dropped.connect(func(file):
		var _data = Global.deco_handler._load_decoration_file(file[0])
		if _data != []: # only update if the data is valid
			Global.design_handler.create_custom_file(file[0])
			update()
		else: Global.announcement_sent.emit("Invalid design file."))
	
	for _n in Utilities.get_all_children(self):
		if _n is Control: _n.use_parent_material = true
	
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
	var _text_value = $VBox/NewSlotBoxContainer/NewSlotBox/SlotNameInput.text.replace(" ", "_")
	if _text_value != "":
		var _new_slot = Global.design_handler.return_valid_name(_text_value)
		Global.design_handler.create_design_slot(_new_slot)
		await get_tree().process_frame
		Global.design_handler.load_slot(_new_slot)
		update()
		
		$VBox/NewSlotBoxContainer/NewSlotBox/SlotNameInput.text = ""
