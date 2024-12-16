extends CanvasLayer

signal closed

const TEST_DATA = {
	"entry": {
		"string": "Opening string.",
		"options": {
			"opening_1": "((Opening option 1.))",
			"opening_2": "((Opening option 2.))",
			"opening_3": "((Opening option 3.))"
		}
	},
	"opening_1": {
		"string": "Opening option 1",
		"options": {
			"s_opening_1": "((Secondary option 1.))",
			"s_opening_2": "((Secondary option 2.))",
			"s_opening_return": "((Return to opening.))"
		}
	},
	"s_opening_return": {
		"reference": "entry" # 'reference' will override everything, playing that block
	}
}

func render_block(block_data: Dictionary) -> void:
	for _n in $Base/Box.get_children():
		if _n is Button: _n.queue_free() # clear out previous buttons
	
	if "string" in block_data:
		$Base/Box/Text.text = block_data.string
	
	if "options" in block_data:
		for _o in block_data.options:
			var _b = Button.new()
			_b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_b.text = block_data.options[_o]
			$Base/Box.add_child(_b)
			
			_b.button_down.connect(func():
				if _o in TEST_DATA:
					var _new_block_data = TEST_DATA[_o]
					if "reference" in _new_block_data:
						if _new_block_data.reference in TEST_DATA:
							render_block(TEST_DATA[_new_block_data.reference])
					else: render_block(_new_block_data))

func open() -> void:
	Global.in_exclusive_ui = true
	Global.can_move = false
	if "entry" in TEST_DATA:
		render_block(TEST_DATA.entry)
	
	$Player.play("Enter")

func close() -> void:
	closed.emit()
	Global.in_exclusive_ui = false
	Global.can_move = true
	queue_free()

func _ready() -> void:
	$Player.play("RESET")

func _on_done_button_down() -> void:
	close()
