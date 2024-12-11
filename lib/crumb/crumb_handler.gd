class_name CrumbHandler extends Node
# CrumbHandler
# Handles crumbs - bug clouds, dirt, and so on

const BugSwarm = preload("res://lib/crumb/bug_swarm.tscn")
const Weed = preload("res://lib/crumb/weed.tscn")

var totals = {}

# Save crumb types and positions to file
func save_crumbs() -> void:
	Save.data.crumbs = []
	for _n in get_children():
		if _n is Crumb:
			Save.data.crumbs.append({
				"type": _n.type,
				"position": _n.global_position
			})

# Load crumbs from save file
func load_crumbs() -> void:
	for _n in get_children(): # clear
		_n.queue_free()
	
	for _c in Save.data.crumbs:
		if _c.type == "bug":
			var _n = BugSwarm.instantiate()
			add_child(_n)
			_n.global_position = _c.position
		elif _c.type == "weed":
			var _n = Weed.instantiate()
			add_child(_n)
			_n.global_position = _c.position

func update_crumb_count() -> void:
	var _get_crumb_count = {"bug": 0, "weed": 0}
	for _n in get_children():
		if _n is Crumb:
			_get_crumb_count[_n.type] += 1
	Save.data.crumb_count = _get_crumb_count

func _ready() -> void:
	for _n in get_children():
		if _n is Crumb:
			if !_n.type in totals:
				totals[_n.type] = 0
			totals[_n.type] += 1
	
	Global.crumb_handler = self # reference
	Global.crumbs_updated.emit()
	
	await get_tree().process_frame
	if Save.data.crumbs != []: load_crumbs() # if not empty
	else: update_crumb_count()
	
	Global.crumbs_updated.connect(func():
		for _i in 2: await get_tree().process_frame # wait for the node to be freed
		update_crumb_count()
		save_crumbs())
