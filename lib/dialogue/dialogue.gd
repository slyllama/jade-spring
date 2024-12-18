extends CanvasLayer

signal closed

const TEST_DATA = {
	"_entry": {
		"string": "F-f-friend, good morning! Thirty-three, seven. The magnetic realignment h-h-helped overnight, it did, twelve?",
		"options": {
			"new_bot": "All three rods seem to be floating just right, P-4; I feel like a new bot."
		}
	},
	"new_bot": {
		"string": "Four, four, four! Magnificent! So uh (ahem, twenty-three)... want to t-t-take them for a spin?",
		"options": {
			"icky": "Sounds like someone has an icky job lined up for an idle set of jade rods, huh."
		}
	},
	"icky": {
		"string": "I just... These rotten weeds and b-b-bugs, one, one, one! I can't. The static! Swooping and d-d-diving. Worse than the Unchained.",
		"options": {
			"handle": "It's okay, Pull. I'll handle it, starting with the weeds."
		}
	},
	"handle": {
		"reference": "_exit"
	}
}

func render_block(block_data: Dictionary) -> void:
	for _n in $Base/Box.get_children():
		if _n is Button: _n.queue_free() # clear out previous buttons
	
	if "string" in block_data:
		$Base/Box/Text.text = block_data.string
	
	if "options" in block_data:
		for _o in block_data.options:
			var _b = $Base/TemplateButton.duplicate()
			_b.text = block_data.options[_o]
			_b.visible = true
			$Base/Box.add_child(_b)
			
			_b.button_down.connect(func():
				if _o in TEST_DATA:
					var _new_block_data = TEST_DATA[_o]
					if "reference" in _new_block_data:
						if _new_block_data.reference == "_exit":
							close()
						if _new_block_data.reference in TEST_DATA:
							render_block(TEST_DATA[_new_block_data.reference])
					else: render_block(_new_block_data))

func open() -> void:
	Global.in_exclusive_ui = true
	Global.can_move = false
	if "_entry" in TEST_DATA:
		render_block(TEST_DATA._entry)
	
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
