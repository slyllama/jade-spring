@icon("res://lib/decoration/deco_threaded_loader/icon_deco_loader.svg")
class_name DecoThreadedLoaderScript extends Node3D
# DecoThreadedLoader
# "Lazy-loads" decorations after map loading on another thread

var load_status: int
var progress: Array[float]
var valid := false
var deco_path: String

signal loaded(decoration: Decoration)

@export var deco_id: String

func _ready() -> void:
	await get_tree().process_frame
	if !deco_id:
		print("[DecoThreadedLoader] No decoration ID defined.")
	if deco_id in Global.DecoData:
		deco_path = Global.DecoData[deco_id].scene
		valid = true
		ResourceLoader.load_threaded_request(deco_path)

func _process(_delta: float) -> void:
	load_status = ResourceLoader.load_threaded_get_status(deco_path, progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			var _d: Decoration = ResourceLoader.load_threaded_get(deco_path).instantiate()
			Global.deco_handler.call_deferred("add_child", _d)
			_d.global_transform = global_transform
			
			loaded.emit(_d)
			queue_free()
		ResourceLoader.THREAD_LOAD_FAILED:
			print("[DecoThreadedLoader] Threaded load failed.")
