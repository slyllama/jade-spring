@tool
extends Node2D

const SPIN_RATE = 0.4
var spin_rate = SPIN_RATE
var target_alpha = 1.0

signal anim_out_complete

@export var test_animation = false:
	get: return(test_animation)
	set(_val):
		anim_in()
		test_animation = false

@export var anim_duration = 0.35

func _set_spin_rate_ratio(ratio: float) -> void:
	spin_rate = SPIN_RATE * ratio

func anim_in(set_target_alpha = 1.0) -> void: # animate in
	target_alpha = set_target_alpha
	modulate.a = 0.0
	visible = true
	
	scale = Vector2(1.2, 1.2)
	var scale_tween = create_tween()
	scale_tween.tween_property(
		self, "scale", Vector2(0.5, 0.5), anim_duration
	).set_ease(Tween.EASE_IN_OUT)
	
	var spin_tween = create_tween()
	spin_tween.tween_method(
		_set_spin_rate_ratio, 11.0, 1.0, anim_duration
	).set_ease(Tween.EASE_IN_OUT)
	spin_tween.set_parallel()
	
	var mod_tween = create_tween()
	mod_tween.tween_property(
		self, "modulate:a", target_alpha, anim_duration
	).set_ease(Tween.EASE_IN_OUT)
	mod_tween.set_parallel()

func anim_out() -> void: # animate in
	modulate.a = 1.0
	
	var scale_tween = create_tween()
	scale_tween.tween_property(
		self, "scale", Vector2(1.2, 1.2), anim_duration
	).set_ease(Tween.EASE_IN_OUT)
	
	var mod_tween = create_tween()
	mod_tween.tween_property(
		self, "modulate:a", 0.0, anim_duration
	).set_ease(Tween.EASE_IN_OUT)
	mod_tween.set_parallel()
	
	await get_tree().create_timer(anim_duration).timeout
	anim_out_complete.emit()

func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = false

func _process(delta: float) -> void:
	$InnerCircle.rotation += delta * spin_rate
	$OuterCircle.rotation += delta * spin_rate * -0.5
