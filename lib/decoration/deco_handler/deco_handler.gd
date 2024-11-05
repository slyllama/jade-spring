extends Node3D
# DecoHandler
# Manages the placing and removal of decorations

const TEST_DECORATION = preload("res://decorations/lantern/deco_lantern.tscn")

func place_decoration(data: Dictionary) -> void:
	var _d = TEST_DECORATION.instantiate()
	add_child(_d)
	_d.global_position = data.position
	Global.decorations.append(_d)

func _ready() -> void:
	for _n in get_children():
		if _n is Decoration:
			Global.decorations.append(_n)
	
	place_decoration({"position": Vector3.ZERO})
