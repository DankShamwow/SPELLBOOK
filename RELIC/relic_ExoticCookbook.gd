extends Relic
class_name ExoticCookbook

var relic_dict: Dictionary[String, bool] = {}
var golden_dict = {
	"mengerspongecake": true,
	"albatrossboiling": true,
	"albatrossboil": true,
	"bogeyboil": true,
	"bogeyboiling": true,
	"reverseunsear": true,
	"reverseunsearing": true,
}

func _ready():
	relic_id = 6
	relic_name = "Exotic Cookbook"
	relic_rarity = RelicRarity.COMMON_BOOK
	relic_description = 'Curated words related to "cooking" heal you for 5 HP when played.'
	relic_flavor_text = "Contains information on advanced cooking techniques such as albatrossboiling, reverse-un-searing, and bogeyboiling, and also has a recipe for Menger Spongecake. This isn't useful to you in your situation."
	%Relic_Label.set_text("")
	super()
	
## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	var wordlist = FileAccess.open("res://WORDLISTS/Categories/Cooking.txt", FileAccess.READ)
	while wordlist.get_position() < wordlist.get_length():
		print("Working...")
		relic_dict[str(wordlist.get_line())] = true
	wordlist.close()
	return null
	
func word_played_effect(word, target = null):
	if golden_dict.get(word):
		juice_relic()
		total_activations += 1
		GeneralManager.character_path.gain_health(10)
		await get_tree().create_timer(0.025).timeout
		return
		
	elif relic_dict.get(word):
		juice_relic()
		total_activations += 1
		GeneralManager.character_path.gain_health(5)
		await get_tree().create_timer(0.025).timeout
		return
		
	else:
		return
