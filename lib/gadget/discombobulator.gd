extends Node3D

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")
const dialogue_data = {
	"_entry": {
		"string": "The maintenance shed is filled with tools and technology alike: shovels, golem parts, and jade battery cells, all neatly stored and labeled. It'd be wise to straighten up any awry crates before Pulley wanders back into here again...",
		"options": {
			"discombobulator": "I'd like a coil of Dispersion Flux.",
			"dragonvoid": "((Ley-Charged Dispersion Flux for Dragonvoid.))",
			"close": "I'm all sorted, thanks."
		}
	},
	"discombobulator": { "reference": "_exit" },
	"dragonvoid": { "reference": "_exit" },
	"close": { "reference": "_exit" }
}

func _on_collision_interacted() -> void:
	var _d = Dialogue.instantiate()
	_d.data = dialogue_data
	Global.hud.add_child(_d)
	_d.open()
	
	_d.block_played.connect(func(id):
		if id == "discombobulator":
			Global.add_effect.emit("discombobulator")
		elif id == "dragonvoid":
			Global.add_effect.emit("dv_charge"))
