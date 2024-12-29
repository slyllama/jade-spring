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
	var _ratio = (Save.data.deposited_weeds
		/ float(Global.crumb_handler.totals.weed) * 100)
	return(_ratio)

func proc_story() -> void:
	# TODO: show different depending on where we are at in the story.
	if Save.data.story_point == "pick_weeds":
		$B_U.visible = true
		$B_L.visible = true
		
		$WeedsText.visible = true
		$WeedsBar.visible = true
	if Save.data.story_point == "clear_bugs":
		$B_U.visible = true
		$B_L.visible = true
		
		$BugsText.visible = true
		$BugsBar.visible = true
		$WeedsText.visible = true
		$WeedsBar.visible = true
	
	# Update sidebar with story contents when the story is advanced
	var _p = Save.data.story_point # story point shorthand
	if _p in Save.STORY_POINT_SCRIPT:
		var _d = Save.STORY_POINT_SCRIPT[_p] # data shorthand
		if "objective" in Save.STORY_POINT_SCRIPT[_p]:
			$StoryText.text = _d.objective
			if Save.data.story_point == "pick_weeds":
				$StoryText.text += " (" + str(Save.OBJECTIVE_WEED_COUNT - Save.data.deposited_weeds) + " remaining)"

func _ready() -> void:
	Global.crumbs_updated.connect(func():
		for _i in 3: await get_tree().process_frame
		if "bug" in Save.data.crumb_count and "bug" in Global.crumb_handler.totals:
			_target_bug_ratio = _get_bug_ratio()
			if !first_load:
				$BugsBar/Panel/Bar.value = _get_bug_ratio()
				first_load = true
		if "deposited_weeds" in Save.data and "weed" in Global.crumb_handler.totals:
			_target_weed_ratio = _get_weed_ratio()
			if !first_load:
				$WeedsBar/Panel/Bar.value = _get_weed_ratio()
				first_load = true
			proc_story())
	
	Save.story_advanced.connect(func():
		Global.play_flash($StoryText.global_position + Vector2(40, 30))
		proc_story())

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
		$Details/DetailsBox/DecorationCount.text = _deco_string
	
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
