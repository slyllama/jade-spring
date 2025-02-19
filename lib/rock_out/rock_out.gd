extends Node3D

const BEAT: float = 3.0/7.0 # duration of a single beat, in seconds

var in_range = false
var count = -1

func _process(_delta: float) -> void:
	var time = $Music.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	
	var _b = 0
	if time > BEAT:
		while time > BEAT:
			time -= BEAT
			_b += 1
	if count != _b:
		count = _b
		$Music/SpatialText.spatial_string = str(count + 1)

func _on_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_range = true
		$Music.play()
		Global.target_music_ratio = 0.0
		Global.rock_out_started.emit()

func _on_area_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_range = false
		$Music.stop()
		Global.target_music_ratio = 1.0
		Global.rock_out_ended.emit()
