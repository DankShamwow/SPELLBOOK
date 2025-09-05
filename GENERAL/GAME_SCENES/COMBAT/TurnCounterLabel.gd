extends RichTextLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func display_turn_text(turn: int, player_turn: bool):
	var tween = get_tree().create_tween()
	
	if player_turn:
		set_text("Player Turn " + str(turn))
	else:
		set_text("Enemy Turn " + str(turn))
	
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	tween.tween_property(self, "modulate:a", 1.0, 1)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
