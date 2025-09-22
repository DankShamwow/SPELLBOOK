extends Relic
class_name Procrastination

func _ready():
	relic_id = 15
	relic_name = "Procrastination"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'Words containing "the" have their final score multiplied by 1.5, but only when attacking.'
	relic_flavor_text = "# TODO: Write description for Procrastination."
	%Relic_Label.set_text("")
	super()

func word_score_multiplier_effect(word: String, target = null):
	if word.contains("the") and target is Enemy:
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 1.5
	else:
		return 1
