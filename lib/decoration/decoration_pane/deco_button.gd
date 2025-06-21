extends HBoxContainer

const ICONS = {
	"foliage": preload("res://lib/hud/fx_list/textures/fx_weed.png"),
	"utility": preload("res://lib/hud/fx_list/textures/fx_utility.png"),
	"furniture": preload("res://lib/hud/fx_list/textures/fx_furniture.png"),
	
	"karma": preload("res://lib/hud/textures/icon_karma.png"),
	"karma_insufficient": preload("res://lib/hud/textures/icon_karma_insufficient.png"),
	"tick": preload("res://lib/hud/textures/icon_tick.png")
}
signal clicked

@export var id = ""

func set_icon(icon: String) -> void:
	$Icon.texture = ICONS[icon]

func set_text(text: String) -> void:
	$Button.text = text

func set_cost(cost: int) -> void:
	$Cost.text = str(cost)
	$Karma.texture = ICONS.karma
	$Cost.visible = true
	if cost > Save.data.karma:
		$Cost.modulate = Color(1, 0.428, 0.34)
		$Karma.texture = ICONS.karma_insufficient
	else:
		$Cost.modulate = Color(1, 1, 1)

func _on_button_button_down() -> void:
	$Click.play()
	clicked.emit()

func _on_button_mouse_entered() -> void:
	$Hover.play()
	$Anim.play("pop_in")

func _on_button_mouse_exited() -> void:
	$Anim.play("pop_out")

func _on_icon_gui_input(_event: InputEvent) -> void:
	if $Button.disabled: return
	if Input.is_action_just_pressed("left_click"):
		_on_button_button_down()
