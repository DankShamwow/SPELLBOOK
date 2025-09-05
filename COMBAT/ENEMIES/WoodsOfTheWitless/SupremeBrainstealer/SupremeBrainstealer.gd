extends Enemy
class_name SupremeBrainstealer

func _ready():
	entity_name = "Supreme Brainstealer"
	entity_description = "An apex, floating, mind-devouring, reality-warping jellyfish."
	max_health = 2500
	health = max_health
	block = 0
	max_energy = 2
	defense = 0
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()



func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy > 0:
		perform_enemy_attack(0)
	else:
		pass_turn.emit()
