@tool
extends Window

const SUBWINDOW := true

func clear() -> void:
	for _n in Utilities.get_all_children(self):
		if _n is LineEdit:
			_n.text = ""
	$Box/CBox.visible = false
	$Box/Blank.visible = true

func set_enabled(enable_state := true):
	for _n in Utilities.get_all_children(self):
		if _n is LineEdit:
			_n.editable = enable_state

func generate_tag_string(tags: Array) -> String:
	var tag_string = ""
	for _t in tags:
		tag_string += _t + ", "
	tag_string = tag_string.rstrip(", ")
	return(tag_string)

func update_data() -> void:
	var _d = Global.DecoData[$Box/CBox/ID.text]
	_d.preview_scale = float($Box/CBox/Scale/Scale.text)
	var _v := int($Box/CBox/Value/Value.text)
	if _v > 0:
		_d.unlock_value = int($Box/CBox/Value/Value.text)
	else: _d.erase("unlock_value")
	if $Box/CBox/NameBox/Name.text != "":
		_d.name = $Box/CBox/NameBox/Name.text
	if $Box/CBox/VOffset/VOffset.text != "":
		_d.preview_v_offset = float($Box/CBox/VOffset/VOffset.text)
	if $Box/CBox/VOffset/HOffset.text != "":
		_d.preview_h_offset = float($Box/CBox/VOffset/HOffset.text)
	if $Box/CBox/Rotation/Rotation.text != "":
		_d.preview_y_rotation = float($Box/CBox/Rotation/Rotation.text)
	
	Global.deco_preview_data_updated.emit()

func update(id: String) -> void:
	clear()
	if !id in Global.DecoData: return
	var data: Dictionary = Global.DecoData[id]
	
	# Fill in values
	$Box/CBox/ID.text = id
	if "name" in data: $Box/CBox/NameBox/Name.text = data.name
	if "scene" in data: $Box/CBox/ScenePath/ScenePath.text = data.scene
	if "cursor_model" in data: $Box/CBox/CursorPath/CursorPath.text = data.cursor_model
	if "unlock_value" in data: $Box/CBox/Value/Value.text = str(data.unlock_value)
	if "tags" in data: $Box/CBox/Tags/Tags.text = generate_tag_string(data.tags)
	if "preview_scale" in data: $Box/CBox/Scale/Scale.text = str(data.preview_scale)
	if "preview_v_offset" in data: $Box/CBox/VOffset/VOffset.text = str(data.preview_v_offset)
	if "preview_h_offset" in data: $Box/CBox/VOffset/HOffset.text = str(data.preview_h_offset)
	if "preview_y_rotation" in data: $Box/CBox/Rotation/Rotation.text = str(data.preview_y_rotation)
	
	$Box/Blank.visible = false
	$Box/CBox.visible = true
	size.y = $Box.size.y * Global.retina_scale + 30.0

func _ready() -> void:
	# Set up window
	get_window().title = "Decoration Data Manager"
	get_window().close_requested.connect(func(): visible = false) # close
	get_window().focus_entered.connect(func(): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	
	if Engine.is_editor_hint(): return
	if !Global.debug_allowed: queue_free()
	
	Global.deco_pane_closed.connect(func(): clear())
	Global.deco_preview_opened.connect(update)
	get_window().position = Utilities.get_screen_position() + Vector2i(30, 60)
	clear()
	
	await get_tree().process_frame
	get_window().size *= Global.retina_scale
	get_window().content_scale_factor = Global.retina_scale

func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_accept")
		or Input.is_action_just_pressed("ui_text_indent")):
		if (get_window().has_focus()
			and get_viewport().gui_get_focus_owner() is LineEdit):
			update_data()

func _on_do_preview_pressed() -> void:
	update_data()
