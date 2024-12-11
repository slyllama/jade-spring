@tool
class_name Crumb extends Area3D
const FishingInstance = preload("res://lib/fishing/fishing.tscn")

@export var type := "bug"
@export var area_radius := 1.2
@export var interact_when_proximal := true
@export var can_click := false

var cursor_in_crumb = false
signal cleared
signal interacted

func clear() -> void:
	#if type in Save.data.crumb_data:
		#Save.data.crumb_data[type].count -= 1
	
	Global.current_crumb = null
	Global.crumbs_updated.emit()
	cleared.emit()
	queue_free()

func _input(_event: InputEvent) -> void:
	if !interact_when_proximal: return
	if Global.current_crumb != self or Global.in_exclusive_ui: return
	if Input.is_action_just_pressed("interact"):
		if Global.tool_mode == Global.TOOL_MODE_NONE:
			interacted.emit()

func _ready() -> void:
	if !can_click:
		input_ray_pickable = false
	
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = area_radius
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

func _process(_delta: float) -> void:
	if can_click and cursor_in_crumb:
		if Input.is_action_just_pressed("left_click"):
			interacted.emit()
