@tool
extends HBoxContainer
# SettingsSlider

@onready var title_text = $Title.text

@export var title_translation: StringTranslation:
	get: return(title_translation)
	set(_t):
		if !_t: return
		title_translation = _t
		$Title.string_translation = _t

@export var title = "Setting":
	get():
		return(title)
	set(_v):
		title = _v
		$Title.text = title + ":"
@export var id: String

func set_value_silent(value: float) -> void:
	$Slider.set_value_no_signal(value * 100)

func _ready() -> void:
	$Title.text = title + ":"
	if Engine.is_editor_hint(): return
	
	SettingsHandler.setting_changed.connect(func(parameter):
		if id == parameter:
			$Slider.value = float(SettingsHandler.settings[parameter] * 100))
	
	Language.language_changed.connect(func(_lang):
		title_text = $Title.text)

func _on_slider_value_changed(value: float) -> void:
	if id in SettingsHandler.settings:
		SettingsHandler.update(id, value * 0.01)
