extends Encounter

func _ready():
	type = EncounterType.COMBAT_ELITE
	reward_gold = 70
	reward_notch_count = 5
	reward_relics = 0
	super()
