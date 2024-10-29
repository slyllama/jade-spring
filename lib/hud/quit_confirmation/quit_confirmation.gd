extends Panel

const TRANS_TIME = 0.11

func close():
	Global.click_sound.emit()
	$Box/Buttons/Cancel.release_focus()
	
	$Box/Buttons/Quit.disabled = true
	$Box/Buttons/Cancel.disabled = true
	
	var close_tween = create_tween()
	close_tween.tween_property(self, "modulate:a", 0, TRANS_TIME)
	close_tween.tween_callback(queue_free)

func _ready() -> void:
	modulate.a = 0.0
	var open_tween = create_tween()
	open_tween.tween_property(self, "modulate:a", 1.0, TRANS_TIME)

func _on_mouse_entered() -> void:
	Global.mouse_in_ui = true

func _on_mouse_exited() -> void:
	Global.mouse_in_ui = false

func _on_cancel_button_down() -> void:
	close()

func _on_quit_button_down() -> void:
	var vol_tween = create_tween()
	vol_tween.tween_method(Utilities.set_master_vol, Utilities.get_user_vol(), 0.0, 0.3)
	await vol_tween.finished
	get_tree().quit()
