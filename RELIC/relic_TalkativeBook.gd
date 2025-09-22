extends Relic
class_name TalkativePictureBook

var relic_dict: Dictionary[String, bool] = {}
var golden_dict: Dictionary[String, bool] = {
	"kaboom": true,
	"eieio": true,
}

func _ready():
	relic_id = 18
	relic_name = "Talkative Picture Book"
	relic_rarity = RelicRarity.COMMON_BOOK
	relic_description = 'Onomatopoeia are granted +5 points per tile.'
	relic_flavor_text = "It's a book with some kind of strange device attached to it. Sometimes, the device speaks in a language you don't understand."
	%Relic_Label.set_text("")
	super()

## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	var wordlist = FileAccess.open("res://WORDLISTS/Categories/Onomatopoeia.txt", FileAccess.READ)
	while wordlist.get_position() < wordlist.get_length():
		print("Working...")
		relic_dict[str(wordlist.get_line())] = true
	wordlist.close()
	GeneralManager.add_bonus_words(golden_dict)
	return null
	
func word_tile_bonus_score_effect(word):
	if relic_dict.get(word):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 5
	else:
		return 0
