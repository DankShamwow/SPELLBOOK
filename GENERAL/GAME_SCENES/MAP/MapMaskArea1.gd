extends ColorRect

func _on_map_bringup() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0, 0, 0, 0.65), 0.25)
		
func _on_map_shutdown() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.25)
