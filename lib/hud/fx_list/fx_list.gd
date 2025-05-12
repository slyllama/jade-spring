extends HBoxContainer
# FXList
# The effects list displays status effects to the player e.g. immobility,
# holding pesticide, etc. It should not trigger any events, only receive and
# display them.

const FXSquare = preload("res://lib/hud/fx_list/fx_square.tscn")
const UNKNOWN_TEX = preload("res://lib/hud/fx_list/textures/fx_unknown.png")

const EFFECTS_LIST = { # TODO: use images instead
	"immobile": {
		"texture": "immobile",
		"title": "Immobile",
		"description": "I can't move at the moment!"
	},
	"fish_food": {
		"title": "((Fish Food))",
		"description": "((Fish food.))"
	},
	"gravity": {
		"texture": "toggle_gravity",
		"title": "Gravity",
		"description": "I'm bound by the laws of physics."
	},
	"decorating": {
		"texture": "decorating",
		"title": "Decorating",
		"description": "I'm currently modifying a decoration."
	},
	"discombobulator": {
		"texture": "discombobulator",
		"title": "Raw Dispersion Flux",
		"description": "I'm equipped for clearing out bugs."
	},
	"discombobulator_qty": {
		"texture": "discombobulator",
		"title": "Raw Dispersion Flux",
		"description": "I'm equipped for clearing out bugs."
	},
	"weed": {
		"texture": "weed",
		"title": "Picked Weed",
		"description": "These belong in the compost bin!"
	},
	"d_jormag": {
		"texture": "d_jormag",
		"title": "Jormag-Attuned Flux",
		"description": "I'm equipped with Dispersion Flux for clearing out Dragonvoid."
	},
	"d_kralkatorrik": {
		"texture": "d_kralkatorrik",
		"title": "Kralkatorrik-Attuned Flux",
		"description": "I'm equipped with Dispersion Flux for clearing out Dragonvoid."
	},
	"d_mordremoth": {
		"texture": "d_mordremoth",
		"title": "Mordremoth-Attuned Flux",
		"description": "I'm equipped with Dispersion Flux for clearing out Dragonvoid."
	},
	"d_primordus": {
		"texture": "d_primordus",
		"title": "Primordus-Attuned Flux",
		"description": "I'm equipped with Dispersion Flux for clearing out Dragonvoid."
	},
	"d_soo_won": {
		"texture": "d_soo_won",
		"title": "Soo-Won-Attuned Flux",
		"description": "I'm equipped with Dispersion Flux for clearing out Dragonvoid."
	},
	"d_zhaitan": {
		"texture": "d_zhaitan",
		"title": "Zhaitan-Attuned Flux",
		"description": "I'm equipped with Dispersion Flux for clearing out Dragonvoid."
	}
}

func _get_texture(tex_id) -> Texture2D:
	return(load("res://lib/hud/fx_list/textures/fx_" + tex_id + ".png"))

var last_effects = []

func update() -> void:
	last_effects = []
	for _n in get_children():
		if "id" in _n:
			last_effects.append(_n.id)
		_n.queue_free()
	for _f in Global.current_effects:
		var _qty = 0
		if "=" in _f:
			_qty = int(_f.split("=")[1])
			_f = _f.split("=")[0] # for quantitative effects
		var _data = EFFECTS_LIST[_f]
		var _n = FXSquare.instantiate()
		_n.id = _f
		
		# Load textures
		if "texture" in _data: _n.texture = _get_texture(_data.texture)
		else: _n.texture = UNKNOWN_TEX
		
		if "title" in _data and "description" in _data:
			var _desc = _data.description
			if _qty > 0:
				_desc = "[color=yellow](" + str(_qty) + ")[/color] " + _data.description
			_n.set_tip_text(_data.title, _desc, _qty)
		add_child(_n)
		
		if !_f in last_effects:
			if "d_" in _f:
				await get_tree().process_frame
				Global.play_flash(_n.global_position)

func add_effect(id) -> void:
	if !id in Global.current_effects:
		Global.current_effects.append(id)
		if "=" in id: update()
		else: update()

func remove_effect(id) -> void:
	for _fx in Global.current_effects:
		if _fx.contains(id):
			Global.current_effects.erase(_fx)
			update()

func _ready() -> void:
	# Connections from Global
	Global.add_effect.connect(add_effect)
	Global.remove_effect.connect(remove_effect)
	
	# Respond to adjustment events/signals
	Global.adjustment_started.connect(func(): add_effect("decorating"))
	Global.adjustment_canceled.connect(func(): remove_effect("decorating"))
	Global.adjustment_applied.connect(func(): remove_effect("decorating"))
	
	update()

var _time = 0.0
func _process(delta: float) -> void:
	_time += delta
	if _time > 0.35:
		_time = 0
		
		if !Global.can_move:
			add_effect("immobile")
		else:
			if "immobile" in Global.current_effects:
				remove_effect("immobile")
