extends RichTextLabel

var active = false

func play(announcement: String) -> void:
	text = "[center]" + announcement + "[/center]"
	visible = true
	$Timer.stop()
	active = true
	$Timer.start()

func _ready() -> void:
	Global.announcement_sent.connect(play)

func _process(delta):
	if !active and modulate.a > 0.0:
		modulate.a -= Utilities.critical_lerp(delta, 1.5)
	elif active and modulate.a < 1.0:
		modulate.a += Utilities.critical_lerp(delta, 8.0)

func _on_timer_timeout() -> void:
	active = false
