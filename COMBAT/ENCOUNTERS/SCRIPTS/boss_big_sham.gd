extends Encounter

func _ready():
	type = EncounterType.COMBAT_BOSS
	reward_gold = 150
	reward_notch_count = 10
	reward_relics = 0
	super()
