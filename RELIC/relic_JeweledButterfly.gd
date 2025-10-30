extends Relic
class_name JeweledButterfly

var relic_dict: Dictionary[String, bool] = {}

func _ready():
	relic_id = 3
	relic_name = "Jeweled Butterfly"
	relic_rarity = Relic.RelicRarity.COMMON
	relic_type = Relic.RelicType.RELIC
	relic_description = 'Curated words relating to "gemstones" give you 5 gold per tile when scored.'
	relic_flavor_text = "[i]Danaus saphirae[/i]. The favorite snack of several geopodes, including salipedes, crystal spiders, and rock crabs."
	%Relic_Label.set_text("")
	super()

## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	var wordlist = FileAccess.open("res://WORDLISTS/Categories/Gemstones.txt", FileAccess.READ)
	while wordlist.get_position() < wordlist.get_length():
		#print("Working...")
		relic_dict[str(wordlist.get_line())] = true
	wordlist.close()
	return null
	
func word_played_effect(word, target = null):
	if relic_dict.get(word):
		juice_relic()
		total_activations += 1
		GameEventHandler.gold_changed.emit(5)
		await get_tree().create_timer(0.025).timeout
	return 0
