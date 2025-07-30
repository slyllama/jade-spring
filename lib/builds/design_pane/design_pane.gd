extends Panel

signal closed

func _set_dissolve(val):
	var _i = 4.0 - val * 4.0
	material.set_shader_parameter("paint_exponent", _i)

# Repopulate pane with accurate data
func update() -> void:
	$VBox/Debug.text = "Current design: " + SettingsHandler.settings.current_design

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
	Global.design_handler.get_slots()
