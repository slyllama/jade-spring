@tool
extends HBoxContainer
# KeyUI
# See and set key bindings

@export var input_name = "((Input Name))":
	get: return(input_name)
	set(_val):
		_set_input_name(_val)
		input_name = _val

@export var action: String

func _set_input_name(_val):
	$Title.text = str(_val)

func _ready() -> void:
	_set_input_name(input_name)
	
	# print(InputMap.get_actions())
	print(InputMap.action_get_events("interact"))
