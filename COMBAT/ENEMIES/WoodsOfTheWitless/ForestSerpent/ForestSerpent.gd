extends Enemy
class_name ForestSerpent

func _ready():
	entity_name = "Forest Serpent"
	entity_description = "A very large, very territorial snake."
	max_health = 1000
	health = max_health
	block = 0
	max_energy = 1
	defense = 5
	active_turns = -3
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
	
	# Hissssssss
	if health == max_health and active_turns < 0:
		schedule_attack(0)
		active_turns += 1
	
	else:
		active_turns += 1
		if active_turns % 3 == 0:
			# Gouge
			schedule_attack(2)
		else:
			# Lunge
			schedule_attack(1)

func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy > 0:
		perform_enemy_attack(0)
	else:
		GameEventHandler.pass_turn.emit()
