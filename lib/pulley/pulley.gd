@tool
extends "res://lib/gadget/gadget.gd"
# Pulley
# Script for the character Ratchet!

const ScriptData = preload("res://lib/pulley/script.gd")
const CharaViewer = preload("res://lib/chara_viewer/chara_viewer.tscn")
const VIEWER_X_OFFSET = 400.0

# These dialogue IDs are considered fresh if (a) the game is on that story
# point and (b) the dialogue ID isn't already in Save.dialogue_played.
const story_point_positions = {
	# [story point]: [ID] 
	"pick_weeds": ["pick_weeds_alt"],
	"clear_bugs": ["clear_bugs_alt"],
	"clear_dv": ["no_dv_charge"],
	"charged_dv": ["dv_charge"],
	"gratitude": ["raiqqo"],
	"stewardship": ["gift"]
}

# Check if the player has seen this dialogue before
# force_fx will make sure that the effect for new dialogue procs
func check_freshness(force_fx := false) -> void:
	Global.remove_effect.emit("dialogue")
	
	var _story_point: String = Save.data.story_point
	if !_story_point in story_point_positions: return
	var _in = true
	for _id in story_point_positions[_story_point]:
		if !_id in Save.data.dialogue_played:
			_in = false
	if !_in:
		if _story_point == "charged_dv": # if player isn't holding any charged flux
			if (!"d_zhaitan" in Global.current_effects and !"d_soo_won" in Global.current_effects
				and !"d_mordremoth" in Global.current_effects and !"d_jormag" in Global.current_effects
				and !"d_primordus" in Global.current_effects and !"d_kralkatorrik" in Global.current_effects):
				_in = true
	
	# Show an effect if Ratchet gains new optional dialogue
	if !_in and force_fx:
		Global.remove_effect.emit("dialogue")
		await get_tree().process_frame
		Global.add_effect.emit("dialogue")
	elif !_in and !$QuestMarker.visible:
		Global.remove_effect.emit("dialogue")
		await get_tree().process_frame
		Global.add_effect.emit("dialogue")
	
	$QuestMarker.visible = !_in

func check_dialogue_achieved() -> void:
	if !Save.data.story_point == "stewardship": return
	var _all_dialogue_achieved = true
	for _id in story_point_positions:
		for _i in story_point_positions[_id]:
			if !_i in Save.data.dialogue_played:
				_all_dialogue_achieved = false
	if _all_dialogue_achieved:
		print("[Pulley] All secondary dialogue read (I checked)!")
		if SteamHandler.get_achievment_completion("my_friend_ratchet") == 0:
			SteamHandler.complete_achievement("my_friend_ratchet")

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	# Quick fix to an ambient occlusion issue
	$PulleyMesh/GolemSkeleton/Skeleton3D/ArmBase_L/ArmBase_L.rotation_degrees.y = 180.0
	$PulleyMesh/GolemSkeleton/Skeleton3D/Armpivot_L/Armpivot_L.rotation_degrees.y = 180.0
	$PulleyMesh/AnimationPlayer.play("Base")
	
	Save.story_advanced.connect(check_freshness)
	Global.check_freshness.connect(check_freshness)
	
	Global.dialogue_closed.connect(func():
		await get_tree().process_frame
		check_freshness())
	Global.effects_reset.connect(func():
		check_freshness(true))
	
	Global.dialogue_closed.connect(func():
		if overlaps_body(Global.player):
			Global.interact_hint = "Talk")
	
	body_entered.connect(func(body): if body is CharacterBody3D:
		Global.interact_hint = "Talk")
	
