class_name LangRichTextLabel extends RichTextLabel

@export var string_translation: StringTranslation
@onready var original_text = text

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Language.language_changed.connect(func(_lang):
		if _lang == Language.Languages.ENGLISH:
			text = original_text
			return
		
		if !string_translation: return
		
		if _lang == string_translation.language:
			text = string_translation.translation)
