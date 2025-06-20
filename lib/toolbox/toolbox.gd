extends CanvasLayer

var _eyedropper_last_used = false

func clear_skills(audio = true) -> void:
	if audio:
		$SkillSwap.play()
	for _b in $Box.get_children():
		if _b is SkillButton:
			_b.switch_skill("empty")

func set_default_skills(audio = true) -> void:
	var _p = Save.data.story_point
	
	clear_skills(audio)
	$Box/Skill1.switch_skill("select")
	$Box/Skill2.switch_skill("deco_test")
	$Box/Skill3.switch_skill("delete")
	$Box/Skill4.switch_skill("eyedropper")
	$Box/Skill5.switch_skill("toggle_gravity")
	$Box/Skill6.switch_skill("ping")
	
	# All skills are disable by default
	$Box/Skill1.set_enabled(false)
	$Box/Skill2.set_enabled(false)
	$Box/Skill3.set_enabled(false)
	$Box/Skill4.set_enabled(false)
	$Box/Skill5.set_enabled(false)
	$Box/Skill6.set_enabled(false)
	
	if Save.is_at_story_point("clear_bugs"):
		$Box/Skill1.set_enabled(false)
		$Box/Skill2.set_enabled(false)
		$Box/Skill3.set_enabled(false)
		$Box/Skill4.set_enabled(false)
		$Box/Skill5.set_enabled(false)
		$Box/Skill6.set_enabled(true)
	if Save.is_at_story_point("ratchet_gratitude"):
		$Box/Skill1.set_enabled()
		$Box/Skill2.set_enabled()
		$Box/Skill3.set_enabled()
		$Box/Skill4.set_enabled()
		$Box/Skill5.set_enabled()
		$Box/Skill6.set_enabled()
	
	if Global.override_lock_tools: # make all decorations available for debug testing
		$Box/Skill1.set_enabled()
		$Box/Skill2.set_enabled()
		$Box/Skill3.set_enabled()
		$Box/Skill4.set_enabled()
		$Box/Skill5.set_enabled()
		$Box/Skill6.set_enabled()
	
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.queued_decoration = "none"
	Global.set_cursor(false)

func get_button_by_id(id: String):
	for _n in $Box.get_children():
		if _n.id == id:
			return(_n)

var _cd := 0.0

func _input(_event: InputEvent) -> void:
	if Global.bindings_pane_open or Global.dragging: return
	if Global.popup_open or Global.dialogue_open: return
	if _cd <= 0.0:
		if Input.is_action_just_released("skill_1"):
			_cd = 0.1
			$Box/Skill1._on_button_up()
			return
		elif Input.is_action_just_released("skill_2"):
			_cd = 0.1
			$Box/Skill2._on_button_up()
			return
		elif Input.is_action_just_released("skill_3"):
			_cd = 0.1
			$Box/Skill3._on_button_up()
			return
		elif Input.is_action_just_released("skill_4"):
			_cd = 0.1
			$Box/Skill4._on_button_up()
			return
		elif Input.is_action_just_released("skill_5"):
			_cd = 0.1
			$Box/Skill5._on_button_up()
			return
		elif Input.is_action_just_released("skill_6"):
			_cd = 0.1
			$Box/Skill6._on_button_up()
			return

