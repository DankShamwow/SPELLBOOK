extends Enemy
class_name Victim

func _ready():
	entity_name = "Victim"
	entity_description = "A poor soul who has lost their mind, literally."
	max_health = 500
	health = max_health
	block = 0
	max_energy = 2
	defense = 0
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
	
	# Dodge
	schedule_attack(1)
	

	var choice = enemy_rng.randi()
	if choice % 3 == 0 or choice % 3 == 2:
		schedule_attack(0)
	else:
		schedule_attack(2)

func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	# Spend the first energy to use Dodge
	if self.current_energy > 1:
		perform_enemy_attack(0)
	
	# Spend the second energy to use Swipe or Scream
	elif self.current_energy > 0:
		perform_enemy_attack(1)
	else:
		pass_turn.emit()
