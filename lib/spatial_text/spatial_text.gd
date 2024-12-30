extends VisibleOnScreenNotifier3D
# SpatialText
# Shows text (and other things) attached to a gizmo or crumb

const TRANS_TIME = 0.2
var in_range = true

var hud_visible = true # is the HUD display toggled (F4)?
var settings_visibility = true # are the labels enabled in settins?

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

func _settings_toggle_visibility() -> void:
	var _value = SettingsHandler.settings.labels
	if _value == "show":
		settings_visibility = true
		if hud_visible:
			$FG.visible = true
	elif _value == "hide":
		settings_visibility = false
		$FG.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_hud"):
		hud_visible = !hud_visible
		if hud_visible and settings_visibility:
			visible = true
		if !hud_visible:
			visible = false

func _ready() -> void:
	$FG/Underlay.queue_free()
	_set_title(spatial_string)
	
	SettingsHandler.setting_changed.connect(func(parameter):
		if parameter == "labels": _settings_toggle_visibility())
	
	await get_tree().process_frame
	_settings_toggle_visibility()

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
