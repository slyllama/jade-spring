@tool
extends HBoxContainer
# SettingsSlider

@export var title = "Setting":
	get():
		return(title)
	set(_v):
		title = _v
		$Title.text = title + ":"
@export var id: String

func _ready() -> void:
	$Title.text = title + ":"
	if Engine.is_editor_hint(): return
	
	SettingsHandler.setting_changed.connect(func(parameter):
		if id == parameter:
			$Slider.value = float(SettingsHandler.settings[parameter] * 100))

func _on_slider_value_changed(value: float) -> void:
	if id in SettingsHandler.settings:
		SettingsHandler.update(id, value * 0.01)
