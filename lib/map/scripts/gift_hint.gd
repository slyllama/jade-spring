extends Node

const GIFT_TEX = preload("res://lib/letters/textures/gift_revealed.png")

func show() -> void:
	var _h = Global.play_hint("gift_hood", { 
		"title": "Gift Acquired!",
		"arrow": "down",
		"anchor_preset": Control.LayoutPreset.PRESET_CENTER,
		"text": "As a token of his gratitude, Raiqqo has given you a Plush Hoodie! It can be toggled in Settings."
		}, Utilities.get_screen_center(Vector2(0, -50.0)))
	
	print(_h)
	
	var _t = TextureRect.new()
	_t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_t.custom_minimum_size = Vector2(256, 256)
	_t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_t.use_parent_material = true
	_t.texture = GIFT_TEX
	
	_h.add_child(_t)
	_t.set_anchors_preset(Control.PRESET_CENTER)
	_t.position = Vector2(0.0, -300.0)

func _ready() -> void:
	Global.command_sent.connect(func(_cmd: String):
		if _cmd == "/gifthint": show())
