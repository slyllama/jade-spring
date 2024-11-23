extends "res://lib/ui_container/ui_container.gd"

const QuitConfirmation = preload("res://lib/hud/quit_confirmation/quit_confirmation.tscn")
var qc

func close() -> void:
	if qc != null:
		qc.queue_free()
	SettingsHandler.save_to_file()
	super()

func _input(event: InputEvent) -> void:
	super(event)
	if Input.is_action_just_pressed("ui_cancel"):
		if !is_open:
			await get_tree().process_frame
			open()
		else:
			await get_tree().process_frame
			close()

func _ready() -> void:
	super()
	# Volume needs to be set independently because its setting update isn't
	# pinged on start (to prevent an awkward spike in volume)
	$Container/Volume.set_value_silent(Utilities.get_user_vol())

func _on_save_press() -> void:
	close()

func _on_quit_button_down() -> void:
	if !Global.in_exclusive_ui:
		close()
		get_tree().quit() # TODO: temporarily allowing for instant closing
		#if qc != null:
			#qc.queue_free()
		#qc = QuitConfirmation.instantiate()
		#add_child(qc)
