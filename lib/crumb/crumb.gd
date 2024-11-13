@tool
class_name Crumb extends Area3D
const FishingInstance = preload("res://lib/fishing/fishing.tscn")

var cursor_in_crumb = false
signal cleared

func clear() -> void:
	cleared.emit()
	queue_free()

func _input(_event: InputEvent) -> void:
	if Global.current_crumb != self or Global.in_exclusive_ui: return
	if Input.is_action_just_pressed("interact"):
		if Global.tool_mode == Global.TOOL_MODE_NONE:
			var _f = FishingInstance.instantiate()
			_f.completed.connect(clear)
			add_child(_f)

func _ready() -> void:
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius *= 2.0
	collision.shape = shape
	add_child(collision)
	
	body_entered.connect(func(body):
		if body is CharacterBody3D:
			await get_tree().process_frame
			Global.current_crumb = self)
	
	body_exited.connect(func(body):
		if body is CharacterBody3D:
			Global.current_crumb = null)
	
	area_entered.connect(func(area):
		if area is CursorArea:
			cursor_in_crumb = true)
	
	area_exited.connect(func(area):
		if area is CursorArea:
			cursor_in_crumb = false)

#func _process(_delta: float) -> void:
	#if cursor_in_crumb:
		#if Input.is_action_just_pressed("left_click"):
			#var _f = FishingInstance.instantiate()
			#_f.completed.connect(clear)
			#add_child(_f)
