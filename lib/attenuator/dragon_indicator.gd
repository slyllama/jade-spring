extends Sprite2D

signal reveal_complete

func _set_paint_value(val: float) -> void:
	material.set_shader_parameter("dissolve_value", val)

func _set_color(color: Color) -> void:
	material.set_shader_parameter("color", color)

func reveal(current_dragon: String) -> void:
	#_set_color(Utilities.DRAGON_DATA[current_dragon].color)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(
		self, "scale", Vector2(0.5, 0.5), 0.12).set_ease(Tween.EASE_IN_OUT)
	
	var paint_tween = create_tween()
	paint_tween.tween_method(
		_set_paint_value, 0.0, 1.0, 0.12)
	paint_tween.set_parallel()
	
	var text_fade = create_tween()
	text_fade.tween_property($TextContents, "modulate:a", 1.0, 0.12)
	text_fade.set_parallel()
	
	reveal_complete.emit()

func _ready() -> void:
	$TextContents.modulate.a = 0.0
	var _mat = material.duplicate(true)
	material = _mat
	_set_paint_value(0.0)
