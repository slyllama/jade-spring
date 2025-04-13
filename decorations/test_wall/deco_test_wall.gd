@tool
extends Decoration

@export var wall_color = Color.MAGENTA:
	get: return(wall_color)
	set(_val):
		if "wall_ornament" in dye_materials:
			set_dye_channel("wall_ornament", _val)
		wall_color = _val

func _ready() -> void:
	assign_dye_channel("wall_ornament")
	set_dye_channel("wall_ornament", wall_color)
	super()

var _e = 0.0
func _process(delta: float) -> void:
	super(delta)
	
	if !custom_lod: return
	if Engine.is_editor_hint(): return
	if get_node_or_null("Wall"):
		_e += delta
		if _e >= 0.2:
			_e = 0
			#var _dist = global_position.distance_to(Global.player_position)
			if distance_to_player >= 13.5: $Wall.visible = false
			else: $Wall.visible = true
