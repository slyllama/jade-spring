extends Panel
# UIContainer
# A general UI container
const TRANS_TIME = 0.11
var rng = RandomNumberGenerator.new()
var mouse_in_ui = false
signal opened
signal closed

@export var title = "Title"
@export var closeable = true
@export var moveable = true
var is_open = false

@onready var current_position = position
var last_mouse_title_click = Vector2.ZERO
var mouse_in_title = false
var moving_window = false

func open(silent = false):
	if is_open: return
	
	is_open = true
	opened.emit()
	visible = true
	if !silent: # can set silent i.e., containers that spawn on map load
		$Paper.pitch_scale = 0.9 + rng.randf() * 0.2 # pitch variation - more organic
		$Paper.play()
	var open_tween = create_tween()
	open_tween.tween_property(self, "modulate:a", 1.0, TRANS_TIME)

func close():
	if !closeable or !is_open: return
	
	Global.click_sound.emit()
	is_open = false
	closed.emit()
	var close_tween = create_tween()
	close_tween.tween_property(self, "modulate:a", 0.0, TRANS_TIME)
	close_tween.tween_callback(func():
		if !is_open: visible = false)

func _ready():
	visible = false
	modulate.a = 0.0
	$Container/TitleContainer/Title.text = title
	$Container/TitleContainer/CloseButton.visible = closeable
	
	# Update panel position on window resize to avoid jumping
	get_window().size_changed.connect(func(): current_position = position)
	
	# Pass mouse events through UI elements, because non-orbit checks are done on the panel itself
	for _n in Utilities.get_all_children(self):
		if "mouse_filter" in _n: _n.mouse_filter = MOUSE_FILTER_PASS
		if _n is BaseButton:
			_n.button_down.connect(func(): Global.click_sound.emit())
	$Corner.mouse_filter = MOUSE_FILTER_IGNORE

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		if mouse_in_title:
			last_mouse_title_click = get_window().get_mouse_position()
			if moveable: moving_window = true
	if Input.is_action_just_released("left_click"):
		moving_window = false
		current_position = position

# Keep track of what the mouse is over at the moment
func _on_mouse_entered() -> void:
	mouse_in_ui = true
	Global.mouse_in_ui = true
func _on_mouse_exited() -> void:
	mouse_in_ui = false
	Global.mouse_in_ui = false
func _on_title_mouse_entered() -> void: mouse_in_title = true
func _on_title_mouse_exited() -> void: mouse_in_title = false

func _process(_delta: float) -> void:
	if !moveable: return
	if moving_window:
		var mouse_delta = get_window().get_mouse_position() - last_mouse_title_click
		position = current_position + mouse_delta
		# Prevent the settings window from being lost!
		position.x = clamp(position.x, -50.0, get_window().size.x - 50.0)
		position.y = clamp(position.y, -50.0, get_window().size.y - 50.0)
