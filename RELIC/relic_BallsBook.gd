extends Relic
class_name BallsBook

var relic_dict: Dictionary[String, bool] = {}

func _ready():
	relic_id = 4
	relic_name = "Balls and How\nto Use Them"
	relic_rarity = Relic.RelicRarity.COMMON_BOOK
	relic_type = Relic.RelicType.BOOK
	relic_description = 'Curated words relating to "kinds of balls" grant +3 points per tile.'
	relic_flavor_text = "You've been searching for this one for a while. At last, you can finally learn how to use all the balls you've accumulated over the course of your life."
	%Relic_Label.set_text("")
	super()

## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	var wordlist = FileAccess.open("res://WORDLISTS/Categories/Balls.txt", FileAccess.READ)
	while wordlist.get_position() < wordlist.get_length():
		#print("Working...")
		relic_dict[str(wordlist.get_line())] = true
	wordlist.close()
	return null
	
func word_tile_bonus_score_effect(word):
	if relic_dict.get(word):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 3
	else:
		return 0
