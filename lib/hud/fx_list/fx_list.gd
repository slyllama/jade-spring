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
		"description": "You are unable to move."
	},
	"decorating": {
		"texture": "decorating",
		"title": "Decorating",
		"description": "You are currently modifying an existing decoration."
	},
	"discombobulator": {
		"texture": "discombobulator",
		"title": "Pest Discombobulator",
		"description": "Go forth, Wayfinder; disperse those locusts!"
	},
	"weed": {
		"texture": "weed",
		"title": "Picked Weed",
		"description": "these belong in the compost bin!"
	}
}

func _get_texture(tex_id) -> Texture2D:
	return(load("res://lib/hud/fx_list/textures/fx_" + tex_id + ".png"))

func update(qty: int = 0) -> void:
	for _n in get_children():
		_n.queue_free()
	for _f in Global.current_effects:
		if "=" in _f: _f = _f.split("=")[0] # for quantitative effects
		var _data = EFFECTS_LIST[_f]
		var _n = FXSquare.instantiate()
		if "texture" in _data:
			_n.texture = _get_texture(_data.texture)
		else:
			_n.texture = UNKNOWN_TEX
		
		if "title" in _data and "description" in _data:
			var _desc = _data.description
			if qty > 0:
				_desc = "[color=yellow](" + str(qty) + ")[/color] " + _data.description
			_n.set_tip_text(_data.title, _desc)
		add_child(_n)

func add_effect(id) -> void:
	if !id in Global.current_effects:
		Global.current_effects.append(id)
		if "=" in id:
			update(int(id.split("=")[1]))
		else:
			update()

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
		# do periodic stuff
		
		if !Global.can_move:
			add_effect("immobile")
		else:
			if "immobile" in Global.current_effects:
				remove_effect("immobile")
