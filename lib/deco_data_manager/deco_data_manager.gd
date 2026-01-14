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
	# Value
	var _v := int($Box/CBox/Value/Value.text)
	if _v > 0:
		_d.unlock_value = int($Box/CBox/Value/Value.text)
	else: _d.erase("unlock_value")
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
	
	$Box/Blank.visible = false
	$Box/CBox.visible = true
	size.y = $Box.size.y + 30.0

func _ready() -> void:
	# Set up window
	get_window().title = "Decoration Data Manager"
	get_window().close_requested.connect(func(): visible = false) # close
	get_window().focus_entered.connect(func(): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	
	if Engine.is_editor_hint(): return
	
	Global.deco_pane_closed.connect(func(): clear())
	Global.deco_preview_opened.connect(update)
	get_window().position = Utilities.get_screen_position() + Vector2i(30, 60)
	clear()

func _on_do_preview_pressed() -> void:
	update_data()
