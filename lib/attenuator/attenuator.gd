@tool
extends CanvasLayer

signal closed

var PianoKey = load("res://lib/attenuator/piano_key.tscn")

const NOTES = [
	{"float": 0.0, "color": Color.CADET_BLUE},	# C
	{"float": 1.0, "color": Color.WHITE},		# D
	{"float": 2.1, "color": Color.WHITE},		# E
	{"float": 2.65, "color": Color.WHITE},		# F
	{"float": 4.1, "color": Color.WHITE},		# G
	{"float": 5.5, "color": Color.WHITE},		# A
	{"float": 7.2, "color": Color.WHITE},		# B
]
const NOTE_PATHS = [
	"res://lib/attenuator/sounds/c1.ogg",
	"res://lib/attenuator/sounds/d1.ogg",
	"res://lib/attenuator/sounds/e1.ogg",
	"res://lib/attenuator/sounds/f1.ogg",
	"res://lib/attenuator/sounds/g1.ogg",
	"res://lib/attenuator/sounds/a1.ogg",
	"res://lib/attenuator/sounds/b1.ogg",
	"res://lib/attenuator/sounds/c2.ogg",
	"res://lib/attenuator/sounds/d2.ogg",
	"res://lib/attenuator/sounds/e2.ogg",
	"res://lib/attenuator/sounds/f2.ogg",
	"res://lib/attenuator/sounds/g2.ogg",
	"res://lib/attenuator/sounds/a2.ogg",
	"res://lib/attenuator/sounds/b2.ogg",
	"res://lib/attenuator/sounds/c3.ogg"
]
const KEY_INDICES = [
	"c1", "d1", "e1", "f1", "g1", "a1", "b1",
	"c2", "d2", "e2", "f2", "g2", "a2", "b2", "c2" ]
const TUNES = {
	"primordus": [ "_", "a1", "a2", "b2", "b2", "_", "e2", "g2", "a2", "e2" ],
	"soo_won": [ "d1", "e1", "f1", "e1", "f1", "g1", "a1", "f1", "d1", "g1", "e1", "c1" ],
	"mordremoth": [ "a1", "_", "c2", "b1", "_", "c2", "e2", "_", "c2", "b1", "_", "c2" ],
	"zhaitan": [ "e2", "_", "b1", "c2", "_", "a1", "b1", "_", "b1" ],
	"kralkatorrik": [ "a1", "_", "a1", "e1", "f1", "_", "b1", "_", "a1", "b1", "c2", "b1" ],
	"jormag": [ "e1", "c1", "a1", "e2", "_", "f2", "b1" ]
}
var SUCCESS_TUNES = {
	"mordremoth": load("res://lib/attenuator/sounds/mordremoth_success.ogg"),
	"soo_won": load("res://lib/attenuator/sounds/soo_won_success.ogg"),
	"primordus": load("res://lib/attenuator/sounds/primordus_success.ogg"),
	"kralkatorrik": load("res://lib/attenuator/sounds/kralkatorrik_success.ogg"),
	"jormag": load("res://lib/attenuator/sounds/jormag_success.ogg"),
	"zhaitan": load("res://lib/attenuator/sounds/zhaitan_success.ogg")
}
const TUNES_ORDER = [ "primordus", "soo_won", "mordremoth", "zhaitan", "kralkatorrik", "jormag" ]

@export var supress_hint = false

var current_dragon = "primordus"
var two_oct = NOTES.duplicate()
var place = 0
var target_track
var passing = true
var succeeded = false
var has_closed = false
var moused_note_y_pos = 0.0
var cursor_key: HBoxContainer # the current key the cursor is highlighting
var session_types = [] # Dragonvoid types on the map

@onready var glyph_box: TextureRect = $Base/ControlContainer/GlyphContainer

func _set_ee_paint_exponent(val: float) -> void:
	$Base/EEUpper.material.set_shader_parameter("dissolve_value", val)

func _set_paint_exponent(val: float) -> void:
	# These are set separately because they shouldn't be dimmed
	# (options are always available)
	$Base/ControlContainer/Reset.self_modulate.a = 1.0 - val
	$Base/ControlContainer/Close.self_modulate.a = 1.0 - val
	
	$Base.material.set_shader_parameter("paint_exponent", ease(val, 2.0) * 10.0)
	$Base/EEUpper.material.set_shader_parameter("dissolve_value", 1.0 - ease(val, 2.0))
	$Base/Cursor.material.set_shader_parameter("alpha", (1.0 - val) * 0.65)
	$Base/KeyContainer.material.set_shader_parameter("paint_exponent", ease(val, 2.0))

func _set_base_darkness(val: float) -> void:
	$Base.material.set_shader_parameter("darken", val)