func _ready() -> void:
	Save.story_advanced.connect(func():
		$SkillSwap.volume_db = linear_to_db(0)
		set_default_skills(false)
		$SkillSwap.volume_db = linear_to_db(1)
	)
	
	Global.command_sent.connect(func(_c):
		if _c == "/unlocktools":
			Global.override_lock_tools = true
			set_default_skills(false))
	
	Global.summon_story_panel.connect(func(_data): clear_skills(false))
	Global.close_story_panel.connect(func(): set_default_skills(false))
	Global.dialogue_opened.connect(func(): clear_skills(false))
	Global.dialogue_closed.connect(func(): set_default_skills(false))
	
	Global.deco_placement_started.connect(func():
		clear_skills()
		$Box/Skill6.switch_skill("cancel")
		if !Global.mouse_3d_override_rotation and !_eyedropper_last_used:
			$Box/Skill1.switch_skill("rotate_left")
			$Box/Skill2.switch_skill("rotate_right")
		_eyedropper_last_used = false)
	
	Global.deco_deleted.connect(func():
		await get_tree().process_frame
		Global.command_sent.emit("/savedeco"))
	
	Global.deco_placement_canceled.connect(set_default_skills)
	
	Global.adjustment_started.connect(func():
		clear_skills()
		Global.adjustment_mode = Global.ADJUSTMENT_MODE_TRANSLATE
		$Box/Skill1.switch_skill("accept")
		if Global.deco_selection_array == []:
			$Box/Skill2.switch_skill("adjust_mode_rotate")
			Global.snapping = false
			if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
				$Box/Skill3.switch_skill("snap_enable")
			else:
				$Box/Skill3.switch_skill("snap_forbidden")
			$Box/Skill4.switch_skill("transform_mode")
			$Box/Skill5.switch_skill("reset_adjustment")
		$Box/Skill6.switch_skill("cancel"))
	
	Global.deco_sampled.connect(func(data):
		Global.set_cursor(false)
		_eyedropper_last_used = true
		await get_tree().process_frame
		Global.queued_decoration = data.id
		Global.tool_mode = Global.TOOL_MODE_PLACE
		Global.deco_placement_started.emit()
		Global.action_cam_disable.emit()
		
		Global.set_cursor(true, {
			"highlight_on_decoration": false,
			"custom_model": load(Global.DecoData[data.id].cursor_model),
			"rotation": data.rotation,
			"eyedrop_scale": data.eyedrop_scale
		})
	)
	
	Global.adjustment_canceled.connect(set_default_skills)
	
	Global.transform_mode_changed.connect(func(mode):
		Global.snapping = false # TODO: check
		if Global.tool_mode == Global.TOOL_MODE_ADJUST:
			if mode == Global.TRANSFORM_MODE_OBJECT:
				$Box/Skill3.switch_skill("snap_forbidden")
			elif mode == Global.TRANSFORM_MODE_WORLD:
				$Box/Skill3.switch_skill("snap_enable"))
	
	Global.fishing_started.connect(func():
		clear_skills()
		$Box/Skill1.switch_skill("fishing_left")
		$Box/Skill2.switch_skill("fishing_right")
		$Box/Skill6.switch_skill("cancel"))
	
	Global.fishing_canceled.connect(func():
		set_default_skills())
	
	$SkillSwap.volume_db = linear_to_db(0)
	await Global.shader_preload_complete
	set_default_skills()
	await $SkillSwap.finished
	$SkillSwap.volume_db = linear_to_db(1.0)

