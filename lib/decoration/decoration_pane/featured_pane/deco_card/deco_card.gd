@tool
extends Panel

@export_multiline var title: String = "((Untitled))"
@export var id: String = ""
@export var image: Texture2D
@export var custom_font_size: int
@export var custom_image_height: float
@export var custom_image_y_pos: float
@export_tool_button("Update Preview") var update_button = update

func update() -> void:
	$Title.text = title
	$Image.texture = image
	if custom_font_size:
		$Title.add_theme_font_size_override(
			"normal_font_size", custom_font_size)
	if custom_image_height:
		$Image.set_deferred("size:y", custom_image_height)
		#$Image.size.y = custom_image_height
	if custom_image_y_pos:
		$Image.position.y = custom_image_y_pos

func _init() -> void:
	modulate.a = 0.9

func _ready() -> void:
	update()

func _on_mouse_entered() -> void: modulate.a = 1.2
func _on_mouse_exited() -> void: modulate.a = 0.9

func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		if id and id != "":
			Global.deco_card_clicked.emit(id)
