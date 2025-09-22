extends Relic
class_name DeliciousFruit

var relic_dict: Dictionary[String, bool] = {
	"thekid": true,
	"theguy": true,
	"theboshy": true,
	"deliciousfruit": true,
	"hatsunemiku": true,
}
var golden_dict = {
	"thekid": true,
	"theguy": true,
	"theboshy": true,
	"apple": true,
	"cherry": true,
	"deliciousfruit": true,
	"hatsunemiku": true,
}

func _ready():
	relic_id = 16
	relic_name = "Delicious Fruit"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'On pickup, gain +20 Max Health.'
	relic_flavor_text = "For time immemorial, the heated argument has remained: is it closer to an apple or to a cherry? Either way, it doesn't matter, because it's very tasty, unless you're a kid."
	%Relic_Label.set_text("")
	super()
	
## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	GeneralManager.character_path.gain_max_health(20)
	GeneralManager.add_bonus_words(relic_dict)
	return null
	
func word_played_effect(word, target = null):
	if golden_dict.get(word):
		juice_relic()
		total_activations += 1
		GeneralManager.character_path.gain_max_health(5)
		await get_tree().create_timer(0.025).timeout
		return
		
	else:
		return