func _set_banner_value(val: float) -> void:
	var _e = ease(val, 0.2)
	$SuccessBanner.material.set_shader_parameter("alpha", val)
	$SuccessBanner.material.set_shader_parameter("paint_exponent", 0.01 + (1 - _e) * 9.0)

func present_glyph() -> void: # present a glyph based on the current Elder Dragon
	for _n in glyph_box.get_children():
		_n.queue_free()
	
	var glyph_sprite = Sprite2D.new()
	glyph_sprite.modulate.a = 0.0
	glyph_sprite.use_parent_material = true
	glyph_sprite.texture = load(
		"res://lib/attenuator/textures/glyphs/" + current_dragon + ".png")
	$SuccessBanner/Rune.texture = load( # TODO: streamline this
		"res://lib/attenuator/textures/glyphs/" + current_dragon + ".png")
	glyph_box.add_child(glyph_sprite)
	
	var _g_fade_tween = create_tween()
	_g_fade_tween.tween_property(glyph_sprite, "modulate:a", 1.0, 0.2)
	var _g_scale_tween = create_tween()
	_g_scale_tween.tween_property(glyph_sprite, "scale", Vector2(0.4, 0.4), 0.2)
	_g_scale_tween.parallel()

func _set_prev_next_keys() -> void:
	var current_index = TUNES_ORDER.find(current_dragon, 0)
	if current_index >= TUNES_ORDER.size() - 1: $Base/ControlContainer/ArrowBox/Next.disabled = true
	else: $Base/ControlContainer/ArrowBox/Next.disabled = false
	if current_index - 1 < 0: $Base/ControlContainer/ArrowBox/Previous.disabled = true
	else: $Base/ControlContainer/ArrowBox/Previous.disabled = false

func select_dragon(forward = true) -> void:
	var current_index = TUNES_ORDER.find(current_dragon, 0)
	if forward:
		if current_index < TUNES_ORDER.size() - 1:
			current_dragon = TUNES_ORDER[current_index + 1]
			await get_tree().process_frame
			render()
	else:
		if current_index > 0:
			current_dragon = TUNES_ORDER[current_index - 1]
			await get_tree().process_frame
			render()
	_set_prev_next_keys()

func _reset_dim() -> void: # reset fail-state dim to original
	var _dt = create_tween()
	_dt.tween_method(
		_set_base_darkness,
		$Base.material.get_shader_parameter("darken"),
		0.0, 0.1)

