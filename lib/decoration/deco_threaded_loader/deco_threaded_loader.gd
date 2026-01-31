@icon("res://lib/decoration/deco_threaded_loader/icon_deco_loader.svg")
class_name DecoThreadedLoaderScript extends Node3D
# DecoThreadedLoader
# "Lazy-loads" decorations after map loading on another thread

@onready var spawn_count := 0
var load_status: int
var spawn_status := 0
var progress: Array[float]
var valid := false
var deco_path: String
var has_loaded := false

signal loaded
@export var deco_id: String
@export var spawn_data: Array

func spawn() -> void:
	var _packed_scene: PackedScene = ResourceLoader.load_threaded_get(deco_path)
	spawn_count = spawn_data.size()
	for _s in spawn_data:
		if !_s is SpawnData or _s == null: continue
		var _d: Decoration = _packed_scene.instantiate()
		_d.position = _s.position
		_d.rotation = _s.rotation
		_d.scale = _s.scale
		Global.deco_handler.call_deferred("add_child", _d)
		_d.tree_entered.connect(func():
			spawn_status += 1
			if spawn_status == spawn_count: # finished
				loaded.emit()
				queue_free())

func _ready() -> void:
	if !deco_id: print("[DecoThreadedLoader] No decoration ID defined.")
	if deco_id in Global.DecoData:
		deco_path = Global.DecoData[deco_id].scene
		ResourceLoader.load_threaded_request(deco_path)
		valid = true

func _process(_delta: float) -> void:
	if !valid: return
	load_status = ResourceLoader.load_threaded_get_status(deco_path, progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			has_loaded = true
			if !has_loaded: return # can't attempt more than once
			spawn()
		ResourceLoader.THREAD_LOAD_FAILED:
			print("[DecoThreadedLoader] Threaded load failed.")
