extends HBoxContainer
class_name GoldTracker

# Baseline is zero gold, we'll add the player's starting gold at the start of a run.
var gold: int = 0

func _ready() -> void:
	GameEventHandler.gold_changed.connect(self.gold_changed)

# Use signals to change this stuff.
func gold_changed(gold_change: int) -> void:
	gold += gold_change
	update_gold_icon()
	
func update_gold_icon() -> void:
	%GoldLabel.text = str(gold)
	
	if gold < 50:
		%GoldIcon.texture.region = Rect2(0, 0, 32, 32)
		
	elif gold >= 50 and gold < 100:
		%GoldIcon.texture.region = Rect2(32, 0, 32, 32)
		
	elif gold >= 100 and gold < 250:
		%GoldIcon.texture.region = Rect2(64, 0, 32, 32)
		
	else:
		%GoldIcon.texture.region = Rect2(96, 0, 32, 32)
