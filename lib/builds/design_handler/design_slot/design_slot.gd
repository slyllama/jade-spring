extends Panel
# DesignSlot

signal activated
signal slot_renamed(new_name: String)
signal slot_deleted

const BASE_TEX_ACTIVATED = preload("res://lib/builds/design_handler/design_slot/textures/design_slot_bg_activated.png")

var editing_name = false

@export var design_name: String:
	get: return(design_name)
	set(_val):
		design_name = _val
		update()

func update() -> void:
	if !design_name:
		print("[DesignSlot] no design name assigned.")
		return
	$HBox/Name.text = design_name.replace("_", " ")
	
	if SettingsHandler.settings.current_design == design_name:
		$HBox/Delete.disabled = true
		$HBox/Rename.disabled = true
		$HBox/Activate.disabled = true
		var _s: StyleBoxTexture = get_theme_stylebox("panel")
		_s.texture = BASE_TEX_ACTIVATED
	
	var _deco_count = 0
	var _df = FileAccess.open(DesignHandler.DPATH + "/" + design_name + ".dat", FileAccess.READ)
	if _df:
		var _df_data = _df.get_var()
		for _dd in _df_data: _deco_count += 1
		_df.close()
		$HBox/DecoCount.text = "(" + str(_deco_count) + ")"
	else:
		print("[DesignSlot] Couldn't get decoration count for '" + design_name + "'.")

func _on_activate_button_down() -> void:
	if SteamHandler.get_achievment_completion("astral_architect") == 0:
		SteamHandler.complete_achievement("astral_architect")
	
	Global.click_sound.emit()
	activated.emit()
	update()

func _on_rename_button_down() -> void:
	if !editing_name:
		editing_name = true
		$HBox/Rename.text = "Apply"
		$HBox/Activate.disabled = true
		$HBox/Name.editable = true
		$HBox/Name.grab_focus()
		$HBox/Name.select_all()
	else:
		var _new_name = $HBox/Name.text.replace(" ", "_")
		if _new_name != design_name:
			slot_renamed.emit(Global.design_handler.return_valid_name(_new_name))
		else:
			editing_name = false
			$HBox/Rename.text = "Rename"
			$HBox/Activate.disabled = false
			$HBox/Name.editable = false

func _on_delete_button_down() -> void:
	if $HBox/Delete.text == "Delete":
		$Warning.play()
		modulate = Color("ff7878")
		$HBox/Delete.text = "Confirm"
		return
	Global.design_handler.delete_slot(design_name)
	slot_deleted.emit()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		if $HBox/Delete.text == "Confirm":
			await get_tree().process_frame
			modulate = Color.WHITE
			$HBox/Delete.text = "Delete"

func _on_name_mouse_entered() -> void:
	Global.mouse_in_ui = true
