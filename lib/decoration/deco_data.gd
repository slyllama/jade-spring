extends Node

const DecoData = {
	"lantern": {
		"name": "Lantern",
		"scene": "res://decorations/lantern/deco_lantern.tscn",
		"cursor_model": "res://decorations/lantern/lantern.glb",
		"preview_scale": 0.9,
		"tags": ["Architecture", "Cantha"]
	},
	"small_boulder": {
		"name": "Small Boulder",
		"scene": "res://decorations/small_boulder/deco_small_boulder.tscn",
		"cursor_model": "res://maps/seitung/meshes/small_boulders.glb",
		"preview_scale": 0.9,
		"tags": []
	},
	"eepy_fence": {
		"name": "Eepy Fence",
		"scene": "res://decorations/eepy_fence/deco_eepy_fence.tscn",
		"cursor_model": "res://decorations/eepy_fence/warped_fence.glb",
		"preview_scale": 0.70,
		"preview_y_rotation": 180,
		"preview_h_offset": -0.1,
		"tags": ["Architecture"]
	},
	"waterfall_fountain": {
		"name": "Waterfall Fountain",
		"scene": "res://decorations/fountain/deco_fountain.tscn",
		"cursor_model": "res://decorations/fountain/fountain.glb",
		"y_rotation": 90,
		"preview_scale": 0.34,
		"preview_v_offset": 0.29,
		"tags": ["Architecture", "Cantha"]
	},
	"shing_jea_arch": {
		"name": "Shing Jea Arch",
		"scene": "res://decorations/shing_jea_arch/deco_shing_jea_arch.tscn",
		"cursor_model": "res://maps/seitung/meshes/arch.glb",
		"y_rotation": 90,
		"preview_y_rotation": 115,
		"preview_scale": 0.42,
		"preview_v_offset": -0.4,
		"tags": ["Architecture", "Cantha"]
	},
	"aetherblade_craft": {
		"name": "Aetherblade Craft",
		"scene": "res://decorations/rocket/deco_rocket.tscn",
		"cursor_model": "res://decorations/rocket/rocket.tscn",
		"preview_scale": 0.23,
		"preview_y_rotation": 190,
		"preview_v_offset": -0.4,
		"tags": [ ]
	},
	"bloodstone_impacted_pillar": {
		"name": "Bloodstone-Impacted Pillar",
		"scene": "res://decorations/bloodstone_impacted_pillar/deco_bloodstone_impacted_pillar.tscn",
		"cursor_model": "res://decorations/bloodstone_impacted_pillar/bloodstone_impacted_pillar.glb",
		"preview_scale": 0.78,
		"preview_v_offset": -0.6,
		"tags": ["Architecture"]
	},
	"flower_patch": {
		"name": "Flower Patch",
		"scene": "res://decorations/flower_patch/deco_flower_patch.tscn",
		"cursor_model": "res://decorations/flower_patch/deco_flower_patch.tscn",
		"preview_scale": 1.00,
		"tags": ["Foliage"]
	},
	"bamboo_cluster": {
		"name": "Bamboo Cluster",
		"scene": "res://decorations/bamboo_cluster/deco_bamboo_cluster.tscn",
		"cursor_model": "res://decorations/bamboo_cluster/bamboo_cursor.tscn",
		"preview_scale": 0.4,
		"preview_v_offset": -0.5,
		"tags": ["Foliage", "Cantha"]
	},
	"simple_sub_frame": {
		"name": "Simple Sub-Frame",
		"scene": "res://decorations/building_platform/deco_building_platform.tscn",
		"cursor_model": "res://decorations/building_platform/meshes/building_platform.glb",
		"preview_scale": 0.4,
		"preview_y_rotation": 35,
		"tags": ["Architecture"]
	},
	"simple_stairs": {
		"name": "Simple Stairs",
		"scene": "res://decorations/platform_stairs/deco_platform_stairs.tscn",
		"cursor_model": "res://decorations/platform_stairs/meshes/platform_stairs.glb",
		"preview_scale": 0.4,
		"preview_y_rotation": 215,
		"tags": ["Architecture"]
	},
	"cobble_ward_ac_unit": {
		"name": "Cobble Ward AC Unit",
		"scene": "res://decorations/rusted_ac_unit/deco_rusted_ac_unit.tscn",
		"cursor_model": "res://decorations/rusted_ac_unit/rusted_ac_unit.glb",
		"preview_scale": 1.2,
		"preview_y_rotation": 35,
		"tags": ["Cantha"]
	},
	"simple_wall": {
		"name": "Simple Wall",
		"scene": "res://decorations/test_wall/deco_test_wall.tscn",
		"cursor_model": "res://decorations/test_wall/meshes/wall.glb",
		"preview_y_rotation": 35,
		"y_rotation": 90,
		"preview_scale": 0.42,
		"tags": ["Architecture"]
	},
	"simple_wall_narrow": {
		"name": "Simple Wall - Narrow",
		"scene": "res://decorations/test_wall/deco_wall_narrow.tscn",
		"cursor_model": "res://decorations/test_wall/meshes/wall_narrow.glb",
		"y_rotation": 90,
		"preview_y_rotation": 35,
		"preview_scale": 0.42,
		"tags": ["Architecture"]
	},
	"simple_door": {
		"name": "Simple Door",
		"scene": "res://decorations/test_door/deco_test_door.tscn",
		"cursor_model": "res://decorations/test_door/mesh/test_door.glb",
		"preview_y_rotation": 35,
		"preview_scale": 0.42,
		"tags": ["Architecture"]
	},
	"weeping_willow": {
		"name": "Weeping Willow",
		"scene": "res://decorations/weeping_willow/deco_weeping_willow.tscn",
		"cursor_model": "res://decorations/weeping_willow/meshes/weeping_willow.glb",
		"preview_scale": 0.38,
		"preview_v_offset": -0.5,
		"preview_h_offset": -0.1,
		"tags": ["Foliage"]
	},
	"simple_roof_piece": {
		"name": "Simple Roof Piece",
		"scene": "res://decorations/roof_piece/deco_roof_piece.tscn",
		"cursor_model": "res://decorations/roof_piece/roof_piece.glb",
		"y_rotation": -90,
		"preview_scale": 0.9,
		"preview_y_rotation": 215,
		"tags": ["Architecture", "Cantha"]
	},
	"simple_roof_corner_piece": {
		"name": "Simple Roof Corner Piece",
		"scene": "res://decorations/roof_corner/roof_corner.tscn",
		"cursor_model": "res://decorations/roof_corner/roof_corner.glb",
		"y_rotation": -90,
		"preview_scale": 0.9,
		"preview_y_rotation": 215,
		"tags": ["Architecture", "Cantha"]
	},
	"autumnal_shrub": {
		"name": "Autumnal Shrub",
		"scene": "res://decorations/autumnal_shrub/deco_autumnal_shrub.tscn",
		"cursor_model": "res://maps/seitung/props/foliage_test/materials/autumnal_shrub.tscn",
		"preview_scale": 0.65,
		"preview_v_offset": -0.2,
		"tags": ["Foliage"]
	},
	"autumnal_tree": {
		"name": "Autumnal Tree",
		"scene": "res://decorations/autumnal_tree/deco_autumnal_tree.tscn",
		"cursor_model": "res://decorations/autumnal_tree/autumnal_tree.tscn",
		"preview_scale": 0.42,
		"preview_v_offset": -0.4,
		"tags": ["Foliage"]
	},
	"ancient_cherry_blossom": {
		"name": "Ancient Cherry Blossom",
		"scene": "res://decorations/ancient_cherry_blossom/ancient_cherry_blossom.tscn",
		"cursor_model": "res://decorations/ancient_cherry_blossom/ancient_cherry_blossom.glb",
		"preview_scale": 0.35,
		"preview_v_offset": -0.4,
		"tags": ["Foliage"]
	}
}
