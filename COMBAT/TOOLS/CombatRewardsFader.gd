extends ColorRect

func _on_rewards_screen_appear(toggled_on: bool) -> void:
	if toggled_on:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0.55), 0.25)
	if not toggled_on:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.25)
