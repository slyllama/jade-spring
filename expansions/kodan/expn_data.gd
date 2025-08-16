extends Node

# Will look for the scene in
#   res://expansions/<expansion>/<decoration>/<decoration>.tscn
# and the cursor in
#   res://expansions/<expansion>/<decoration>/<decoration>_mesh.tscn

const data = {
	"kodan_roof_piece": {
		"name": "Kodan Roof Piece",
		"preview_scale": 0.5,
		"preview_y_rotation": 180,
		"tags": ["Architecture", "Kodan", "Roof"]
	},
	"kodan_roof_window_piece": {
		"name": "Kodan Roof Window Piece",
		"preview_scale": 0.5,
		"preview_y_rotation": 180,
		"tags": ["Architecture", "Kodan", "Roof"]
	},
	"kodan_roof_corner_piece": {
		"name": "Kodan Roof Corner Piece",
		"preview_scale": 0.5,
		"preview_y_rotation": 140,
		"tags": ["Architecture", "Kodan", "Roof"]
	},
	"kodan_foxglove": {
		"name": "Kodan Foxglove",
		"preview_scale": 1.0,
		"tags": ["Foliage", "Kodan"],
		"cursor_suffix": "tscn",
		"preview_v_offset": -0.35
	},
}
