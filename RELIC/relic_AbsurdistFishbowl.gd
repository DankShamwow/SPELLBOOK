extends Relic
class_name AbsurdistFishbowl

var relic_dict: Dictionary[String, bool] = {}

func _ready():
	relic_id = 5
	relic_name = "Absurdist Fishbowl"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'Curated words relating to "kinds of fish" grant +1 max health when played.'
	relic_flavor_text = "Seeing the fish swim inside makes you feel happy. You hope it doesn't get invaded by fishbowl-sized monsters."
	%Relic_Label.set_text("")
	super()

## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	var wordlist = FileAccess.open("res://WORDLISTS/Categories/Fish.txt", FileAccess.READ)
	while wordlist.get_position() < wordlist.get_length():
		print("Working...")
		relic_dict[str(wordlist.get_line())] = true
	wordlist.close()
	GeneralManager.add_bonus_words(relic_dict)
	relic_dict.clear()
	return null
	
func word_played_effect(word, target = null):
	if relic_dict.get(word):
		juice_relic()
		total_activations += 1
		GeneralManager.character_path.gain_max_health(1)
		await get_tree().create_timer(0.025).timeout
		return
	else:
		return
