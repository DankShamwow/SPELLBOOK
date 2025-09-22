extends Relic
class_name SentenceMixer

var golden_dict = {
	"swaws": true,
	"smoms": true,
	"steaets": true,
	"tacocat": true,
}

func _ready():
	relic_id = 8
	relic_name = "Sentence Mixer"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'Most strings that are palidromes count as words.'
	relic_flavor_text = "That's not [i]smoms[/i], it's [i]steaets[/i]. [i]Steaets[/i] from the [i]steaets hah[/i] we're having."
	%Relic_Label.set_text("")
	super()

func mixer_check(word: String, prefix_1: String = "", prefix_2: String = "", prefix_3: String = "", suffix_1: String = "", suffix_2: String = "", suffix_3: String = ""):
	if word == word.reverse():
		for i in word.length():
			## No using 3 of the same letter in a row.
			if i >= 2:
				if word[i] == word[i-1] and word[i-1] == word[i-2]:
					return false
			
			##NOTE: Leaving space to implement more rules for this relic's function. It feels ripe for bullshit.
				
		return true
	else:
		return false

func word_tile_bonus_score_effect(word):
	if golden_dict.get(word):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 10
	else:
		return 0
