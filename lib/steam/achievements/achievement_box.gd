extends HBoxContainer

const completion_text = ["(Not Achieved)", "(Achieved)"]
@export var achievement_id: String
@onready var data = SteamHandler.Achievements[achievement_id]
var completed = -1

func refresh() -> void:
	completed = SteamHandler.get_achievment_completion(achievement_id)
	if completed == -1:
		return
	
	$TextBox/Title.text = data.title + " " + completion_text[completed]
	$TextBox/Description.text = data.desc
	if completed == 0:
		$Icon.texture = data.icon_unearned
	elif completed == 1:
		$Icon.texture = data.icon_earned

func _ready() -> void:
	if !achievement_id:
		queue_free()
		return
	SteamHandler.stats_refreshed.connect(refresh)
