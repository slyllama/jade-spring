@tool
class_name Crumb extends Area3D
const FishingInstance = preload("res://lib/fishing/fishing.tscn")

@export var type := "bug"
@export var area_radius := 1.2
@export var interact_when_proximal := true
@export var can_click := false
@export var area_height = 8.0
@export var custom_data = "" # used for things like Dragonvoid (Elder Dragon assignment)

var cursor_in_crumb = false
signal cleared
signal interacted

func process_custom_data() -> void:
	pass
	# This is called by the CrumbHandler once it has loaded everything, so you
	# can guarantee that custom data exists at this point.

func clear() -> void:
	if type == "bug":
		Global.spawn_karma.emit(Global.kv_bug, global_position)
	elif type == "dragonvoid":
		Global.spawn_karma.emit(Global.kv_dragonvoid, global_position)
	
	Global.current_crumb = null
	Global.crumbs_updated.emit()
	cleared.emit()
	queue_free()

func _input(_event: InputEvent) -> void:
	if !interact_when_proximal: return
	if custom_data == "ignore": return
	if Global.current_crumb != self or Global.in_exclusive_ui: return
	if Input.is_action_just_pressed("interact"):
		if Global.tool_mode == Global.TOOL_MODE_NONE:
			interacted.emit()

func _ready() -> void:
	if !can_click:
		input_ray_pickable = false
	
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = area_radius
	shape.height = area_height
	collision.shape = shape
	add_child(collision)
	
	if Engine.is_editor_hint(): return
	
	Global.summon_story_panel.connect(func(_data):
		if overlaps_body(Global.player):
			await get_tree().process_frame
			Global.current_crumb = null)
	
	Global.close_story_panel.connect(func():
		if overlaps_body(Global.player):
			Global.current_crumb = self)
	
	body_entered.connect(func(body):
		if Global.story_panel_open: return
		if body is CharacterBody3D:
			await get_tree().process_frame
			Global.current_crumb = self)
	
	body_exited.connect(func(body):
		if Global.story_panel_open: return
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
