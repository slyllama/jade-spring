extends Node

const VER = "1.2b"
const TARGET = "steam"
const VER_HTTPS = "https://www.slyllama.net/jade-spring/vercheck.json"

signal latest_version_retrieved(latest_version)
@onready var request = HTTPRequest.new()
var version_check_complete = false

func _ready():
	add_child(request)
	request.request_completed.connect(func(result, status, _headers, body):
		if result != 0:
			version_check_complete = true # only do once
			return # couldn't connect
		if version_check_complete: return
		version_check_complete = true
		
		if status != HTTPClient.RESPONSE_OK: return # invalid connection
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		if "versions" in json_data:
			latest_version_retrieved.emit(json_data.versions[0]))
	request.request(VER_HTTPS)
