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
	$Box/Skill3.switch_skill("delete")
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.queued_decoration = "none"
	Global.set_cursor(false)

func get_button_by_id(id: String):
	for _n in $Box.get_children():
		if _n.id == id:
			return(_n)

#func _input(_event: InputEvent) -> void:
	## Abort certain actions by right-clicking
	#if Input.is_action_just_pressed("right_click"):
		#if Global.tool_mode == Global.TOOL_MODE_SELECT:
			#Global.tool_mode = Global.TOOL_MODE_NONE
			#set_default_skills()

func _ready() -> void:
	$SkillSwap.volume_db = linear_to_db(0)
	set_default_skills()
	await $SkillSwap.finished
	$SkillSwap.volume_db = linear_to_db(1.0)
	
	Global.deco_placement_started.connect(func():
		clear_skills()
		$Box/Skill6.switch_skill("cancel"))
	
	Global.deco_placed.connect(set_default_skills)
	Global.deco_deleted.connect(set_default_skills)
	Global.deco_placement_canceled.connect(set_default_skills)
	
	Global.adjustment_started.connect(func():
		clear_skills()
		$Box/Skill1.switch_skill("accept")
		$Box/Skill2.switch_skill("translate")
		$Box/Skill3.switch_skill("rotate")
		$Box/Skill5.switch_skill("transform_mode")
		$Box/Skill6.switch_skill("cancel"))
	
	Global.adjustment_canceled.connect(set_default_skills)
	
	Global.fishing_started.connect(func():
		clear_skills()
		$Box/Skill6.switch_skill("cancel"))
	
	Global.fishing_canceled.connect(set_default_skills)

#region Skill button behaviour
func skill_used(skill_id: String) -> void:
	match skill_id:
		"delete": # delete a decoration - uses similar logic to 'select'
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_DELETE
				
				clear_skills()
				$Box/Skill3.switch_skill("delete")
				get_button_by_id("delete").set_highlight()
				
				Global.set_cursor()
			elif Global.tool_mode == Global.TOOL_MODE_DELETE:
				Global.tool_mode = Global.TOOL_MODE_NONE
				set_default_skills()
		"select":
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_SELECT
				
				clear_skills()
				$Box/Skill1.switch_skill("select")
				get_button_by_id("select").set_highlight()
				
				Global.set_cursor()
			elif Global.tool_mode == Global.TOOL_MODE_SELECT:
				Global.tool_mode = Global.TOOL_MODE_NONE
				set_default_skills()
		"cancel":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_PLACE:
				Global.deco_placement_canceled.emit()
			elif Global.tool_mode == Global.TOOL_MODE_FISH:
				Global.fishing_canceled.emit()
		"accept":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_applied.emit()
				set_default_skills()
			elif Global.tool_mode == Global.TOOL_MODE_PLACE:
				print("Decoration placed")
				set_default_skills()
		"deco_test":
			if !Global.deco_pane_open:
				Global.deco_pane_opened.emit() # open the decoration pane
			else:
				Global.deco_pane_closed.emit()
			if Global.tool_mode == Global.TOOL_MODE_SELECT: # clear the cursor if it is active
				Global.tool_mode = Global.TOOL_MODE_NONE
				set_default_skills()
		"transform_mode":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.toggle_transform_mode()
		"translate":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_mode_translate.emit()
		"rotate":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_mode_rotation.emit()
#endregion
