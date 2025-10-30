extends Relic
class_name FallbackRelic

func _ready():
	relic_id = 0
	relic_name = "Cart Chow"
	relic_rarity = Relic.RelicRarity.UNDEFINED
	relic_type = Relic.RelicType.UNDEFINED
	relic_description = "You shouldn't have this."
	relic_flavor_text = "It's got what carts crave!"
