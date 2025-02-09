extends "res://lib/gadget/gadget.gd"

const ATTUNE_DIALOGUE = {
	"_entry": {
		"string": "((Raw Dispersion Flux Attunement))",
		"options": {
			"attune": "((Attune Raw Dispersion Flux))",
			"close": "I'm all sorted, thanks."
		}
	},
	"attune": { "reference": "_exit" },
	"close": { "reference": "_exit" }
}

func _on_interacted() -> void:
	if "discombobulator" in Global.current_effects:
		var _d = Dialogue.instantiate()
		_d.data = ATTUNE_DIALOGUE
		Global.hud.add_child(_d)
		_d.open()
		
		_d.closed.connect(Global.generic_area_entered.emit)
		
		_d.block_played.connect(func(id):
			if id == "attune":
				Global.remove_effect.emit("discombobulator")
				Global.add_effect.emit("dv_charge")
				Global.announcement_sent.emit(
					"((The Raw Dispersion Flux is now attuned for clearing Dragonvoid!))")
			)
	else:
		Global.announcement_sent.emit(
			"((This ramshackle device takes Raw Dispersion Flux and attunes it for clearing Dragonvoid.))")
