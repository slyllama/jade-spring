extends VBoxContainer

func _ready() -> void:
	for _n in Utilities.get_all_children(self):
		if _n is TextureButton:
			_n.modulate.a = 0.9
			_n.mouse_entered.connect(func(): _n.modulate.a = 1.2)
			_n.mouse_exited.connect(func(): _n.modulate.a = 0.9)
