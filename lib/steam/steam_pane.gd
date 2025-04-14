extends "res://lib/ui_container/ui_container.gd"

const AchievementBox = preload("res://lib/steam/achievements/achievement_box.tscn")
var is_ready = false

func open(silent = false) -> void:
	if is_open:
		return
	is_ready = false
	$Container/CScroll.visible = false
	$Spinner.visible = true
	super(silent)
	SteamHandler.refresh_stats()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _a in SteamHandler.AchievementsList:
		var _ab = AchievementBox.instantiate()
		_ab.achievement_id = _a
		$Container/CScroll/CBox.add_child(_ab)
	
	SteamHandler.stats_refreshed.connect(func():
		is_ready = true
		$Spinner.visible = false
		$Container/CScroll.visible = true
		
		$Container/CScroll/CBox/C1.title_left = "Karma earned"
		$Container/CScroll/CBox/C1.amount_left = SteamHandler.stats.karma_earned
		
		$Container/CScroll/CBox/C1.title_right = "Weeds picked"
		$Container/CScroll/CBox/C1.amount_right = SteamHandler.stats.weeds_picked
		
		$Container/CScroll/CBox/C2.title_left = "Bugs cleared"
		$Container/CScroll/CBox/C2.amount_left = SteamHandler.stats.bugs_cleared
		
		$Container/CScroll/CBox/C2.title_right = "Dragonvoid dispelled"
		$Container/CScroll/CBox/C2.amount_right = SteamHandler.stats.void_dispelled
		
		$Container/CScroll/CBox/C3.title_left = "Decorations placed"
		$Container/CScroll/CBox/C3.amount_left = SteamHandler.stats.decos_placed
	)

func _process(delta: float) -> void:
	super(delta)
	if !$Spinner.visible:
		return
	$Spinner.rotation += delta * 2.0
	if $Spinner.rotation >= 2 * PI:
		$Spinner.rotation = 0

func _on_reset_button_down() -> void:
	Global.command_sent.emit("/clearstats")
