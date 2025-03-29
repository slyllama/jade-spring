@tool
extends TextureRect

@export_range(0.0, 1.0) var dissolve_value = 1.0:
	get: return(dissolve_value)
	set(value):
		_set_dissolve_value(value)
		dissolve_value = value

# 0 is full dissolve; 1 is no dissolve
func _set_dissolve_value(value: float):
	material.set_shader_parameter("alpha", ease(value, 0.2))
	var _exp = (1.0 - ease(value, 2.0)) * 4.0
	material.set_shader_parameter("paint_exponent", _exp)

func open() -> void:
	if Engine.is_editor_hint():
		return
	
	$PaperSound.play()
	# Convince gadgets that this is a story panel so that they can't be hovered
	Global.summon_story_panel.emit({})
	Global.action_cam_disable.emit()
	Global.story_panel_open = true
	var _fade = create_tween()
	_fade.tween_method(_set_dissolve_value, 0.0, 1.0, 0.2)

func close() -> void:
	Global.story_panel_open = false
	Global.close_story_panel.emit()
	Global.action_cam_enable.emit()
	
	var _fade = create_tween()
	_fade.tween_method(_set_dissolve_value, 1.0, 0.0, 0.2)
	_fade.tween_callback(queue_free)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Global.in_exclusive_ui = true
		await get_tree().process_frame
		close()
		Global.in_exclusive_ui = false

func _ready() -> void:
	Global.settings_pane_opened.connect(close)
	
	dissolve_value = 1.0
	open()

func _on_close_button_button_down() -> void:
	Global.click_sound.emit()
	close()

# Can't orbit when dragging through UI
func _on_mouse_entered() -> void:
	Global.in_exclusive_ui = true
func _on_mouse_exited() -> void:
	Global.in_exclusive_ui = false
