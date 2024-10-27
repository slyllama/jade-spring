extends HBoxContainer
# SettingsDropdown
# Multi-choice options in the settings menu!

@export var title = "Setting"
@export var id: String
@export var options: Array[String]
@export var default_option = ""
@onready var selected_option = default_option

# Update displayed value
func _refresh() -> void:
	$Menu.text = str(selected_option).capitalize()

func _ready() -> void:
	$Title.text = title + ":"
	
	# Populate based on exported variables and refresh
	for option in options:
		$Menu.get_popup().add_item(str(option).capitalize())
	_refresh()
	
	# Update settings (and display) when an option is selected from the list
	$Menu.get_popup().id_pressed.connect(func(n):
		selected_option = options[n]
		SettingsHandler.update(id, selected_option)
		_refresh())
	
	# Let the game know the popup has been closed (especially for CameraHandler)
	$Menu.get_popup().visibility_changed.connect(func():
		if !$Menu.get_popup().visible: Global.popup_open = false)

	# Update when a setting is changed/established (correctly populates the field
	# when the game is started, for instance)
	SettingsHandler.setting_changed.connect(func(parameter):
		if id == parameter:
			selected_option = SettingsHandler.settings[parameter]
			_refresh())

func _on_menu_about_to_popup() -> void:
	Global.popup_open = true
