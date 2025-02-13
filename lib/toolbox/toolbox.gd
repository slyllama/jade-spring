extends CanvasLayer

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
	$Box/Skill5.switch_skill("safe_point")
	
	if _p == "game_start" or _p == "pick_weeds":
		$Box/Skill1.set_enabled(false)
		$Box/Skill2.set_enabled(false)
		$Box/Skill3.set_enabled(false)
		$Box/Skill4.set_enabled(false)
	else:
		$Box/Skill1.set_enabled()
		$Box/Skill2.set_enabled()
		$Box/Skill3.set_enabled()
		$Box/Skill4.set_enabled()
	
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.queued_decoration = "none"
	Global.set_cursor(false)

func get_button_by_id(id: String):
	for _n in $Box.get_children():
		if _n.id == id:
			return(_n)

var _cd := 0.0

func _input(_event: InputEvent) -> void:
	if Global.bindings_pane_open: return
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
	
	Global.deco_placement_started.connect(func():
		clear_skills()
		$Box/Skill6.switch_skill("cancel")
		if !Global.mouse_3d_override_rotation:
			$Box/Skill2.switch_skill("rotate_left")
			$Box/Skill3.switch_skill("rotate_right"))
	
	Global.deco_deleted.connect(func():
		await get_tree().process_frame
		Global.command_sent.emit("/savedeco"))
	
	Global.deco_placement_canceled.connect(set_default_skills)
	
	Global.adjustment_started.connect(func():
		clear_skills()
		Global.adjustment_mode = Global.ADJUSTMENT_MODE_TRANSLATE
		$Box/Skill1.switch_skill("accept")
		$Box/Skill2.switch_skill("adjust_mode_rotate")
		Global.snapping = false
		if Global.transform_mode == Global.TRANSFORM_MODE_WORLD: $Box/Skill3.switch_skill("snap_enable")
		else: $Box/Skill3.switch_skill("snap_forbidden")
		$Box/Skill4.switch_skill("transform_mode")
		$Box/Skill5.switch_skill("reset_adjustment")
		$Box/Skill6.switch_skill("cancel"))
	
	Global.deco_sampled.connect(func(data):
		Global.set_cursor(false)
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
		$Box/Skill6.switch_skill("cancel"))
	
	Global.fishing_canceled.connect(func():
		set_default_skills())
	
	$SkillSwap.volume_db = linear_to_db(0)
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
				get_button_by_id("select").set_highlight()
				Global.action_cam_disable.emit()
				Global.set_cursor()
			elif (Global.tool_mode == Global.TOOL_MODE_SELECT
				or Global.tool_mode == Global.TOOL_MODE_EYEDROPPER):
				Global.tool_mode = Global.TOOL_MODE_NONE
				Global.selection_canceled.emit()
				Global.action_cam_enable.emit()
				set_default_skills()
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
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_PLACE:
				Global.deco_placement_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_FISH:
				Global.fishing_canceled.emit()
			Global.action_cam_enable.emit()
		"accept":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_applied.emit()
				set_default_skills()
			elif Global.tool_mode == Global.TOOL_MODE_PLACE:
				set_default_skills()
			Global.action_cam_enable.emit()
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
		"safe_point":
			Global.go_to_safe_point()
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
		"toggle_walk_mode":
			if Global.in_walk_mode: Global.walk_mode_left.emit()
			else: Global.walk_mode_entered.emit()
		"rotate_left":
			Global.rotate_left_90.emit()
		"rotate_right":
			Global.rotate_right_90.emit()
		"debug_skill":
			Global.debug_skill_used.emit()
#endregion

func _process(delta: float) -> void:
	if _cd > 0:
		_cd -= delta
