extends HBoxContainer
# FXList
# The effects list displays status effects to the player e.g. immobility,
# holding pesticide, etc. It should not trigger any events, only receive and
# display them.

const FXSquare = preload("res://lib/hud/fx_list/fx_square.tscn")

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
	}
}

var current_effects = [ ]

func _get_texture(tex_id) -> Texture2D:
	return(load("res://lib/hud/fx_list/textures/fx_" + tex_id + ".png"))

func update() -> void:
	for _n in get_children():
		_n.queue_free()
	for _f in current_effects:
		var _data = EFFECTS_LIST[_f]
		var _n = FXSquare.instantiate()
		if "texture" in _data:
			_n.texture = _get_texture(_data.texture)
		
		if "title" in _data and "description" in _data:
			_n.set_tip_text(_data.title, _data.description)
		add_child(_n)

func add_effect(id) -> void:
	if !id in current_effects:
		current_effects.append(id)
		update()

func remove_effect(id) -> void:
	if id in current_effects:
		current_effects.erase(id)
		update()

func _ready() -> void:
	Global.adjustment_started.connect(func():
		add_effect("decorating"))
	Global.adjustment_canceled.connect(func():
		remove_effect("decorating"))
	Global.adjustment_applied.connect(func():
		remove_effect("decorating"))
	
	update()

var _time = 0.0
func _process(delta: float) -> void:
	_time += delta
	if _time > 0.35:
		_time = 0
		# do periodic stuff
		
		if !Global.can_move: add_effect("immobile")
		else: remove_effect("immobile")
