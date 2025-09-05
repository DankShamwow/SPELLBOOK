extends Enemy
class_name Lunatic

func _ready():
	entity_name = "Lunatic"
	entity_description = "A poor soul who has lost their mind, figuratively."
	max_health = 600
	health = max_health
	block = 0
	max_energy = 1
	defense = 0
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
		
	if active_turns >= 7 and active_turns % 2 == 1:
		schedule_attack(2)
	
	else:
		var choice = enemy_rng.randi()
		if choice % 3 == 0 or choice % 3 == 2:
			schedule_attack(0)
		else:
			schedule_attack(1)


func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy > 0:
		perform_enemy_attack(0)
	else:
		pass_turn.emit()
