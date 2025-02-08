class_name CrumbHandler extends Node
# CrumbHandler
# Handles crumbs - bug clouds, dirt, and so on

const BugSwarm = preload("res://lib/crumb/bug_swarm.tscn")
const Weed = preload("res://lib/crumb/weed.tscn")
const Dragonvoid = preload("res://lib/crumb/dragonvoid.tscn")
const Nettles = preload("res://lib/crumb/weed/nettles.glb")

var totals = {}
var RNG = RandomNumberGenerator.new()

# Save crumb types and positions to file
func save_crumbs() -> void:
	Save.data.crumbs = []
	for _n in get_children():
		if _n is Crumb:
			Save.data.crumbs.append({
				"type": _n.type,
				"position": _n.global_position,
				"rotation": _n.rotation
			})
	Save.save_to_file()

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
		elif _c.type == "dragonvoid":
			var _n = Dragonvoid.instantiate()
			add_child(_n)
			_n.global_position = _c.position
			_n.rotation = _c.rotation

func update_crumb_count() -> void:
	var _get_crumb_count = {"bug": 0, "weed": 0, "dragonvoid": 0}
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
	totals.weed -= 1
	
	Global.crumb_handler = self
	Global.crumbs_updated.emit()
	
	await get_tree().process_frame
	if Save.data.crumbs != []: load_crumbs()
	else: update_crumb_count()
	
	for _n in get_children(): # weed variety
		if _n is Crumb and RNG.randf() > 0.57:
			if _n.type == "weed":
				var _mesh_base: MeshInstance3D = _n.get_node_or_null("WeedMesh")
				if _mesh_base:
					for _o in _mesh_base.get_children():
						_o.queue_free()
					var _nettles = Nettles.instantiate()
					_mesh_base.add_child(_nettles)
					_mesh_base.set_mesh(null)
					var _title = _n.get_node_or_null("SpatialText")
					if _title: _title.spatial_string = "Pestilent Nettles"
	
	Global.crumbs_updated.connect(func():
		# Wait for the node to be freed
		for _i in 2: await get_tree().process_frame
		update_crumb_count()
		save_crumbs())
