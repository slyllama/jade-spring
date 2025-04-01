extends "res://lib/ui_container/ui_container.gd"

const LockTexture = preload("res://lib/hud/textures/icon_karma.png")
const DecoButton = preload("res://lib/decoration/decoration_pane/deco_button.tscn")

@onready var preview = get_node("Base/PreviewContainer/PreviewViewport/DecoPreview") # shortcut
@onready var tag_list = get_node("Container/TagContainer/TagMenu") # preview
@export var default_tag = "None"
@onready var selected_tag = default_tag

var current_id = "fountain" # default
var buttons = {} # associate buttons with IDs
var active = false
var last_deco_count = {} # updated when the pane is opened

func _get_y_rotation(data: Dictionary) -> float:
	var _custom_y_rotation = 135.0
	if "preview_y_rotation" in data:
		_custom_y_rotation += data.preview_y_rotation
	elif "y_rotation" in data:
		_custom_y_rotation += data.y_rotation
	return(_custom_y_rotation)

func _update_unlock_button(id: String) -> void:
	if "unlock_value" in Global.DecoData[id]:
		if !id in Save.data.unlocked_decorations:
			var _data = Global.DecoData[id]
			$ActionsBox/Unlock.visible = true
			$ActionsBox/Unlock.text = "(" + str(_data.unlock_value) + ") Unlock"
			if _data.unlock_value <= Save.data.karma:
				$ActionsBox/Unlock.disabled = false
			else:
				$ActionsBox/Unlock.disabled = true
				$ActionsBox/Unlock.tooltip_text = "Insufficient Karma."
				# TODO: this is where a hint would show up for the first time
			$ActionsBox/PlaceDecoration.disabled = true
		else:
			$ActionsBox/Unlock.visible = false
			$ActionsBox/PlaceDecoration.disabled = false
	else:
		$ActionsBox/Unlock.visible = false
		$ActionsBox/PlaceDecoration.disabled = false

func open(silent = false) -> void:
	active = true
	$Container/SearchContainer/Search.set_text("")
	Global.deco_pane_open = true
	super(silent)
	last_deco_count = Global.deco_handler.get_deco_count()
	render(selected_tag)

func close():
	Global.deco_pane_open = false
	super()
	await get_tree().process_frame
	if Global.tool_mode == Global.TOOL_MODE_NONE:
		if active:
			Global.action_cam_enable.emit()
	active = false

func start_decoration_placement(id: String) -> void:
	Global.mouse_3d_override_rotation = null
	Global.tool_mode = Global.TOOL_MODE_PLACE
	Global.queued_decoration = id
	Global.action_cam_disable.emit()
	
	var _y_rotation = 0.0
	if "y_rotation" in Global.DecoData[id]:
		_y_rotation = Global.DecoData[id].y_rotation
	
	if "cursor_model" in Global.DecoData[id]:
		Global.set_cursor(true, {
			"highlight_on_decoration": false,
			"custom_model": load(Global.DecoData[id].cursor_model),
			"y_rotation": _y_rotation})
	else:
		Global.set_cursor(true, {
			"highlight_on_decoration": false})
	
	Global.deco_placement_started.emit()

