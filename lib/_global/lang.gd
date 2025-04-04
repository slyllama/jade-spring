extends Node

enum Languages { TOKI_PONA, ENGLISH }

signal language_changed(lang)

# Master translation file

const toki_pona = {
	"Continue": "open e musi"
}

func _ready() -> void:
	SettingsHandler.setting_changed.connect(func(_param):
		if _param == "language":
			var _lang = SettingsHandler.settings.language
			if _lang == "toki_pona": Language.language_changed.emit(Languages.TOKI_PONA)
			else: Language.language_changed.emit(Languages.ENGLISH)
	)
