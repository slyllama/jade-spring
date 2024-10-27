extends Node
# Utilities
# Various handy tools!

const DEG = "[char=0x000000B0]"
const TICK = "[char=0x00002713]"

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