func render() -> void:
	session_types = Global.crumb_handler.get_dv_types()
	if current_dragon in session_types:
		$Base/ControlContainer/IsOnMap.text = "[center]Sensor Status: Detected[/center]"
		$Base/ControlContainer/IsOnMap.modulate = Color("c2f177")
	else:
		$Base/ControlContainer/IsOnMap.text = "[center]Sensor Status: Not Detected[/center]"
		$Base/ControlContainer/IsOnMap.modulate = Color("8f5e6e")
	
	# Reset from success state
	$Base/ControlContainer/ArrowBox/Previous.disabled = false
	$Base/ControlContainer/ArrowBox/Next.disabled = false
	$Base/Marker.visible = true
	$KeyCursor.visible = true
	$Base/ControlContainer/Reset.disabled = false
	
	$SuccessBanner.visible = false
	_set_banner_value(0.0)
	_set_paint_exponent(0.0)
	
	place = 0
	present_glyph()
	var _title = Utilities.DRAGON_DATA[current_dragon].name
	$Base/ControlContainer/DragonTitle.text = "[center]" + _title + "[/center]"
	
	# Reset
	for _n in $Base/KeyContainer.get_children():
		_n.queue_free() # clear out
	_adv_blank_place()
	await get_tree().process_frame
	
	var _d = 0
	for _i in two_oct:
		var _n = PianoKey.instantiate()
		_n.get_node("Note").stream = load(NOTE_PATHS[_d])
		_n.id = _d
		_n.note_name = KEY_INDICES[_d]
		_n.modulate = _i.color
		_n.mouse_entered.connect(func():
			cursor_key = _n
			moused_note_y_pos = _n.global_position.y)
		_n.played.connect(func():
			var played_note = KEY_INDICES[_n.id]
			var correct_note = TUNES[current_dragon][place]
			if played_note != correct_note:
				if passing:
					# FAIL
					var _dt = create_tween()
					_dt.tween_method(_set_base_darkness, 0.0, 0.5, 0.1)
					Global.play_flash(
						$Base/ControlContainer/Reset.global_position + Vector2(60, 16))
					var ee_fade_tween = create_tween()
					ee_fade_tween.tween_method(_set_ee_paint_exponent, 1.0, 0.0, 0.3)
				passing = false
			
			if place < TUNES[current_dragon].size() - 1 and passing:
				place += 1
				_adv_blank_place()
				$Click.play()
			else:
				if place == TUNES[current_dragon].size() - 1 and passing:
					# SUCCESS
					succeeded = true
					$SuccessBanner/Base.self_modulate = Utilities.DRAGON_DATA[current_dragon].color
					$SuccessBanner/DragonTitle.text = ("[center]"
						+ str(Utilities.DRAGON_DATA[current_dragon].name).to_upper() + "[/center]")
					$SuccessBanner/Quote.text = ("[center]" + Utilities.LDQUO
						+ Utilities.DRAGON_DATA[current_dragon].quote
						+ Utilities.RDQUO + "[/center]")
					Global.ripple.emit() # used for emitting screen effects
					
					#Global.remove_effect.emit("discombobulator")
					Global.add_effect.emit("d_" + current_dragon)
					for _o in $Base/KeyContainer.get_children():
						_o.disable()
					
					# Make achievement check for holding all Dragonvoid
					var dv_count := 0
					for effect: String in Global.current_effects:
						if "d_" in effect:
							dv_count += 1
					if dv_count == Utilities.DRAGON_DATA.size():
						if SteamHandler.get_achievment_completion("the_all") == 0:
							SteamHandler.complete_achievement("the_all")
					
					# Disable and hide various keys - the inverse has to be done too
					$Base/Cursor.visible = false
					$KeyCursor.visible = false
					$Base/ControlContainer/ArrowBox/Previous.disabled = true
					$Base/ControlContainer/ArrowBox/Next.disabled = true
					$Base/ControlContainer/Reset.disabled = true
					$Base/Marker.visible = false
					
					$SuccessBanner/Close2.grab_focus()
					
					$Success.play()
					$SuccessBanner.visible = true
					_set_base_darkness(0.86)
					var banner_tween = create_tween()
					banner_tween.tween_method(_set_banner_value, 0.0, 1.0, 0.2)
					
					if Save.data.story_point == "clear_dv":
						Save.advance_story()
					
					# Play the appropriate success tune (if one exists)
					await get_tree().create_timer(0.25).timeout
					Global.check_freshness.emit()
					if current_dragon in SUCCESS_TUNES:
						Global.override_track_play.emit(SUCCESS_TUNES[current_dragon])
		)
		$Base/KeyContainer.add_child(_n)
		
		_n.set_pills_size(TUNES[current_dragon].size())
		_n.set_pills_color(Utilities.DRAGON_DATA[current_dragon].color)
		if _d == 0:
			cursor_key = _n
			moused_note_y_pos = _n.global_position.y # initial set
		_d += 1
	
	var _c = 0
	for _n in TUNES[current_dragon]:
		if _n != "_":
			var _key_index = KEY_INDICES.find(_n, 0)
			$Base/KeyContainer.get_children()[_key_index].assign_track([_c])
		_c += 1
	
	if !passing:
		passing = true
		var ee_fade_tween = create_tween()
		ee_fade_tween.tween_method(_set_ee_paint_exponent, 0.0, 1.0, 0.3)
	target_track = $Base/KeyContainer.get_children()[0]
	
	for _n in $Base/KeyContainer.get_children():
		if !is_instance_valid(_n): continue
		if "alpha" in _n:
			_n.alpha = 1.0
		await get_tree().create_timer(0.03).timeout

func close(instant = false) -> void:
	if has_closed: return
	
	cursor_key = null
	await get_tree().process_frame # queue for next frame so settings doesn't open
	has_closed = true
	
	Global.attenuator_open = false
	Global.can_move = true
	Global.in_exclusive_ui = false
	Global.tool_mode = Global.TOOL_MODE_NONE
	Global.dismiss_hints()
	
	closed.emit()
	Global.attenuator_closed.emit()
	
	if Utilities.has_dv_charge():
		Global.play_hint("charged_dv", { 
			"title": "Holding Charged Flux",
			"arrow": "down",
			"anchor_preset": Control.LayoutPreset.PRESET_CENTER_BOTTOM,
			"text": "You are holding Attuned Dispersion Flux. Interact with the corresponding Dragonvoid blight to dispel it!"
		}, Utilities.get_screen_center(Vector2(0, get_viewport().size.y / Global.retina_scale * 0.5 - 300)), true)
	
	if !instant:
		$DispulsionFX.anim_out()
		var fade_tween = create_tween()
		fade_tween.tween_method(_set_paint_exponent, 0.0, 1.0, 0.2)
		await $DispulsionFX.anim_out_complete
	
	Global.player.update_golem_effects()
	queue_free()

func _adv_blank_place() -> void:
	if TUNES[current_dragon][place] == "_":
		place += 1

