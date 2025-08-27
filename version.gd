extends Node

const VER = "1.3b"
const TARGET = "steam"
const VER_HTTPS = "https://www.slyllama.net/jade-spring/vercheck.json"

signal latest_version_retrieved(latest_version)
@onready var request = HTTPRequest.new()

func request_latest_version() -> void:
	request.request(VER_HTTPS)

func _ready():
	add_child(request)
	request.request_completed.connect(func(result, status, _headers, body):
		if result != 0: return # couldn't connect
		
		if status != HTTPClient.RESPONSE_OK: return # invalid connection
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		
		if "ver-release" in json_data and "ver-prerelease" in json_data:
			latest_version_retrieved.emit({
				"release": json_data["ver-release"],
				"prerelease": json_data["ver-prerelease"]
			})
		)
