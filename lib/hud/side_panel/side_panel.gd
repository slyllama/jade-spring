extends VBoxContainer

var _target_bug_ratio := 0.0
var _last_bug_ratio = _target_bug_ratio
var _target_weed_ratio := 0.0
var _last_weed_ratio = _target_weed_ratio
var _target_dv_ratio := 0.0
var _last_dv_ratio = _target_dv_ratio

var first_load = false
var karma_fist_load = false

var ignore_story_updates = true

func _get_bug_ratio() -> float:
	return((100 - Save.data.crumb_count.bug
		/ float(Global.crumb_handler.totals.bug) * 100))

func _get_dv_ratio() -> float:
	return((100 - Save.data.crumb_count.dragonvoid
		/ float(Global.crumb_handler.totals.dragonvoid) * 100))

func _get_weed_ratio () -> float:
	var _ratio = (Save.data.deposited_weeds
		/ float(Global.crumb_handler.totals.weed) * 100)
	return(_ratio)

func update_roster_visibility(pos: int) -> void:
	if pos >= 0:
		$Subtitle.visible = false
		$WeedsText.visible = false
		$WeedsBar.visible = false
		$BugsText.visible = false
		$BugsBar.visible = false
		$DVText.visible = false
		$DVBar.visible = false
		$MinorSeparator.visible = false
		$B_U.visible = false
		$B_L.visible = false
		$Separator3.visible = false
	if pos >= 1:
		$Subtitle.visible = true
		$WeedsText.visible = true
		$WeedsBar.visible = true
		
		$MinorSeparator.visible = true
		$B_U.visible = true
		$B_L.visible = true
		$Separator3.visible = true
	if pos >= 2:
		$BugsText.visible = true
		$BugsBar.visible = true
	if pos >= 3:
		$DVText.visible = true
		$DVBar.visible = true
	if pos >= 4:
		$StoryText.visible = false
		for _n in get_tree().get_nodes_in_group("Roster"):
			_n.visible = false
		$Completion.visible = true

func fade_in(time = 0.9) -> void:
	var _fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, time)

func proc_story() -> void:
	# Update sidebar with story contents when the story is advanced
	var _p = Save.data.story_point # story point shorthand
	
	if _p == "game_start":
		update_roster_visibility(0)
	elif _p == "pick_weeds":
		update_roster_visibility(1)
	elif _p == "clear_bugs":
		update_roster_visibility(2)
	elif _p == "ratchet_dv":
		update_roster_visibility(3)
	elif _p == "clear_dv":
		update_roster_visibility(3)
	elif _p == "charged_dv":
		update_roster_visibility(3)
	elif _p == "ratchet_gratitude":
		update_roster_visibility(3)
	elif _p == "gratitude":
		update_roster_visibility(3)
	elif _p == "stewardship":
		update_roster_visibility(4)
	
	if _p in Save.STORY_POINT_SCRIPT:
		var _d = Save.STORY_POINT_SCRIPT[_p] # data shorthand
		if "objective" in Save.STORY_POINT_SCRIPT[_p]:
			$StoryText.text = "[font_size=18]" + _d.title + "[/font_size]\n" + _d.objective
			if Save.data.story_point == "pick_weeds":
				$StoryText.text += " (" + str(Save.data.deposited_weeds) + "/" + str(Save.OBJECTIVE_WEED_COUNT) + ")"
			elif Save.data.story_point == "clear_bugs":
				$StoryText.text += " (" + str(Global.crumb_handler.totals.bug - Save.data.crumb_count.bug) + "/" + str(Save.OBJECTIVE_PEST_COUNT) + ")"

func _ready() -> void:
	modulate.a = 0.0
	
	Global.crumbs_updated.connect(func():
		for _i in 3: await get_tree().process_frame
		if "bug" in Save.data.crumb_count and "bug" in Global.crumb_handler.totals:
			_target_bug_ratio = _get_bug_ratio()
			if !first_load:
				$BugsBar/Panel/Bar.value = _get_bug_ratio()
		if "dragonvoid" in Save.data.crumb_count and "dragonvoid" in Global.crumb_handler.totals:
			_target_dv_ratio = _get_dv_ratio()
			if !first_load:
				$DVBar/Panel/Bar.value = _get_dv_ratio()
		if "deposited_weeds" in Save.data and "weed" in Global.crumb_handler.totals:
			_target_weed_ratio = _get_weed_ratio()
			if !first_load:
				$WeedsBar/Panel/Bar.value = _get_weed_ratio()
			proc_story()
		
		if !first_load:
			first_load = true)
	
	Global.close_story_panel.connect(func():
		if Save.data.story_point == "game_start":
			fade_in(1.5))
	
	Save.story_advanced.connect(func():
		#Global.play_flash($StoryText.global_position + Vector2(40, 30))
		proc_story())
	
	Save.karma_changed.connect(func():
		if !"karma" in Save.data: return
		$Details/DetailsBox/StatsBox/KarmaCount.text = str(Save.data.karma) + " Karma"
		if karma_fist_load:
			Global.play_flash(
				$Details/DetailsBox/StatsBox/KarmaCount.global_position + Vector2(5, 5)))
	
	Save.karma_changed.emit()
	karma_fist_load = true
	
	if !Global.start_params.new_save:
		fade_in()

var _j = 0.0

func _process(delta: float) -> void:
	# Get decoration count (every now and then)
	_j += delta
	if _j >= 0.5:
		_j = 0.0
		var _deco_count = Global.decorations.size()
		var _deco_string = str(_deco_count) + " decorations"
		if _deco_count == 1:
			_deco_string = str(_deco_count) + " decoration"
		$Details/DetailsBox/StatsBox/DecoCount.text = _deco_string
	
	if _last_bug_ratio != _target_bug_ratio:
		if !ignore_story_updates:
			Global.play_flash($BugsBar.global_position + Vector2(20, 7))
	if _last_dv_ratio != _target_dv_ratio:
		if !ignore_story_updates:
			Global.play_flash($DVBar.global_position + Vector2(20, 7))
	if _last_weed_ratio != _target_weed_ratio:
		if !ignore_story_updates:
			Global.play_flash($WeedsBar.global_position + Vector2(20, 7))
	
	$BugsBar/Panel/Bar.value = lerp(
		$BugsBar/Panel/Bar.value, _target_bug_ratio, delta * 9)
	$DVBar/Panel/Bar.value = lerp(
		$DVBar/Panel/Bar.value, _target_dv_ratio, delta * 9)
	$WeedsBar/Panel/Bar.value = lerp(
		$WeedsBar/Panel/Bar.value, _target_weed_ratio, delta * 9)
	
	_last_bug_ratio = _target_bug_ratio
	_last_dv_ratio = _target_dv_ratio
	_last_weed_ratio = _target_weed_ratio

func _on_ignore_story_updates_timeout() -> void:
	ignore_story_updates = false
