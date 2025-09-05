extends Encounter

func _ready():
	type = EncounterType.COMBAT_BASIC
	reward_gold = 25
	reward_notch_count = 3
	reward_relics = 0
	
	super()
