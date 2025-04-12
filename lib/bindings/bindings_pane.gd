extends "res://lib/ui_container/ui_container.gd"

var bind_nodes = []
const PATH = "user://save/map.dat"

var input_map = { }

func open(silent = false):
	super(silent)
	Global.bindings_pane_open = true

func close():
	super()
	Global.bindings_pane_open = false

func _set_all_enabled(state = true) -> void:
	$Container/Done.disabled = !state
	$Container/TitleContainer/CloseButton.disabled = !state
	for _n: KeyUI in bind_nodes:
		_n.get_node("Key").disabled = !state
		_n.enabled = state

func _append_controller_map() -> void:
	for _a in Utilities.controller_map:
		InputMap.action_add_event(_a, Utilities.controller_map[_a])

func _apply_input_map() -> void:
	for _n: KeyUI in bind_nodes:
		for _i in input_map:
			if _n.action == _i:
				_n.assign_key(input_map[_i])

func _update_input_map() -> void:
	for _n: KeyUI in bind_nodes:
		input_map[_n.action] = _n.get_key()
		_set_all_enabled()
	var _f = FileAccess.open(PATH, FileAccess.WRITE)
	_f.store_var(input_map, true)
	_f.close()

func _input(_event: InputEvent) -> void:
	super(_event)

func _ready() -> void:
	var _scroll_bar: VScrollBar = $Container/ScrollContainer.get_v_scroll_bar()
	_scroll_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	for _n in $Container/ScrollContainer/Contents.get_children():
		if _n is KeyUI: bind_nodes.append(_n)
	
	if !Global.bindings_saved_initial:
		for _n: KeyUI in bind_nodes:
			Global.default_input_map[_n.action] = _n.get_key().duplicate()
			if _n.get_controller_input():
				Utilities.controller_map[_n.action] = _n.get_controller_input()
		Global.bindings_saved_initial = true
	
	for _n: KeyUI in bind_nodes:
		_n.await_input_started.connect(func(): _set_all_enabled(false))
		_n.await_input_ended.connect(func(): _update_input_map())
	
	if FileAccess.file_exists(PATH):
		var _f = FileAccess.open(PATH, FileAccess.READ)
		input_map = _f.get_var(true)
		_f.close()
		_apply_input_map()
	else:
		for _n: KeyUI in bind_nodes:
			_n.assign_key(_n.get_key())
		_update_input_map()
	
	_append_controller_map()

func _on_done_button_down() -> void:
	close()

func _on_reset_inputs_button_down() -> void:
	input_map = Global.default_input_map.duplicate()
	Global.bindings_updated.emit()
	_apply_input_map()
	_update_input_map()
