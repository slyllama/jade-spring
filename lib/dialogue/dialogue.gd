extends CanvasLayer

signal closed

func open() -> void:
	Global.in_exclusive_ui = true
	Global.can_move = false
	$Player.play("Enter")

func close() -> void:
	closed.emit()
	Global.in_exclusive_ui = false
	Global.can_move = true
	queue_free()

func _ready() -> void:
	$Player.play("RESET")

func _on_done_button_down() -> void:
	close()
