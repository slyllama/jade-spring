@tool
extends CanvasLayer

var x_offset = 0.0
var y_offset = 0.0

var bg_x_offset_intensity = 24.0
var bg_x_offset = 0.0
var bg_y_offset_intensity = 9.0
var bg_y_offset = 0.0

@onready var jade_bot = $JBWorldBox/JBWorld/MainMenu3D/JadeBot

# Resize and center the BG
func _position_bg(update_scale = false) -> void:
	$BG.position = Vector2(
		get_window().size.x / 2.0 - bg_x_offset,
		get_window().size.y / 2.0 - bg_y_offset)
	
	if update_scale:
		var _bg_width: float = $BG.texture.get_width() # BG width
		var _window_width: float  = get_window().size.x # window width
		var _relative_scale: float = _window_width / _bg_width
		$BG.scale = Vector2(_relative_scale, _relative_scale)

func _ready():
	_position_bg(true)
	
	if Engine.is_editor_hint(): return
	$Splash.visible = true
	
	for _n in Utilities.get_all_children($Buttons):
		if _n is BaseButton:
			_n.button_down.connect(func(): Global.click_sound.emit())
	
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
	)
	
	get_window().size_changed.connect(func():
		_position_bg(true))
	
	SettingsHandler.refresh()
	Utilities.set_master_vol()
	$Buttons/Play.grab_focus()
	
	var _splash_fade = create_tween()
	_splash_fade.tween_property($Splash, "modulate:a", 0.0, 0.35)
	await _splash_fade.finished
	$Splash.queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	var _mouse_pos = get_window().get_mouse_position()
	x_offset = _mouse_pos.x / get_window().size.x * 2 - 1
	y_offset = _mouse_pos.y / get_window().size.y * 2 - 1
	
	# Parallax-move the background and jade bot
	bg_x_offset = lerp(bg_x_offset, x_offset * bg_x_offset_intensity, delta * 2)
	bg_y_offset = lerp(bg_y_offset, y_offset * bg_y_offset_intensity, delta * 2)
	jade_bot.position.x = lerp(jade_bot.position.x, x_offset * -0.2 + 0.05, delta * 2)
	jade_bot.position.y = lerp(jade_bot.position.y, y_offset * -0.03 + 0.25, delta * 2)
	
	# Apply movement to BG
	_position_bg()

func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://lib/loader/loader.tscn")

func _on_settings_button_down() -> void:
	$SettingsPane.open()
