extends CanvasLayer
# MMLoader - minimal scene to threaded load the main menu instead of holding
# up the entire main thread

const TARGET_SCENE = "res://lib/main_menu/main_menu.tscn"
var target_scene = TARGET_SCENE

var status: int
var progress: Array[float]
var has_loaded = false
var transitioning = false

func _transition():
	if transitioning: return
	transitioning = true
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(target_scene))

func _ready() -> void:
	if Global.map_name != "":
		$Splash.visible = false
	ResourceLoader.load_threaded_request(target_scene)

func _process(_delta: float) -> void:
	status = ResourceLoader.load_threaded_get_status(target_scene, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS: pass
		ResourceLoader.THREAD_LOAD_LOADED: _transition()
		ResourceLoader.THREAD_LOAD_FAILED: pass
