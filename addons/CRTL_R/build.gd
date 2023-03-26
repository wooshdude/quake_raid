func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_pressed() and event.scancode == KEY_R and event.control:
		var qodot = get_tree().get_edited_scene_root().find_node("QodotMap")
		if not qodot:
			print("no qodot")
			return
		if qodot.has_method("build_map"):
			qodot.build_map()
		else:
			print("could not find build_map method")
