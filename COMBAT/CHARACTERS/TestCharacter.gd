extends Character
class_name TestCharacter

func _ready():
	entity_name = "Test Character"
	entity_description = "Lorem Ipsum, la de da de da, hit the grotesque bababooey"
	max_health = 100
	health = 100
	block = 0
	max_energy = 3
	has_initiative = true
	super()
