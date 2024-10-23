@tool
extends EditorPlugin
const ICON_PATH = "icon.svg"

func _enter_tree() -> void:
	add_custom_type("MMOCamera", "Node3D", preload("mmo_camera.gd"), preload(ICON_PATH))

func _exit_tree() -> void:
	remove_custom_type("MMOCamera")
