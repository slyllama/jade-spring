class_name CrumbHandler extends Node
# CrumbHandler
# Handles crumbs - bug clouds, dirt, and so on

var crumb_count = 0

func _ready() -> void:
	Global.crumb_handler = self # reference
	for _n in get_children():
		if _n is Crumb:
			crumb_count += 1