#region Skill button behaviour
func skill_used(skill_id: String) -> void:
	if !visible: return
	match skill_id:
		"delete": # delete a decoration - uses similar logic to 'select'
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_DELETE
				clear_skills()
				$Box/Skill3.switch_skill("delete")
				get_button_by_id("delete").set_highlight()
				Global.action_cam_disable.emit()
				Global.deco_deletion_started.emit()
				Global.selection_started.emit()
				Global.set_cursor()
			elif Global.tool_mode == Global.TOOL_MODE_DELETE:
				Global.tool_mode = Global.TOOL_MODE_NONE
				Global.action_cam_enable.emit()
				Global.deco_deletion_canceled.emit()
				Global.selection_canceled.emit()
				set_default_skills()
		"select":
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_SELECT
				Global.selection_started.emit()
				clear_skills()
				$Box/Skill1.switch_skill("select")
				$Box/Skill2.switch_skill("select_multiple")
				get_button_by_id("select").set_highlight()
				Global.action_cam_disable.emit()
				Global.set_cursor()
			elif (Global.tool_mode == Global.TOOL_MODE_SELECT
				or Global.tool_mode == Global.TOOL_MODE_EYEDROPPER):
				Global.tool_mode = Global.TOOL_MODE_NONE
				Global.selection_canceled.emit()
				Global.action_cam_enable.emit()
				set_default_skills()
		"select_multiple":
			clear_skills(false)
			$Box/Skill1.switch_skill("edit_selection")
			$Box/Skill2.switch_skill("duplicate_edit_selection")
			$Box/Skill6.switch_skill("cancel")
			Global.selection_canceled.emit()
			await get_tree().process_frame
			Global.tool_mode = Global.TOOL_MODE_SELECT_MULTIPLE
			Global.set_cursor() # restart cursor
		"eyedropper":
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_EYEDROPPER
				Global.selection_started.emit()
				clear_skills()
				$Box/Skill4.switch_skill("select")
				get_button_by_id("select").set_highlight()
				Global.action_cam_disable.emit()
				Global.set_cursor()
		"cancel":
			for _sd in Global.deco_selection_array:
				_sd.node.set_selected(false)
				_sd.node.position = _sd.last_position
			Global.deco_selection_array = []
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_PLACE:
				Global.deco_placement_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_FISH:
				Global.fishing_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_SELECT_MULTIPLE:
				Global.cursor_disabled.emit()
				set_default_skills()
			Global.action_cam_enable.emit()
		"accept":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.deco_selection_array = []
				Global.adjustment_applied.emit()
				set_default_skills()
			elif Global.tool_mode == Global.TOOL_MODE_PLACE:
				set_default_skills()
			Global.action_cam_enable.emit()
		"edit_selection":
			if Global.tool_mode == Global.TOOL_MODE_SELECT_MULTIPLE:
				Global.set_cursor(false)
				Global.deco_selection_array[0].node.start_adjustment()
		"duplicate_edit_selection":
			if Global.tool_mode == Global.TOOL_MODE_SELECT_MULTIPLE:
				if Global.deco_selection_array.size() <= 0:
					return
				Global.deco_handler.duplicate_decoration_selection()
				Global.set_cursor(false)
				Global.deco_selection_array[0].node.start_adjustment()
		"deco_test":
			if !Global.deco_pane_open:
				await get_tree().process_frame
				Global.deco_pane_opened.emit() # open the decoration pane
				Global.action_cam_disable.emit()
			else:
				Global.deco_pane_closed.emit()
			if Global.tool_mode == Global.TOOL_MODE_SELECT: # clear the cursor if it is active
				Global.tool_mode = Global.TOOL_MODE_NONE
				set_default_skills()
		"transform_mode":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.toggle_transform_mode()
		"adjust_mode_translate":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_mode = Global.ADJUSTMENT_MODE_TRANSLATE
				Global.adjustment_mode_translate.emit()
			$Box/Skill2.switch_skill("adjust_mode_rotate")
			if Global.transform_mode == Global.TRANSFORM_MODE_OBJECT:
				if Global.snapping == true:
					Global.snapping = false
				$Box/Skill3.switch_skill("snap_forbidden")
			else:
				if Global.snapping: $Box/Skill3.switch_skill("snap_disable")
				else:  $Box/Skill3.switch_skill("snap_enable")
			$Box/Skill4.switch_skill("transform_mode")
		"adjust_mode_rotate":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_mode = Global.ADJUSTMENT_MODE_ROTATE
				Global.adjustment_mode_rotation.emit()
			$Box/Skill2.switch_skill("adjust_mode_translate")
			# Rotation snapping
			if Global.snapping: $Box/Skill3.switch_skill("snap_disable")
			else:  $Box/Skill3.switch_skill("snap_enable")
			$Box/Skill4.switch_skill("empty")
		"snap_enable":
			$Box/Skill3.switch_skill("snap_disable")
			Global.snapping = true
			Global.snapping_enabled.emit()
			Global.announcement_sent.emit("Snapping enabled.")
		"snap_disable":
			$Box/Skill3.switch_skill("snap_enable")
			Global.snapping = false
			Global.announcement_sent.emit("Snapping disabled.")
		"reset_adjustment":
			Global.adjustment_reset.emit()
		"rotate_left":
			Global.rotate_left_90.emit()
		"rotate_right":
			Global.rotate_right_90.emit()
		"roll_left":
			Global.roll_left_90.emit()
		"roll_right":
			Global.roll_right_90.emit()
		"debug_skill":
			Global.debug_skill_used.emit()
		"toggle_gravity":
			$GravityCD.start()
			if gravity_cd: return
			gravity_cd = true
			if "gravity" in Global.current_effects:
				Global.remove_effect.emit("gravity")
				Global.ripple.emit()
			else:
				Global.gravity_entered.emit()
				Global.add_effect.emit("gravity")
		"ping":
			Global.command_sent.emit("/ping")
#endregion

func _process(delta: float) -> void:
	if _cd > 0:
		_cd -= delta

var gravity_cd = false

func _on_gravity_cd_timeout() -> void:
	gravity_cd = false
