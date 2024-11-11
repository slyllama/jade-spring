@tool
class_name Crumb extends Area3D
const FishingInstance = preload("res://lib/fishing/fishing.tscn")

var cursor_in_crumb = false
signal cleared

func clear() -> void:
	cleared.emit()
	queue_free()

func _ready() -> void:
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius *= 2.0
	collision.shape = shape
	add_child(collision)
	
	area_entered.connect(func(area):
		if area is CursorArea:
			cursor_in_crumb = true)
	
	area_exited.connect(func(area):
		if area is CursorArea:
			cursor_in_crumb = false)

func _process(_delta: float) -> void:
	if cursor_in_crumb:
		if Input.is_action_just_pressed("left_click"):
			var _f = FishingInstance.instantiate()
			_f.completed.connect(clear)
			add_child(_f)
