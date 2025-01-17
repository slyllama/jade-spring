extends "res://lib/ui_container/ui_container.gd"

const QuitConfirmation = preload("res://lib/hud/quit_confirmation/quit_confirmation.tscn")
var qc

func open(silent = false) -> void:
	super(silent)
	$Container/Done.grab_focus()
	Global.settings_open = true
	Global.action_cam_disable.emit()

func close() -> void:
	Global.settings_open = false
	Global.action_cam_enable.emit()
	if qc != null:
		qc.queue_free()
	SettingsHandler.save_to_file()
	super()

func _input(event: InputEvent) -> void:
	super(event)
	if Input.is_action_just_pressed("ui_cancel"):
		if is_open:
			await get_tree().process_frame
			close()

func _ready() -> void:
	super()
	var _scroll_bar: VScrollBar = $Container/SC.get_v_scroll_bar()
	_scroll_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	# Volume needs to be set independently because its setting update isn't
	# pinged on start (to prevent an awkward spike in volume)
	$Container/SC/Contents/Volume.set_value_silent(Utilities.get_user_vol())
	
	SettingsHandler.setting_changed.connect(func(_param):
		if _param == "fov":
			var _fov = SettingsHandler.settings.fov
			$Container/SC/Contents/FOV/Title.text = "FOV (" + str(SettingsHandler.get_fov_deg()) + "):")

func _on_save_press() -> void:
	close()

func _on_quit_button_down() -> void:
	if !Global.in_exclusive_ui:
		AudioServer.set_bus_volume_db(0, -80)
		Global.command_sent.emit("/savedata")
		close()
		get_tree().change_scene_to_file("res://lib/main_menu/main_menu.tscn")
