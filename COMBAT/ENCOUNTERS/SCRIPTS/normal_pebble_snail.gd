extends Encounter

func _ready():
	type = EncounterType.COMBAT_NORMAL
	reward_gold = 35
	reward_notch_count = 3
	reward_relics = 0
	super()
