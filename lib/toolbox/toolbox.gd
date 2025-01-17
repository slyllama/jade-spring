extends CanvasLayer

func clear_skills() -> void:
	$SkillSwap.play()
	for _b in $Box.get_children():
		if _b is SkillButton:
			_b.switch_skill("empty")

func set_default_skills() -> void:
	clear_skills()
	$Box/Skill1.switch_skill("select")
	$Box/Skill2.switch_skill("deco_test")
	$Box/Skill2.set_enabled()
	$Box/Skill3.switch_skill("delete")
	$Box/Skill4.switch_skill("safe_point")
	#$Box/Skill5.switch_skill("debug_skill")
	# TODO: disabled for initial release
	#$Box/Skill5.switch_skill("toggle_walk_mode")
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.queued_decoration = "none"
	Global.set_cursor(false)

func get_button_by_id(id: String):
	for _n in $Box.get_children():
		if _n.id == id:
			return(_n)

func _ready() -> void:
	Global.deco_placement_started.connect(func():
		clear_skills()
		$Box/Skill6.switch_skill("cancel")
		$Box/Skill2.switch_skill("rotate_left")
		$Box/Skill3.switch_skill("rotate_right"))
	
	#Global.deco_placed.connect(set_default_skills)
	Global.deco_deleted.connect(func():
		#set_default_skills()
		await get_tree().process_frame
		Global.command_sent.emit("/savedeco"))
	Global.deco_placement_canceled.connect(set_default_skills)
	
	Global.adjustment_started.connect(func():
		clear_skills()
		Global.adjustment_mode = Global.ADJUSTMENT_MODE_TRANSLATE
		$Box/Skill1.switch_skill("accept")
		$Box/Skill2.switch_skill("adjust_mode_rotate")
		
		#if !Global.snapping: $Box/Skill3.switch_skill("snap_enable")
		#else: $Box/Skill3.switch_skill("snap_disable")
		Global.snapping = false
		if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
			$Box/Skill3.switch_skill("snap_enable")
		else:
			$Box/Skill3.switch_skill("snap_forbidden")
		
		$Box/Skill4.switch_skill("transform_mode")
		$Box/Skill5.switch_skill("reset_adjustment")
		$Box/Skill6.switch_skill("cancel"))
	
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
				Global.set_cursor()
			elif Global.tool_mode == Global.TOOL_MODE_DELETE:
				Global.tool_mode = Global.TOOL_MODE_NONE
				Global.action_cam_enable.emit()
				Global.deco_deletion_canceled.emit()
				set_default_skills()
		"select":
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_SELECT
				clear_skills()
				$Box/Skill1.switch_skill("select")
				get_button_by_id("select").set_highlight()
				Global.action_cam_disable.emit()
				
				Global.set_cursor()
			elif Global.tool_mode == Global.TOOL_MODE_SELECT:
				Global.tool_mode = Global.TOOL_MODE_NONE
				Global.action_cam_enable.emit()
				set_default_skills()
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
			#$Box/Skill3.switch_skill("rotate_left")
			#$Box/Skill4.switch_skill("rotate_right")
		"safe_point":
			Global.go_to_safe_point()
		"snap_enable":
			$Box/Skill3.switch_skill("snap_disable")
			Global.snapping = true
			Global.snapping_enabled.emit()
			Global.announcement_sent.emit("Grid snapping enabled.")
		"snap_disable":
			$Box/Skill3.switch_skill("snap_enable")
			Global.snapping = false
			Global.announcement_sent.emit("Grid snapping disabled.")
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