func _ready() -> void:
	$Base/Cursor.visible = true
	
	if Engine.is_editor_hint(): return
	$OpenSound.play()
	_set_base_darkness(0.0)
	Global.target_music_ratio = 0.0
	
	Global.can_move = false
	Global.attenuator_open = true
	Global.in_exclusive_ui = true
	Global.action_cam_disable.emit()
	Global.tool_mode = Global.TOOL_MODE_FISH
	
	for _i in NOTES:
		two_oct.append({"float": _i.float * 2.0 + 8.0, "color": _i.color})
	two_oct.append({"float": NOTES[0].float * 4.0 + 24.0, "color": NOTES[0].color})
	
	render()
	_set_prev_next_keys()
	
	$DispulsionFX.anim_duration = 0.15
	$DispulsionFX.anim_in()
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_paint_exponent, 1.0, 0.0, 0.3)
	var ee_fade_tween = create_tween()
	ee_fade_tween.tween_method(_set_ee_paint_exponent, 0.0, 1.0, 0.3)
	
	if !supress_hint:
		Global.play_hint("attunement_arrows", { 
			"title": "Dragon Attunement",
			"arrow": "left",
			"anchor_preset": Control.LayoutPreset.PRESET_CENTER,
			"text": "Use the arrows on the right to select the correct Elder Dragon for the Dragonvoid you want to attune to and clear."
		}, Utilities.get_screen_center(Vector2(120, -130)), true)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close()
	
	elif Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		if !succeeded:
			_on_previous_button_down()
	elif Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		if !succeeded:
			_on_next_button_down()
	
	if !cursor_key: return
	
	# Play whatever key the cursor is on
	if Input.is_action_just_pressed("interact"):
		if !succeeded:
			cursor_key.get_node("Note").play()
			cursor_key.played.emit()
		else:
			close()
	
	# Move the cursor up and down, if it is able to
	if Input.is_action_just_pressed("move_forward") or Input.is_action_just_pressed("ui_up"): # up
		var _keys = $Base/KeyContainer.get_children()
		var _prev_key_idx = _keys.find(cursor_key) - 1
		if _prev_key_idx >= 0:
			cursor_key = _keys[_prev_key_idx]
			moused_note_y_pos = _keys[_prev_key_idx].global_position.y
	elif Input.is_action_just_pressed("move_back") or Input.is_action_just_pressed("ui_down"): # down
		var _keys = $Base/KeyContainer.get_children()
		var _next_key_idx = _keys.find(cursor_key) + 1
		if _next_key_idx < _keys.size():
			cursor_key = _keys[_next_key_idx]
			moused_note_y_pos = _keys[_next_key_idx].global_position.y

func _on_close_button_down() -> void: close()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	$DispulsionFX.position.x = $Base.position.x + $Base.size.x / 2.0
	$DispulsionFX.position.y = $Base.position.y + 300.0
	$SuccessBanner.position.x = $Base.position.x + $Base.size.x / 2.0
	$SuccessBanner.position.y = $Base.position.y + $Base.size.y / 2.0
	
	
	if cursor_key: # move the key selector to the relevant key
		$KeyCursor.global_position = lerp(
			$KeyCursor.global_position,
			cursor_key.global_position + Vector2(100, 14),
			Utilities.critical_lerp(delta, 40.0))
	
	# Cursor follows mouse and highlights the whole row
	$Base/Cursor.global_position.y = lerp(
		$Base/Cursor.global_position.y,
		moused_note_y_pos,
		Utilities.critical_lerp(delta, 70.0))
	
	for _n in glyph_box.get_children():
		_n.position.x = glyph_box.size.x / 2.0
		_n.position.y = glyph_box.size.y / 2.0
	
	if !target_track: return # not ready yet
	if "pills" in target_track:
		var _target = target_track.pills[place]
		
		$Base/Marker.global_position.x = lerp(
			$Base/Marker.global_position.x,
			_target.global_position.x + _target.size.x / 2.0,
			Utilities.critical_lerp(delta, 20.0))
	
	$Base/Debug.text = ("place: " + str(place) + "/" + str(TUNES[current_dragon].size())
		+ "\npassing = " + str(passing))

func _on_reset_button_down() -> void:
	_reset_dim()
	Global.click_sound.emit()
	render()

func _on_next_button_down() -> void:
	if select_timeout: return
	select_timeout = true
	$SelectTimeout.start()
	
	_reset_dim()
	Global.click_sound.emit()
	Global.dismiss_hints()
	select_dragon()

func _on_previous_button_down() -> void:
	if select_timeout: return
	select_timeout = true
	$SelectTimeout.start()
	
	_reset_dim()
	Global.click_sound.emit()
	Global.dismiss_hints()
	select_dragon(false)

# Prevent double-ups
var select_timeout = false
func _on_select_timeout() -> void:
	select_timeout = false
