extends ColorRect

func _on_map_toggle(toggled_on: bool) -> void:
	if toggled_on:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0.65), 0.25)
	if not toggled_on:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.25)
