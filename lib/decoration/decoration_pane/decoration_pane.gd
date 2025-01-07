extends "res://lib/ui_container/ui_container.gd"

@onready var preview = get_node("Base/PreviewContainer/PreviewViewport/DecoPreview") # shortcut
@onready var tag_list = get_node("Container/TagContainer/TagMenu") # preview
var current_id = "fountain" # default
@export var default_tag = "None"
@onready var selected_tag = default_tag

var buttons = {} # associate buttons with IDs

func _get_y_rotation(data: Dictionary) -> float:
	var _custom_y_rotation = 135.0
	if "preview_y_rotation" in data:
		_custom_y_rotation += data.preview_y_rotation
	elif "y_rotation" in data:
		_custom_y_rotation += data.y_rotation
	return(_custom_y_rotation)

func open(silent = false) -> void:
	Global.deco_pane_open = true
	super(silent)
	render(selected_tag)

func close():
	Global.deco_pane_open = false
	super()
	Global.action_cam_enable.emit()

func start_decoration_placement(id: String) -> void:
	Global.tool_mode = Global.TOOL_MODE_PLACE
	Global.queued_decoration = id
	Global.deco_placement_started.emit()
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

func render(tag = "None") -> void:
	for _n in buttons:
		buttons[_n].queue_free()
	buttons = {}
	
	var id_list = []
	for _d in Global.DecoData:
		var _ds = Global.DecoData[_d]
		if tag == "None":
			id_list.append(_d)
		elif "tags" in _ds:
			if tag in _ds.tags:
				id_list.append(_d)
	
	id_list.sort()
	if "autumnal_tree" in id_list: # use Shing Jea arch if not (it's pretty
		current_id = "autumnal_tree"
	else:
		current_id = id_list[0]
	
	for _d in id_list:
		# Get decoration data from Global.DecoData and use it to make buttons
		var _item = Button.new()
		var _dl = Global.DecoData[_d]
		_item.text = "  " + _dl.name
		_item.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_item.mouse_filter = Control.MOUSE_FILTER_PASS
		buttons[_d] = _item
		$Container/ScrollBox/ScrollVBox.add_child(_item)
		
		if "Foliage" in _dl.tags:
			_item.modulate = Color("bfee8e")
		if "Architecture" in _dl.tags:
			_item.modulate = Color("f2be98")
		
		_item.button_down.connect(func():
			current_id = _d
			preview.current_id = current_id
			preview.load_model(
				_dl.scene, _dl.preview_scale, _get_y_rotation(_dl)))
	
	preview.clear_model()
	preview.current_id = current_id
	var _data = Global.DecoData[current_id]
	preview.load_model(
		_data.scene,
		_data.preview_scale,
		_get_y_rotation(_data))
	
	# Grab focus on the last selected decoration type
	buttons[current_id].grab_focus()

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
