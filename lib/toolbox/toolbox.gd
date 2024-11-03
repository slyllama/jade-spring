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
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.set_cursor(false)

func get_button_by_id(id: String):
	for _n in $Box.get_children():
		if _n.id == id:
			return(_n)

func _ready() -> void:
	$SkillSwap.volume_db = linear_to_db(0)
	set_default_skills()
	await $SkillSwap.finished
	$SkillSwap.volume_db = linear_to_db(1.0)
	
	Global.adjustment_started.connect(func():
		clear_skills()
		$Box/Skill1.switch_skill("accept")
		$Box/Skill5.switch_skill("transform_mode")
		$Box/Skill6.switch_skill("cancel"))

func skill_used(skill_id: String) -> void:
	match skill_id:
		"select":
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_SELECT
				get_button_by_id("select").set_highlight()
				Global.set_cursor()
			elif Global.tool_mode == Global.TOOL_MODE_SELECT:
				Global.tool_mode = Global.TOOL_MODE_NONE
				set_default_skills()
		"cancel":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_canceled.emit()
				set_default_skills()
		"accept":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.adjustment_applied.emit()
				set_default_skills()
		"deco_test":
			print("deco test")
			pass
		"transform_mode":
			if Global.tool_mode == Global.TOOL_MODE_ADJUST:
				Global.toggle_transform_mode()
