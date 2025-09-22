extends Relic
class_name QuaSeal

func _ready():
	relic_id = 9
	relic_name = "Seal of Qua-ity"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'Playing a word that contains "qua" multiplies the final score by 1.5.'
	relic_flavor_text = str('"No, it is [b]NOT[/b] misspelled. This seal ensures that whatever it is stamped on contains ' + "'qua'" + ' in a quantity of at least one."')
	%Relic_Label.set_text("")
	super()

func word_score_multiplier_effect(word: String, target = null):
	if word.contains("qua"):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 1.5
	else:
		return 1
