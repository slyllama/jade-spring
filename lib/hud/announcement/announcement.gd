extends RichTextLabel

var active = false

func play(get_text: String) -> void:
	text = "[center]" + get_text + "[/center]"
	visible = true
	
	if !active:
		modulate.a = 0
		var fade_in = create_tween()
		fade_in.tween_property(self, "modulate:a", 1.0, 0.2)
	active = true
	$Timer.start()

func _ready() -> void:
	Global.announcement_sent.connect(play)

func _on_timer_timeout() -> void:
	active = false
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.2)
	fade_out.tween_callback(func():
		if !active:
			visible = false)
