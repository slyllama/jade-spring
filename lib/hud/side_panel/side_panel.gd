extends VBoxContainer

var _target_bug_ratio := 0.0

func _ready() -> void:
	Global.crumbs_updated.connect(func():
		if ! "bug" in Global.crumb_data: return
		_target_bug_ratio = (100 - Global.crumb_data.bug.count
			/ float(Global.crumb_data.bug.total) * 100))

func _process(delta: float) -> void:
	$BugsBar/Panel/Bar.value = lerp(
		$BugsBar/Panel/Bar.value, _target_bug_ratio, delta * 9)
