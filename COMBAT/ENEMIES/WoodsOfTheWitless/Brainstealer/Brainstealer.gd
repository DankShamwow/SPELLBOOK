extends Enemy
class_name Brainstealer

func _ready():
	entity_name = "Brainstealer"
	entity_description = "An older, floating, mind-devouring jellyfish."
	max_health = 1000
	health = max_health
	block = 0
	max_energy = 1
	defense = 0
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
		
	if health < (max_health / 2):
		var choice = enemy_rng.randi_range(0, 2)
		
		if choice == 0:
			schedule_attack(0)
			
		if choice == 1:
			schedule_attack(1)
			
		if choice == 2:
			schedule_attack(2)
			
	else:
		var choice = enemy_rng.randi_range(0, 1)
		
		if choice == 0:
			schedule_attack(1)
			
		if choice == 1:
			schedule_attack(2)
	
func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy > 0:
		perform_enemy_attack(0)
	else:
		pass_turn.emit()
