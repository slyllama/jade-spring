extends VBoxContainer

var _target_bug_ratio := 0.0
var _last_bug_ratio = _target_bug_ratio
var _target_weed_ratio := 0.0
var _last_weed_ratio = _target_weed_ratio
var first_load = false

func _get_bug_ratio() -> float:
	return((100 - Save.data.crumb_count.bug
		/ float(Global.crumb_handler.totals.bug) * 100))

func _get_weed_ratio () -> float:
	return((100 - Save.data.crumb_count.weed
		/ float(Global.crumb_handler.totals.weed) * 100))

func proc_story() -> void:
	# TODO: show different depending on where we are at in the story.
	#if Save.data.story_point == "bulwark_gyro":
		#$Blank2.visible = true
		#$WeedsText.visible = true
		#$WeedsBar.visible = true
		#$Blank.visible = true
	
	# Update sidebar with story contents when the story is advanced
	var _p = Save.data.story_point # story point shorthand
	if _p in Save.STORY_POINT_SCRIPT:
		var _d = Save.STORY_POINT_SCRIPT[_p] # data shorthand
		if "objective" in Save.STORY_POINT_SCRIPT[_p]:
			$StoryText.text = _d.objective
			if Save.data.story_point == "bulwark_gyro":
				$StoryText.text += " (" + str(10 - (Global.crumb_handler.totals.weed
					- Save.data.crumb_count.weed)) + " remaining)"

func _ready() -> void:
	Global.crumbs_updated.connect(func():
		for _i in 3: await get_tree().process_frame
		if "bug" in Save.data.crumb_count and "bug" in Global.crumb_handler.totals:
			_target_bug_ratio = _get_bug_ratio()
			if !first_load:
				$BugsBar/Panel/Bar.value = _get_bug_ratio()
				first_load = true
		if "weed" in Save.data.crumb_count and "weed" in Global.crumb_handler.totals:
			_target_weed_ratio = _get_weed_ratio()
			if !first_load:
				$WeedsBar/Panel/Bar.value = _get_weed_ratio()
				first_load = true
			
			proc_story())
	
	Save.story_advanced.connect(proc_story)
	#proc_story()

func _process(delta: float) -> void:
	if _last_bug_ratio != _target_bug_ratio:
		Global.play_flash($BugsBar.global_position + Vector2(20, 7))
	if _last_weed_ratio != _target_weed_ratio:
		Global.play_flash($WeedsBar.global_position + Vector2(20, 7))
	
	$BugsBar/Panel/Bar.value = lerp(
		$BugsBar/Panel/Bar.value, _target_bug_ratio, delta * 9)
	$WeedsBar/Panel/Bar.value = lerp(
		$WeedsBar/Panel/Bar.value, _target_weed_ratio, delta * 9)
	
	_last_bug_ratio = _target_bug_ratio
	_last_weed_ratio = _target_weed_ratio
