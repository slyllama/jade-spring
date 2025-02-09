extends Node3D

@onready var tile_detail = $RoofPiece/TilesDetail
@onready var tile_lod = $RoofPiece/TilesLOD

var _d = 0.0
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_d += delta
	if _d >= 0.2:
		_d = 0
		if get_parent().distance_to_player >= 10.5:
			tile_detail.visible = false
		else:
			tile_detail.visible = true
