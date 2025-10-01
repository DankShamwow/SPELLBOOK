extends Enemy
class_name DireSnail

func _ready():
	entity_name = "Dire Snail"
	entity_description = "A very large, very slow snail."
	max_health = 450
	health = max_health
	block = 0
	max_energy = 1
	defense = 0
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
	
	if active_turns % 3 == 0:
		schedule_attack(0)
	elif active_turns % 3 == 1:
		schedule_attack(1)
	else:
		schedule_attack(2)
	
	active_turns += 1
	
func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy > 0:
		perform_enemy_attack(0)
	else:
		GameEventHandler.pass_turn.emit()
