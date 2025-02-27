extends Sprite2D

func _set_paint_value(val: float) -> void:
	val = ease(val, -0.5)
	material.set_shader_parameter("dissolve_value", val)

func _set_color(color: Color) -> void:
	material.set_shader_parameter("color", color)

func reveal(current_dragon: String) -> void:
	_set_color(Utilities.DRAGON_DATA[current_dragon].color)
	
	scale = Vector2(0.8, 0.8)
	var scale_tween = create_tween()
	scale_tween.tween_property(
		self, "scale", Vector2(0.5, 0.5), 0.12).set_ease(Tween.EASE_IN_OUT)
	var paint_tween = create_tween()
	paint_tween.tween_method(
		_set_paint_value, 0.0, 1.0, 0.12).set_ease(Tween.EASE_IN_OUT)
	paint_tween.set_parallel()
	
	await get_tree().create_timer(1.7).timeout
	
	var scale_tween2 = create_tween()
	scale_tween2.tween_property(
		self, "scale", Vector2(0.8, 0.8), 0.32).set_ease(Tween.EASE_IN_OUT)
	var paint_tween2 = create_tween()
	paint_tween2.tween_method(
		_set_paint_value, 0.1, 0.0, 0.32).set_ease(Tween.EASE_IN_OUT)
	paint_tween2.set_parallel()

func _ready() -> void:
	_set_paint_value(0.0)
