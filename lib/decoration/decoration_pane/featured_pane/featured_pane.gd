extends Panel

signal featured_deco_selected(id: String)
signal tag_selected(id: String)

const CAROUSEL_WIDTH = 480 # how many pixels needed to move the scroll container to the next value
@onready var CarouselContainer: ScrollContainer = $Base/Carousel/ScrollContainer
@onready var PrevButton: TextureButton = $Base/Carousel/Previous
@onready var NextButton: TextureButton = $Base/Carousel/Next
@onready var carousel_count = $Base/Carousel/ScrollContainer/Box.get_child_count()

var transitioning = false
var current_idx = 0

func _set_carousel_offset(pixels: int) -> void:
	CarouselContainer.set_deferred("scroll_horizontal", pixels)

func set_carousel_position(idx: int) -> void:
	if transitioning: return
	$CarouselTimer.start()
	
	if idx < 0: idx = carousel_count - 1
	elif idx > carousel_count - 1: idx = 0
	
	transitioning = true
	var _carousel_tween = create_tween()
	_carousel_tween.tween_method(
		_set_carousel_offset,
		CAROUSEL_WIDTH * current_idx,
		CAROUSEL_WIDTH * idx, 0.54
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await _carousel_tween.finished
	current_idx = idx
	transitioning = false

func _ready() -> void:
	# Connect "previous" and "next" buttons
	PrevButton.button_down.connect(func():
		$PageTurn.play()
		set_carousel_position(current_idx - 1))
	NextButton.button_down.connect(func():
		$PageTurn.play()
		set_carousel_position(current_idx + 1))
	
	# Connect clicking of featured panes
	for _n in CarouselContainer.get_node("Box").get_children():
		if _n is TextureRect:
			_n.modulate.a = 0.9
			_n.mouse_entered.connect(func(): _n.modulate.a = 1.2)
			_n.mouse_exited.connect(func(): _n.modulate.a = 0.9)
			
			_n.gui_input.connect(func(_event):
				if Input.is_action_just_pressed("left_click"):
					if _n.has_meta("decoration_reference"):
						featured_deco_selected.emit(_n.get_meta("decoration_reference"))
					if _n.has_meta("tag_reference"):
						tag_selected.emit(_n.get_meta("tag_reference"))
			)

func _on_carousel_timer_timeout() -> void:
	set_carousel_position(current_idx + 1)