func _on_interacted() -> void:
	if Global.in_exclusive_ui or Global.dialogue_open: return
	Global.generic_area_left.emit()
	
	var _dialogue_spawned = true
	Global.remove_effect.emit("dialogue")
	
	if Save.data.story_point == "game_start":
		spawn_dialogue(ScriptData.intro_dialogue_data, true)
	elif Save.data.story_point == "pick_weeds":
		spawn_dialogue(ScriptData.pick_weeds_alt_dialogue)
	elif Save.data.story_point == "clear_bugs":
		spawn_dialogue(ScriptData.clear_bugs_alt_dialogue)
	elif Save.data.story_point == "ratchet_dv":
		spawn_dialogue(ScriptData.dv_intro_dialogue, true)
	elif Save.data.story_point == "clear_dv":
		spawn_dialogue(ScriptData.no_dv_charge)
	
	elif Save.data.story_point == "charged_dv":
		if ("d_zhaitan" in Global.current_effects or "d_soo_won" in Global.current_effects
			or "d_mordremoth" in Global.current_effects or "d_jormag" in Global.current_effects
			or "d_primordus" in Global.current_effects or "d_kralkatorrik" in Global.current_effects):
			var _d = Dialogue.instantiate()
			_d.data = ScriptData.dv_charge
			Global.hud.add_child(_d)
			_d.closed.connect(func():
				if Save.data.story_point == "clear_dv":
					Save.advance_story())
			_d.open()
	
	elif Save.data.story_point == "ratchet_gratitude":
		# This needs to be manual so that we can call back to open the letter
		var _d = Dialogue.instantiate()
		_d.data = ScriptData.gift_letter
		Global.hud.add_child(_d)
		_d.closed.connect(func():
			if Save.data.story_point == "ratchet_gratitude":
				Save.advance_story() # only advance once (on the right story step)!
			await get_tree().process_frame
			Global.command_sent.emit("/giftletter"))
		_d.open()
	
	elif Save.data.story_point == "gratitude":
		var _d = Dialogue.instantiate()
		_d.data = ScriptData.raiqqo_dialogue
		Global.hud.add_child(_d)
		_d.open()
	
	elif Save.data.story_point == "stewardship":
		var _d = Dialogue.instantiate()
		_d.data = ScriptData.gift
		Global.hud.add_child(_d)
		_d.closed.connect(func():
			check_dialogue_achieved()
			if Save.data.story_point == "stewardship":
				SettingsHandler.update("show_gift_item", "show"))
		_d.open()
	else: _dialogue_spawned = false
	
	# If true, dialogue has spawned and we can show the characters
	if _dialogue_spawned:
		var _chara_jade = CharaViewer.instantiate()
		Global.hud.get_node("TopLevel").add_child(_chara_jade)
		_chara_jade.set_anchors_preset(Control.PRESET_CENTER)
		_chara_jade.position = get_viewport().size / Global.retina_scale * 0.5 - _chara_jade.size / 2.0
		_chara_jade.position.x -= VIEWER_X_OFFSET
		_chara_jade.load_model("res://lib/player/meshes/jade_bot.glb",
			"AnimationPlayer", {
			"y_rotation": 35.0,
			"exclusion_meshes": [
				"JadeArmature/Skeleton3D/EngineGlowCard",
				"JadeArmature/Skeleton3D/PlushBase",
				"JadeArmature/Skeleton3D/PlushBorder",
				"JadeArmature/Skeleton3D/PlushEars",
				"JadeArmature/Skeleton3D/PlushSides",
				"JadeArmature/Skeleton3D/PlushTail"
			]
		})
		
		var _chara_pulley = CharaViewer.instantiate()
		Global.hud.get_node("TopLevel").add_child(_chara_pulley)
		_chara_pulley.set_anchors_preset(Control.PRESET_CENTER)
		_chara_pulley.position = get_viewport().size / Global.retina_scale * 0.5 - _chara_pulley.size / 2.0
		_chara_pulley.position.x += VIEWER_X_OFFSET
		_chara_pulley.load_model("res://lib/pulley/meshes/pulley.glb",
			"AnimationPlayer", {
			"y_rotation": -35.0,
			"scale": Vector3(0.6, 0.6, 0.6)
		})
