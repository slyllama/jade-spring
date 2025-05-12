extends AudioStreamPlayer
# Jukebox
# The jukebox makes sure that music is always playing appropriately

@export var track_list: Array[AudioStreamOggVorbis]
@export var start_muted := false
@export var music_enabled := true
@export var delay := 24.0

var rng = RandomNumberGenerator.new()
var tracks: Array[AudioStreamOggVorbis] = []
var tracks_alt: Array[AudioStreamOggVorbis] = []
var using_alt = false
var volume_set = 0.0

var space_timer = Timer.new()
var override_track = AudioStreamPlayer.new()

# Will randomly select tracks from `tracks` and swap them over to `tracks_alt`
# until they have all been used up, and then do the same from `tracks_alt`;
# `using_alt` is used to keep track of this
func load_track() -> void:
	if !using_alt:
		var selected_id = rng.randi_range(0, tracks.size() - 1)
		set_stream(tracks[selected_id])
		play()
		tracks_alt.append(tracks[selected_id])
		tracks.remove_at(selected_id)
		if tracks == []: using_alt = true
		return
	else:
		var selected_id = rng.randi_range(0, tracks_alt.size() - 1)
		set_stream(tracks_alt[selected_id])
		play()
		tracks.append(tracks_alt[selected_id])
		tracks_alt.remove_at(selected_id)
		if tracks_alt == []: using_alt = false
		return

func play_override(_get_stream: AudioStreamOggVorbis) -> void:
	override_track.stream = _get_stream
	override_track.play()

func _ready() -> void:
	Global.attenuator_closed.connect(func():
		await get_tree().process_frame
		if !override_track.playing:
			Global.target_music_ratio = 1.0)
	
	Global.override_track_play.connect(play_override)
	
	override_track.finished.connect(func():
		if !Global.attenuator_open:
			Global.target_music_ratio = 1.0)
	
	volume_db = -80.0
	space_timer.one_shot = true
	
	add_child(space_timer)
	add_child(override_track)
	
	space_timer.timeout.connect(load_track)
	finished.connect(func():
		space_timer.wait_time = delay
		space_timer.start())
	
	# `enabled` only disables music, not sound effects
	if !music_enabled: return
	if track_list == []:
		print("[Jukebox] music not configured.")
		return
	tracks = track_list.duplicate()
	
	await get_tree().create_timer(2.0).timeout
	load_track()

func _process(_delta: float) -> void:
	if track_list == []: return
	volume_db = linear_to_db(clamp(volume_set, 0.0, 0.34) * clamp(ease(Global.target_music_ratio, 3.6), 0.001, 1.0))
