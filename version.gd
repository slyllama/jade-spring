extends Node

const VER = "1.1b"
const TARGET = "itch"
const VER_HTTPS = "https://www.slyllama.net/jade-spring/vercheck.json"

signal latest_version_retrieved(latest_version)
@onready var request = HTTPRequest.new()

func _ready():
	add_child(request)
	request.request_completed.connect(func(result, status, _headers, body):
		if result != 0: return # couldn't connect
		if status != HTTPClient.RESPONSE_OK: return # invalid connection
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		if "versions" in json_data:
			latest_version_retrieved.emit(json_data.versions[0]))
	request.request(VER_HTTPS)
