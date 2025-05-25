extends Character
class_name TestCharacter

## who_has_initiative is the GameEntity that currently has the initiative.
var who_has_initiative = GeneralManager.who_has_initiative

func _ready():
	max_health = 100
	health = 100
	block = 0
	max_energy = 3
	has_initiative = true
	super()
