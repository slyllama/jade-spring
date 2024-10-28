extends CanvasLayer

func clear_skills() -> void:
	for _b in $Box.get_children():
		if _b is SkillButton:
			_b.switch_skill("empty")

func set_default_skills() -> void:
	clear_skills()
	$Box/Skill1.switch_skill("select")
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.set_cursor(false)

func _ready() -> void:
	set_default_skills()
	
	Global.adjustment_started.connect(func():
		clear_skills()
		$Box/Skill1.switch_skill("accept")
		$Box/Skill4.switch_skill("cancel"))

func skill_used(skill_id: String) -> void:
	match skill_id:
		"select":
			if Global.tool_mode == Global.TOOL_MODE_NONE:
				Global.tool_mode = Global.TOOL_MODE_SELECT
				$Box/Skill1.set_highlight()
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
