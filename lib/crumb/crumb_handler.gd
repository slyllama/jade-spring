class_name CrumbHandler extends Node
# CrumbHandler
# Handles crumbs - bug clouds, dirt, and so on

func _ready() -> void:
	Global.crumb_handler = self # reference
	for _n in get_children():
		if _n is Crumb:
			if !_n.type in Global.crumb_data:
				Global.crumb_data[_n.type] = { "total": 1, "count": 1 }
			else:
				Global.crumb_data[_n.type].count += 1
				Global.crumb_data[_n.type].total += 1
	
	Global.crumbs_updated.emit()
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/crumbdata":
			print(Global.crumb_data))
