extends Node3D

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")
const DIALOGUE_DATA = {
	"title": "Ratchet's Shed",
	"_entry": {
		"string": "The maintenance shed is filled to the brim with tools and magitech alike: shovels, replacement golem parts, and jade battery cells, all neatly stowed and labeled.",
		"options": {
			"discombobulator": "Take some coils of Raw Dispersion Flux.",
			"fish_food": "Grab some fish food.",
			"close": "I'm all sorted, thanks."
		}
	},
	"discombobulator": {
		"type": "action",
		"reference": "_exit"
		},
	"fish_food": {
		"type": "action",
		"reference": "_exit"
	},
	"close": { "reference": "_exit" }
}

@onready var dialogue_data = DIALOGUE_DATA.duplicate()

func proc_story() -> void:
	var _p = Save.data.story_point
	if _p == "game_start" or _p == "pick_weeds":
		$Collision.active = false
		$Collision.visible = false
	else:
		$Collision.active = true
		$Collision.visible = true

func _ready() -> void:
	Global.summon_story_panel.connect(func(_data):
		if $Collision.overlaps_body(Global.player):
			Global.generic_area_left.emit())
	
	Global.close_story_panel.connect(func():
		if $Collision.overlaps_body(Global.player):
			Global.interact_hint = "Rummage"
			Global.generic_area_entered.emit())
	
	$Collision.body_entered.connect(func(body):
		if body == Global.player:
			Global.interact_hint = "Rummage")
	
	Save.story_advanced.connect(proc_story)
	proc_story()

func _on_collision_interacted() -> void:
	if Global.deco_pane_open or Global.dialogue_open: return
	Global.generic_area_left.emit()
	dialogue_data = DIALOGUE_DATA.duplicate(true)
	
	# Add an option to clear an effect (and golems) if you have it
	if ("d_kralkatorrik" in Global.current_effects
		or "d_soo_won" in Global.current_effects
		or "d_zhaitan" in Global.current_effects
		or "d_mordremoth" in Global.current_effects
		or "d_jormag" in Global.current_effects
		or "d_primordus" in Global.current_effects
		or Global.get_effect_qty("discombobulator_qty") > 0):
		dialogue_data._entry["options"].erase("close")
		dialogue_data._entry.options["clear"] = "I'd like to return my Golems. (Clears effects.)"
		dialogue_data._entry.options["close"] = "I'm all sorted, thanks."
		dialogue_data["clear"] = { "reference": "_exit", "type": "action" }
	
	var _d = Dialogue.instantiate()
	_d.data = dialogue_data
	Global.hud.add_child(_d)
	_d.open()
	
	_d.closed.connect(func():
		Global.interact_hint = "Rummage"
		Global.generic_area_entered.emit())
	_d.block_played.connect(func(id):
		if id == "discombobulator":
			Global.remove_effect.emit("discombobulator_qty")
			for _i in 3:
				Global.add_qty_effect("discombobulator_qty")
			Global.player.update_golem_effects()
			$GolemSound.play()
		elif id == "fish_food":
			Global.add_effect.emit("fish_food")
		elif id == "clear":
			Global.remove_effect.emit("discombobulator_qty")
			Global.remove_effect.emit("dv_charge")
			Global.remove_effect.emit("d_soo_won")
			Global.remove_effect.emit("d_kralkatorrik")
			Global.remove_effect.emit("d_zhaitan")
			Global.remove_effect.emit("d_jormag")
			Global.remove_effect.emit("d_primordus")
			Global.remove_effect.emit("d_mordremoth")
			Global.player.clear_dgolems())