func render(tag = "None", custom_data = []) -> void:
	for _n in buttons:
		buttons[_n].queue_free()
	buttons = {}
	
	var id_list = []
	
	if custom_data.size() > 0:
		for _d in custom_data:
			id_list.append(_d)
	else:
		for _d in Global.DecoData:
			var _ds = Global.DecoData[_d]
			if tag == "None":
				id_list.append(_d)
			elif tag == "Empty":
				pass
			elif "tags" in _ds:
				if tag in _ds.tags:
					id_list.append(_d)
	
	id_list.sort()
	if !current_id in id_list:
		if "autumnal_tree" in id_list: # use Shing Jea arch if not (it's pretty
			current_id = "autumnal_tree"
		else:
			if id_list.size() > 0:
				current_id = id_list[0]
	
	var _c = 0
	for _d in id_list:
		# Get decoration data from Global.DecoData and use it to make buttons
		var _item = DecoButton.instantiate()
		var _dl = Global.DecoData[_d]
		
		var _button_text = "  " + _dl.name
		if _d in last_deco_count:
			_button_text += " (" + str(last_deco_count[_d]) + ")"
		_item.set_text(_button_text)
		if "unlock_value" in _dl and !_d in Save.data.unlocked_decorations:
			_item.set_cost(_dl.unlock_value)
			
		buttons[_d] = _item
		$Container/ScrollBox/ScrollVBox.add_child(_item)
		
		if "Foliage" in _dl.tags:
			_item.set_icon("foliage")
		if "Utility" in _dl.tags:
			_item.set_icon("utility")
		if "Furniture" in _dl.tags:
			_item.set_icon("furniture")
		
		_item.clicked.connect(func():
			# Prevent the same model from loadingtwice
			var _already_loaded = false
			if _d == current_id: _already_loaded = true
			else: current_id = _d
			
			preview.current_id = current_id
			var _p = _dl.scene
			_update_unlock_button(_d)
			
			# Model exceptions
			if _d == "light_ray":
				_p = "res://decorations/light_ray/light_ray_cursor.glb"
			$DecoTitle.text = "[center]" + _dl.name + "[/center]"
			if !_already_loaded:
				preview.load_model(
					_p, _dl.preview_scale, _get_y_rotation(_dl)))
		
		_c += 1
	
	preview.clear_model()
	preview.current_id = current_id
	var _data = Global.DecoData[current_id]
	
	if $Container/SearchContainer/Search.has_focus():
		$LoadOnTimeout.start()
	else:
		_load_model()
	$DecoTitle.text = "[center]" + _data.name + "[/center]"
	_update_unlock_button(current_id)

func _load_model() -> void:
	var _data = Global.DecoData[current_id]
	preview.load_model(
		_data.scene,
		_data.preview_scale,
		_get_y_rotation(_data))

# Update displayed value
func _refresh() -> void:
	tag_list.text = str(selected_tag).capitalize()

func _input(_event) -> void:
	super(_event)
	if Input.is_action_just_pressed("ui_cancel"):
		await get_tree().process_frame
		close()

func _ready() -> void:
	super()
	Global.deco_placement_started.connect(close)
	var _scroll_bar: VScrollBar = $Container/ScrollBox.get_v_scroll_bar()
	_scroll_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Close the decoration pane if the story panel is opened
	# This shouldn't really come up in normal use
	Global.summon_story_panel.connect(func(_data): close())
	Global.dialogue_opened.connect(close)
	
	# Let the game know the popup has been closed (especially for CameraHandler)
	tag_list.get_popup().visibility_changed.connect(func():
		if !tag_list.get_popup().visible:
			Global.popup_open = false)
	for _d in Global.DecoTags:
		tag_list.get_popup().add_item(_d)
	tag_list.get_popup().id_pressed.connect(func(n):
		selected_tag = Global.DecoTags[n]
		render(selected_tag)
		_refresh())
	_refresh()

func _process(delta: float) -> void:
	super(delta)
	Global.mouse_in_deco_pane = mouse_in_ui

func _on_place_decoration_button_down() -> void:
	Global.deco_button_pressed = true
	if current_id != null:
		await get_tree().process_frame
		start_decoration_placement(current_id)

func _on_menu_about_to_popup() -> void:
	Global.popup_open = true

func _on_unlock_button_down() -> void:
	Save.subtract_karma(Global.DecoData[current_id].unlock_value)
	Save.data.unlocked_decorations.append(current_id)
	Save.save_to_file()
	render()
	
	await get_tree().process_frame
	Global.play_flash($ActionsBox/PlaceDecoration.global_position
		+ $ActionsBox/PlaceDecoration.size / 2.0)

func _on_search_focus_entered() -> void:
	Global.can_move = false

func _on_search_focus_exited() -> void:
	Global.can_move = true

func _on_search_text_changed(new_text: String) -> void:
	#if new_text.length() > 0 and new_text.length() < 3:
		#render("Empty")
		#return # too short
	var _decos = []
	for _d in Global.DecoData:
		if Global.DecoData[_d].name.findn(new_text) > -1:
			_decos.append(_d)
	render("None", _decos)

func _on_clear_search_button_down() -> void:
	$Container/SearchContainer/Search.set_text("")
	render(selected_tag)

func _on_load_on_timeout_timeout() -> void:
	_load_model()
