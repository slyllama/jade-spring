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

func _set_paint_val(val: float) -> void:
	$Base.material.set_shader_parameter("value", val)

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
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_val, -1.0, 1.0, 0.3)

func close() -> void:
	closed.emit()
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_val, 1.0, -1.0, 0.3)
	
	await fade_tween.finished
	await get_tree().process_frame
	Global.in_exclusive_ui = false
	Global.can_move = true
	queue_free()

func _ready() -> void:
	#$Player.play("RESET")
	$Base.modulate.a = 1.0

func _on_done_button_down() -> void:
	close()
