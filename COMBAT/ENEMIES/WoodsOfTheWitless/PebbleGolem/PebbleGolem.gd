extends Enemy
class_name PebbleGolem

func _ready():
	entity_name = "Pebble Golem"
	entity_description = "A larval Rock Golem."
	max_health = 200
	health = max_health
	block = 0
	max_energy = 1
	defense = 5
	super()

func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
		
	schedule_attack(0)

func on_turn_start(_count):
	super(_count)
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy > 0:
		perform_enemy_attack(0)
	else:
		GameEventHandler.pass_turn.emit()
