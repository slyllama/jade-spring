extends Node
# Threaded load Attenuator

const PATH = "res://lib/attenuator/attenuator.tscn"

var status: int
var progress: Array[float]
var has_loaded = false
var transitioning = false

signal pulled(resource: Resource)

func _ready() -> void:
	ResourceLoader.load_threaded_request(PATH)

func _process(_delta: float) -> void:
	status = ResourceLoader.load_threaded_get_status(PATH, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS: pass
		ResourceLoader.THREAD_LOAD_LOADED:
			if !has_loaded: has_loaded = true
			else: return
			pulled.emit(ResourceLoader.load_threaded_get(PATH))
		ResourceLoader.THREAD_LOAD_FAILED: pass
