extends VBoxContainer

var _target_bug_ratio := 0.0
var first_load = false

func _get_bug_ratio() -> float:
	return((100 - Global.crumb_data.bug.count
		/ float(Global.crumb_data.bug.total) * 100))

func _ready() -> void:
	Global.crumbs_updated.connect(func():
		if "bug" in Global.crumb_data:
			_target_bug_ratio = _get_bug_ratio()
			if !first_load:
				$BugsBar/Panel/Bar.value = _get_bug_ratio()
				first_load = true)

func _process(delta: float) -> void:
	$BugsBar/Panel/Bar.value = lerp(
		$BugsBar/Panel/Bar.value, _target_bug_ratio, delta * 9)
