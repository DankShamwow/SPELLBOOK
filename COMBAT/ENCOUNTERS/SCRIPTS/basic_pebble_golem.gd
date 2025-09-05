extends Encounter

func _ready():
	type = EncounterType.COMBAT_BASIC
	reward_gold = 15
	reward_notch_count = 2
	reward_relics = 0
	super()
