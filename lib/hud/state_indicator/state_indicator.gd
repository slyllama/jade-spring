@tool
extends CanvasLayer

@export var tint_color = Color.WHITE:
	get: return(tint_color)
	set(_val):
		set_color(_val)
		tint_color = _val

func set_color(color: Color) -> void:
	if !is_node_ready(): return
	for _n in $Base.get_children():
		if "modulate" in _n:
			_n.modulate = color

func _ready() -> void:
	Global.deco_placement_started.connect(func():
		tint_color = Color(0.51, 0.758, 0.169)
		visible = true)
	
	Global.adjustment_started.connect(func():
		await get_tree().process_frame
		tint_color = Color(0.97, 0.773, 0.233)
		visible = true)
	
	Global.deco_deletion_started.connect(func():
		await get_tree().process_frame
		tint_color = Color(0.97, 0.319, 0.233)
		visible = true)
	
	Global.deco_placement_canceled.connect(func(): visible = false)
	Global.deco_placed.connect(func(): visible = false)
	Global.adjustment_applied.connect(func(): visible = false)
	Global.adjustment_canceled.connect(func(): visible = false)
	Global.deco_deletion_canceled.connect(func(): visible = false)
