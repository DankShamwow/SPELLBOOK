extends Relic
class_name BlankRelic

func _ready():
	relic_id = -1
	relic_name = ""
	relic_rarity = RelicRarity.UNDEFINED
	relic_description = ""
	relic_flavor_text = ""

## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	return null
	
## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a multiplier effect.
func word_score_multiplier_effect(_word, _target = null):
	return 0

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a bonus scoring effect for each letter in the word.
func word_letter_bonus_score_effect(_word):
	return 0

## Function that handles what should happen when a specific letter, kind of letter, etc.
func letter_score_effect(_letter, _word, _target, _tile_score):
	return 0
	
## Function that happens every "x" letters played.
func x_letters_played_effect(_letter_score, _word):
	return 0

## Function that handles what should happen if a tile has a certain grid index.
func grid_index_effect(_grid_index, _word):
	return 0

## Function that handles what should happen if a letter needs to be retriggered.
func letter_retrigger_effect(_letter, _word):
	return 0

## Function that handles what should happen if a word needs to be retriggered.
func word_retrigger_effect(_word):
	return 0
