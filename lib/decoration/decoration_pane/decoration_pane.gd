extends "res://lib/ui_container/ui_container.gd"

@onready var preview = get_node("Base/PreviewContainer/PreviewViewport/DecoPreview") # shortcut
@onready var debug = get_node("Base/Debug")

var current_id

func open(silent = false) -> void:
	$PlaceDecoration.visible = false
	super(silent)
	preview.clear_model()

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
		
		$Container.add_child(_item)
		_item.button_down.connect(func():
			$PlaceDecoration.visible = false
			current_id = _d
			
			# Get the custom y-rotation, if one exists
			var _y_rotation = 135.0
			if "y_rotation" in _data:
				_y_rotation += _data.y_rotation
			
			preview.load_model(_data.scene, _data.preview_scale, _y_rotation)
			$PlaceDecoration.visible = true)

func _process(delta: float) -> void:
	super(delta)
	# Report details about the 3D async loader
	debug.text = "[right]Current path: '" + str(preview.current_model_path) + "'[/right]"
	Global.mouse_in_deco_pane = mouse_in_ui

func _on_place_decoration_button_down() -> void:
	if current_id != null:
		await get_tree().process_frame
		start_decoration_placement(current_id)
