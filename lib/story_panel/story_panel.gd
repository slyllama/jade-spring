extends CanvasLayer

var closed = false # prevent double interactions

func _set_shader_value(val: float) -> void: # 0-1
	var _e = ease(val, 0.2)
	$Base.material.set_shader_parameter("paint_mask_exponent", (1 - _e) * 10)

func open(title = "((Title))", description = "((Description))"):
	$Base/Content/Title.text = "[center]" + title + "[/center]"
	# Includes shortcuts for second paragraph
	$Base/Content/Description.text = description.replace("<", "\n[font_size=9] [/font_size]\n[color=white]").replace(">", "[/color]")
	#$PlayDialogue.play()
	
	Global.story_panel_open = true
	Global.action_cam_disable.emit()
	
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_shader_value, 0.0, 1.0, 0.27)
	var content_fade_tween = create_tween()
	content_fade_tween.tween_property($Base/Content, "modulate:a", 1.0, 0.27)
	content_fade_tween.set_parallel()
	
	for _i in 2: # wait for command line to process
		await get_tree().process_frame
	
	await get_tree().create_timer(0.1).timeout
	$JadeWingsBase/JadeAnim.play("float")

func play_building_hint() -> void:
	Global.play_hint("building", { 
		"title": "Building Unlocked",
		"arrow": "down",
		"anchor_preset": Control.LayoutPreset.PRESET_CENTER_BOTTOM,
		"text": "You can now build! Experiment with unlocked skills to decorate."
	}, Utilities.get_screen_center(Vector2(0, get_viewport().size.y / Global.retina_scale * 0.5 - 300)), true)

func close():
	if closed: return # should only happen once
	closed = true
	
	if Save.data.story_point == "game_start":
		Global.play_hint("movement", { 
				"title": "Jade Bot Movement",
				"arrow": "down",
				"anchor_preset": Control.LayoutPreset.PRESET_CENTER,
				"text": "Use |move_forward|, |move_back|, |move_left|, and |move_right| to move and direct your Jade Bot. Ascend with |move_up| and descend with |move_down|. Use |interact| to interact with objects you are close to!"
			}, Utilities.get_screen_center(Vector2(0, -100)), true)
	
	elif Save.data.story_point == "ratchet_gratitude":
		play_building_hint()
	
	Global.story_panel_open = false
	Global.close_story_panel.emit()
	
	# Do closing stuff
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_shader_value, 1.0, 0.0, 0.27)
	var content_fade_tween = create_tween()
	content_fade_tween.tween_property($Base/Content, "modulate:a", 0.0, 0.27)
	content_fade_tween.set_parallel()
	$Paper.play()
	$JadeWingsBase/JadeAnim.play_backwards("float")
	
	await fade_tween.finished
	Global.action_cam_enable.emit()
	queue_free()

func _ready() -> void:
	$Base/Content.modulate.a = 0.0
	$JadeWingsBase/JadeWings.modulate.a = 0.0
	$JadeWingsBase/JadeWings.position.y = 10.0
	$Base/Content/Done.grab_focus()
	
	Global.settings_pane_opened.connect(close)

func _process(_delta: float) -> void:
	$JadeWingsBase.global_position = (
		get_window().size / 2.0 * (1.0 / Global.retina_scale) + Vector2(0, -200))

func _on_content_mouse_entered() -> void:
	Global.in_exclusive_ui = true
func _on_content_mouse_exited() -> void:
	Global.in_exclusive_ui = false
