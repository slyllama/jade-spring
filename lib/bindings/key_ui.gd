@tool
class_name KeyUI extends HBoxContainer
# KeyUI
# See and set key bindings

var enabled = true
var awaiting_input = false
signal await_input_started
signal await_input_ended

@export var input_name = "((Input Name))":
	get: return(input_name)
	set(_val):
		_set_input_name(_val)
		input_name = _val

@export var action: String

func _get_key_as_text() -> String:
	if action in InputMap.get_actions():
		var _a = InputMap.action_get_events(action)
		return(_a[0].as_text().replace(" (Physical)", ""))
	else: return("((ERR))")

func _set_input_name(_val):
	$Title.text = str(_val)

func get_key() -> InputEvent:
	return(InputMap.action_get_events(action)[0])

func get_controller_input() -> Variant:
	if InputMap.action_get_events(action).size() > 1:
		var _a = InputMap.action_get_events(action)[1]
		if !_a is InputEventKey: # TODO: not sure if this is actually necessary
			return(_a)
		else: return(null)
	else: return(null)

func assign_key(key: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)
	$Key.text = _get_key_as_text()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if awaiting_input:
			assign_key(event)
			awaiting_input = false
			await_input_ended.emit()
			Global.bindings_updated.emit()

func _ready() -> void:
	_set_input_name(input_name)

func _on_key_button_down() -> void:
	if enabled and !awaiting_input:
		awaiting_input = true
		await_input_started.emit()
		$Key.text = "Press a key"
