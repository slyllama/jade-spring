@tool
extends Crumb

func interact() -> void:
	#if "discombobulator" in Global.current_effects:
	var _f = FishingInstance.instantiate()
	_f.completed.connect(clear)
	add_child(_f)
	#else:
		#Global.announcement_sent.emit("You need a Discombobulator to clear these pests.")
