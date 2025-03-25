@tool
extends HBoxContainer
# SettingsDropdown
# Multi-choice options in the settings menu!

@export var title = "Setting":
	get():
		return(title)
	set(_v):
		title = _v
		$Title.text = title + ":"
@export var id: String
@export var options: Array[String]
@export var default_option = ""
@onready var selected_option = default_option
@export var info_tooltip = ""

func _parse_id(id: String) -> String:
	return(id.capitalize().replace("Msaa", "MSAA").replace("Fxaa", "FXAA"))

# Update displayed value
func _refresh() -> void:
	$Menu.text = _parse_id(str(selected_option))

func _ready() -> void:
	if info_tooltip != "" and info_tooltip:
		$Info.tooltip_text = info_tooltip
		$Info.visible = true
	$Title.text = title + ":"
	
	if Engine.is_editor_hint(): return
	
	# Populate based on exported variables and refresh
	for option in options:
		$Menu.get_popup().add_item(_parse_id(str(option)))
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
