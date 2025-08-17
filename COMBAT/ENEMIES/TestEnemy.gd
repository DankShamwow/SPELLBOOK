extends Enemy
class_name TestEnemy

func _ready():
	max_health = 100
	health = 100
	block = 0
	max_energy = 3
	defense = 10
	super()

func on_turn_start():
	super()
	_perform_next_attack()

func _perform_next_attack():
	if self.current_energy == 3:
		perform_enemy_attack(0, Character)
	elif self.current_energy == 2:
		perform_enemy_attack(1, self)
	elif self.current_energy == 1:
		perform_enemy_attack(2, Character)
	else:
		pass_turn.emit()
