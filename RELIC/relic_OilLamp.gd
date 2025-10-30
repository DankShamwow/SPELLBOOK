extends Relic
class_name OilLamp

func _ready():
	relic_id = 11
	relic_name = "Oil Lamp"
	relic_rarity = Relic.RelicRarity.COMMON
	relic_type = Relic.RelicType.RELIC
	relic_description = 'When you inflict Burn, increase the Amount and Duration by one.'
	relic_flavor_text = "A seemingly-simple oil lamp, but as hard as you try, you can't seem to extinguish it."
	%Relic_Label.set_text("")
	super()

func debuff_boost(debuff: String):
	if debuff == "BURN_DEBUFF":
		juice_relic()
		total_activations += 1
		return 1
	else:
		return 0
