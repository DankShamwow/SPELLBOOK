extends Relic
class_name ContractionalObligations

var relic_dict: Dictionary[String, bool] = {}

var golden_dict = {
	"yalldntve": true,
	"whomstdve": true
}

func _ready():
	relic_id = 10
	relic_name = "Contractional Obligations"
	relic_rarity = Relic.RelicRarity.COMMON
	relic_type = Relic.RelicType.RELIC
	relic_description = 'Contractions are added to the Dictionary. You may spell them without an apostrophe.'
	relic_flavor_text = "It lists out what you need to do and when you do it, all without using a full word for the entire document."
	%Relic_Label.set_text("")
	super()

func on_pickup_effect():
	var wordlist = FileAccess.open("res://WORDLISTS/Categories/Contractions.txt", FileAccess.READ)
	while wordlist.get_position() < wordlist.get_length():
		#print("Working...")
		relic_dict[str(wordlist.get_line())] = true
	wordlist.close()
	GeneralManager.add_bonus_words(relic_dict)
	relic_dict.clear()
	return null

func word_tile_bonus_score_effect(word: String):
	if golden_dict.get(word):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 5
	else:
		return 0
