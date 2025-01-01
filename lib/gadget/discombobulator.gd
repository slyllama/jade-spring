extends Node3D

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")
const dialogue_data = {
	"_entry": {
		"string": "((Discombobulator dialogue.))",
		"options": {
			"discombobulator": "I'd like a bug discombobulator.",
			"dragonvoid": "I'll take a Dragonvoid charge.",
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
