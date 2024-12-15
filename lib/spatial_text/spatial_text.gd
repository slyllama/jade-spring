extends VisibleOnScreenNotifier3D
# SpatialText
# Shows text (and other things) attached to a gizmo or crumb

const TRANS_TIME = 0.2
var in_range = true

@export var spatial_string = "((Untitled))":
	get:
		return(spatial_string)
	set(_val):
		spatial_string = _val
		_set_title(_val)
@export var color = "white"

func _set_title(title: String) -> void:
	$FG/Title.text = "[center][color=" + color + "]" + title + "[/color][/center]"

func _get_in_bounds(_pos: Vector2) -> bool:
	var _in_bounds = true
	if (_pos.x < 0 or _pos.x > get_window().size.x
		or _pos.y < 0 or _pos.y > get_window().size.y):
		_in_bounds = false
	return(_in_bounds)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_hud"):
		$FG.visible = !$FG.visible

func _ready() -> void:
	$FG/Underlay.queue_free()
	_set_title(spatial_string)

func _process(_delta: float) -> void:
	var _unp = Global.camera.unproject_position(global_position)
	if visible and is_on_screen() and _get_in_bounds(_unp):
		if !$FG/Title.visible:
			$FG/Title.visible = true
		$FG/Title.position = _unp
		$FG/Title.position.x -= 100.0
	else:
		if $FG/Title.visible:
			$FG/Title.visible = false
	
	if global_position.distance_to(Global.player_position) > 5.8:
		if in_range:
			in_range = false
			var _ft = create_tween() # fade tween
			_ft.tween_property($FG/Title, "modulate:a", 0.0, TRANS_TIME)
	else:
		if !in_range:
			in_range = true
			var _ft = create_tween() # fade tween
			_ft.tween_property($FG/Title, "modulate:a", 1.0, TRANS_TIME)
