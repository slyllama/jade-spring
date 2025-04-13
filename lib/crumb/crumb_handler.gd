class_name CrumbHandler extends Node
# CrumbHandler
# Handles crumbs - bug clouds, dirt, and so on

const BugSwarm = preload("res://lib/crumb/bug_swarm.tscn")
const Weed = preload("res://lib/crumb/weed.tscn")
const Dragonvoid = preload("res://lib/crumb/dragonvoid.tscn")
const Nettles = preload("res://lib/crumb/weed/nettles.glb")
const GiftLetter = preload("res://lib/gift_letter/gift_letter.tscn")
const DRAGONS = ["kralkatorrik", "soo_won", "primordus", "jormag", "zhaitan", "mordremoth"]

var totals = {}
var RNG = RandomNumberGenerator.new()

# Save crumb types and positions to file
func save_crumbs() -> void:
	if Global.map_name == "debug": return
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
	if Global.map_name == "debug": return
	
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

func get_remaining() -> int:
	var remaining_weeds = totals.weed - Save.data.deposited_weeds
	var remaining_bugs = Save.data.crumb_count.bug
	var remaining_dv = Save.data.crumb_count.dragonvoid
	return(remaining_weeds + remaining_bugs + remaining_dv)

func update_crumb_count() -> void:
	var _get_crumb_count = {"bug": 0, "weed": 0, "dragonvoid": 0}
	for _n in get_children():
		if _n is Crumb:
			_get_crumb_count[_n.type] += 1
	Save.data.crumb_count = _get_crumb_count
	
	print("Remaining: " + str(get_remaining()))
	if get_remaining() == 0:
		# Gift letter and story advancing
		var _g = GiftLetter.instantiate()
		_g.set_text("((Game completion!))")
		Global.hud.get_node("TopLevel").add_child(_g)
		Save.advance_story()
		
		# Proc achievement if the player doesn't have it already
		if SteamHandler.get_achievment_completion("game_completion") == 0:
			SteamHandler.complete_achievement("game_completion")

func get_karma_stats() -> void:
	var _out = "weed = " + str(totals.weed) + " @ " + str(Global.kv_weed) + " = " + str(totals.weed * Global.kv_weed)
	_out += "\nbug = " + str(totals.bug) + " @ " + str(Global.kv_bug) + " = " + str(totals.bug * Global.kv_bug)
	_out += "\ndragonvoid = " + str(totals.dragonvoid) + " @ " + str(Global.kv_dragonvoid) + " = " + str(totals.dragonvoid * Global.kv_dragonvoid)
	_out += "\nTotal Karma yield: " + str(totals.weed * Global.kv_weed + totals.bug * Global.kv_bug + totals. dragonvoid * Global.kv_dragonvoid)
	print(_out)

func _ready() -> void:
	for _n in get_children():
		if _n is Crumb:
			if !_n.visible:
				_n.queue_free()
				continue
			if !_n.type in totals:
				totals[_n.type] = 0
			totals[_n.type] += 1
	if "weed" in totals:
		totals.weed -= 1
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/karmastats":
			get_karma_stats())
	
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
	
	await get_tree().process_frame
	
	# Assign Elder Dragons to Dragonvoid
	var _dragons_shuffle = DRAGONS.duplicate()
	_dragons_shuffle.shuffle()
	for _n: Crumb in get_children():
		#if !_n is Crumb: continue
		if _n.type == "dragonvoid":
			_n.custom_data = _dragons_shuffle[0]
			_dragons_shuffle.remove_at(0)
			if _dragons_shuffle.size() == 0:
				_dragons_shuffle = DRAGONS.duplicate()
		_n.process_custom_data()
