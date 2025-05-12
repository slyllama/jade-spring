extends MeshInstance3D

const SMOL = Vector3(0.01, 0.01, 0.01)
const BIG = Vector3(1.0, 1.0, 1.0)
const MATERIAL = preload("res://lib/decoration/materials/mat_selection_icon.tres")

var active = false

func set_active(state = true) -> void:
	active = state
	if state:
		visible = true
		var _scale_tween = create_tween()
		_scale_tween.tween_property(
			self, "scale", BIG, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	else:
		var _scale_tween = create_tween()
		_scale_tween.tween_property(
			self, "scale", SMOL, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
		_scale_tween.tween_callback(func():
			if !active:
				visible = false)

func _ready() -> void:
	cast_shadow = SHADOW_CASTING_SETTING_OFF
	
	var _mesh = QuadMesh.new()
	_mesh.size = Vector2(0.35, 0.35)
	_mesh.material = MATERIAL
	mesh = _mesh
	
	scale = SMOL
	visible = false
