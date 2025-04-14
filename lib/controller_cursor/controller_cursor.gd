extends Sprite2D

var target_position = Vector2.ZERO
var skill_buttons = []
var current_focus = null

func clear_focus() -> void:
	if !current_focus:
		return
	Global.controller_skill.emit(current_focus)
	current_focus = null
	var _fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	var _slide_tween = create_tween()
	_slide_tween.tween_property(self, "offset:y", -10.0, 0.1)
	_slide_tween.set_parallel()

func focus_on(node: Node, node_offset = Vector2.ZERO) -> void:
	current_focus = node
	target_position = node.global_position + node_offset

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("controller_focus_mode"):
		if get_window().gui_get_focus_owner(): return
		offset.y = 0.0
		var _fade_tween = create_tween()
		_fade_tween.tween_property(self, "modulate:a", 1.0, 0.1)
		focus_on(skill_buttons[0], Vector2(32, 0))
	if Input.is_action_just_released("controller_focus_mode"):
		clear_focus()
	
	if Input.is_action_just_pressed("ui_right"):
		var _skill_idx = skill_buttons.find(current_focus)
		if _skill_idx >= 0 and _skill_idx < skill_buttons.size() - 1:
			focus_on(skill_buttons[_skill_idx + 1], Vector2(32, 0))
	if Input.is_action_just_pressed("ui_left"):
		var _skill_idx = skill_buttons.find(current_focus)
		if _skill_idx > 0:
			focus_on(skill_buttons[_skill_idx - 1], Vector2(32, 0))

func _ready() -> void:
	modulate.a = 0.0
	await get_tree().process_frame
	skill_buttons.append(Global.hud.get_node("Toolbox/MarkerRestPos"))
	skill_buttons.append(Global.hud.get_node("Toolbox/Box/Skill1"))
	skill_buttons.append(Global.hud.get_node("Toolbox/Box/Skill2"))
	skill_buttons.append(Global.hud.get_node("Toolbox/Box/Skill3"))
	skill_buttons.append(Global.hud.get_node("Toolbox/Box/Skill4"))
	skill_buttons.append(Global.hud.get_node("Toolbox/Box/Skill5"))
	skill_buttons.append(Global.hud.get_node("Toolbox/Box/Skill6"))

func _process(delta) -> void:
	global_position = lerp(global_position, target_position, Utilities.critical_lerp(delta, 40.0))
