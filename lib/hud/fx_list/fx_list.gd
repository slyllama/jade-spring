extends HBoxContainer
# FXList
# The effects list displays status effects to the player e.g. immobility,
# holding pesticide, etc. It should not trigger any events, only receive and
# display them.

class FXSquare extends ColorRect: # TODO: use images instead
	func _ready():
		custom_minimum_size = Vector2(24, 24)

const EFFECTS_LIST = { # TODO: use images instead
	"immobile": {
		"color": "red"
	},
	"decorating": {
		"color": "green"
	}
}

var current_effects = [ ]

func update() -> void:
	for _n in get_children():
		_n.queue_free()
	for _f in current_effects:
		var _n = FXSquare.new()
		_n.color = EFFECTS_LIST[_f].color
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
