extends "res://lib/ui_container/ui_container.gd"

@onready var preview = get_node("Base/PreviewContainer/PreviewViewport/DecoPreview") # shortcut
var current_id = "fountain" # default

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
	preview.clear_model()
	
	preview.current_id = current_id
	var _data = Global.DecoData[current_id]
	
	preview.load_model(
		_data.scene,
		_data.preview_scale,
		_get_y_rotation(_data))
	
	# Grab focus on the last selected decoration type
	buttons[current_id].grab_focus()

func close():
	Global.deco_pane_open = false
	super()

func start_decoration_placement(id: String) -> void:
	Global.tool_mode = Global.TOOL_MODE_PLACE
	Global.queued_decoration = id
	Global.deco_placement_started.emit()
	
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

func _ready() -> void:
	super()
	Global.deco_placement_started.connect(close)
	
	# Get decoration data from Global.DecoData and use it to make buttons
	for _d in Global.DecoData:
		var _item = Button.new()
		var _data = Global.DecoData[_d]
		_item.text = "  " + _data.name
		_item.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_item.mouse_filter = Control.MOUSE_FILTER_PASS
		buttons[_d] = _item
		
		$Container.add_child(_item)
		
		_item.button_down.connect(func():
			current_id = _d
			preview.current_id = current_id
			preview.load_model(
				_data.scene, _data.preview_scale, _get_y_rotation(_data)))

func _process(delta: float) -> void:
	super(delta)
	Global.mouse_in_deco_pane = mouse_in_ui

func _on_place_decoration_button_down() -> void:
	Global.deco_button_pressed = true
	if current_id != null:
		await get_tree().process_frame
		start_decoration_placement(current_id)
