extends Node
# Utilities
# Various handy tools!

const DEG = "[char=0x000000B0]"
const TICK = "[char=0x00002713]"
const BIGNUM = -9999
const BIGVEC3 = Vector3(BIGNUM, BIGNUM, BIGNUM)

const DRAGON_DATA = {
	"jormag": {
		"name": "Jormag",
		"color": Color("90d6d0")
	},
	"kralkatorrik": {
		"name": "Kralkatorrik",
		"color": Color("dc6cb5")
	},
	"mordremoth": {
		"name": "Mordremoth",
		"color": Color("85ab37")
	},
	"primordus": {
		"name": "Primordus",
		"color": Color("e9694c")
	},
	"soo_won": {
		"name": "Soo-Won",
		"color": Color("4da3bf")
	},
	"zhaitan": {
		"name": "Zhaitan",
		"color": Color("57375c")
	}
}

func format_binding(binding: String) -> String:
	return("[color=#ffc573](" + binding + ")[/color]")

func get_screen_center(offset = Vector2.ZERO) -> Vector2:
	return(Vector2(get_window().size.x / Global.retina_scale / 2.0 - 150.0,
		get_window().size.y / Global.retina_scale / 2.0) + offset)

# Is the specified point within the world boundaries?
# TODO: relies on magic numbers; should use the boundary nodes themselves
func point_in_wb(point: Vector3) -> bool:
	if (point.x <= -13.0 or point.x >= 14.0 or point.z >= 20.75
		or point.z <= -12.0 or point.y >= 16.5):
		return(false)
	else: return(true)

func get_binding_str(input_binding) -> String:
	var key_string = ""
	if InputMap.has_action(input_binding):
		if InputMap.action_get_events(input_binding)[0] is InputEventKey:
			key_string = OS.get_keycode_string(
				InputMap.action_get_events(input_binding)[0].physical_keycode)
	return(key_string)

func get_time() -> String:
	var time = Time.get_time_dict_from_system()
	return("%02d:%02d:%02d" % [time.hour, time.minute, time.second])

func set_window_mode(window_mode: String) -> void:
		if window_mode == "full_screen":
			if get_window().mode != Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_FULLSCREEN
		elif window_mode == "maximized":
			if get_window().mode != Window.MODE_MAXIMIZED:
				get_window().mode = Window.MODE_MAXIMIZED
		elif window_mode == "exclusive_full_screen":
			if get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
				get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		elif window_mode == "windowed_(1080p)":
			if get_window().mode != Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_WINDOWED
			get_window().set_size(Vector2i(1920, 1080) * Global.retina_scale)
		else:
			if get_window().mode != Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_WINDOWED
			get_window().set_size(Vector2i(1280, 720) * Global.retina_scale)

func get_user_vol() -> float:
	if "volume" in SettingsHandler.settings:
		return(clamp(float(SettingsHandler.settings.volume), 0.0, 1.0))
	else:
		return(0.0)

# Set master volume on the bus
func set_master_vol(vol = get_user_vol()) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(vol))

# Get all children recursively
func get_all_children(node: Node) -> Array:
	var nodes: Array = []
	if !node: return([])
	for n in node.get_children():
		if n.get_child_count() > 0:
			nodes.append(n)
			nodes.append_array(get_all_children(n, ))
		else: nodes.append(n)
	return(nodes)

# Pretty (and rounded) presentation of Vector2 values
func fmt_vec2(vec: Vector2) -> String:
	return(str(snapped(vec.x, 0.1))
		+ ", " + str(snapped(vec.y, 0.1)))

# Pretty (and rounded) presentation of Vector3 values
func fmt_vec3(vec: Vector3) -> String:
	return(str(snapped(vec.x, 0.1))
		+ ", " + str(snapped(vec.y, 0.1))
		+ ", " + str(snapped(vec.z, 0.1)))

func critical_lerp(delta: float, speed: float) -> float:
	return(clamp(1.0 - exp(-speed * delta), 0.0, 1.0))
