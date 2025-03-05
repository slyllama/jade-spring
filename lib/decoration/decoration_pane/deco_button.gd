extends HBoxContainer

const ICONS = {
	"foliage": preload("res://lib/hud/fx_list/textures/fx_weed.png"),
	"utility": preload("res://lib/hud/fx_list/textures/fx_utility.png"),
	"furniture": preload("res://lib/hud/fx_list/textures/fx_furniture.png")
}
signal clicked

func fade_in_with_delay(delay_time: float) -> void:
	await get_tree().create_timer(delay_time).timeout
	var _f = create_tween()
	_f.tween_property(self, "modulate:a", 1.0, 0.1)

func set_icon(icon: String) -> void:
	$Icon.texture = ICONS[icon]

func set_text(text: String) -> void:
	$Button.text = text

func set_cost(cost: int) -> void:
	$Cost.text = str(cost)
	$Cost.visible = true
	$Karma.visible = true

func _on_button_button_down() -> void:
	clicked.emit()

func _ready() -> void:
	modulate.a = 0.0
