extends VisibleOnScreenNotifier3D
# SpatialText
# Shows text (and other things) attached to a gizmo or crumb

@export var spatial_string = "((Untitled))":
	get:
		return(spatial_string)
	set(_val):
		spatial_string = _val
		_set_title(_val)

func _set_title(title: String) -> void:
	$FG/Title.text = "[center]" + title + "[/center]"

func _get_in_bounds(_pos: Vector2) -> bool:
	var _in_bounds = true
	if (_pos.x < 0 or _pos.x > get_window().size.x
		or _pos.y < 0 or _pos.y > get_window().size.y):
		_in_bounds = false
	return(_in_bounds)

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
		visible = false
	else:
		visible = true
