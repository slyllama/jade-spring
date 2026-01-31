@tool
extends Decoration

func _ready():
	super()
	if Engine.is_editor_hint(): return
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/time=night": $LightRay.visible = false
		elif _cmd == "/time=day": $LightRay.visible = true)
