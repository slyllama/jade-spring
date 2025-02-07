extends Node3D

@onready var tile_detail = $RoofPiece/TilesDetail
@onready var tile_lod = $RoofPiece/TilesLOD

var _d = 0.0
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_d += delta
	if _d >= 0.2:
		_d = 0
		var _dist = global_position.distance_to(Global.player_position)
		if _dist >= 9.0:
			tile_detail.visible = false
			tile_lod.visible = true
		else:
			tile_detail.visible = true
			tile_lod.visible = false
