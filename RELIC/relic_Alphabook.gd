extends Relic
class_name Alphabook

func _ready():
	relic_id = 13
	relic_name = "Alphabook"
	relic_rarity = Relic.RelicRarity.COMMON_BOOK
	relic_type = Relic.RelicType.BOOK
	relic_description = 'Tiles with the letter A, B, or C have their tile score tripled, but only when attacking.'
	relic_flavor_text = "The first book ever written."
	super()
	%Relic_Label.set_text("")

func letter_score_effect(letter, word, target, tile_score):
	if (letter == 0 or letter == 1 or letter == 2) and target is Enemy:
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return (2 * tile_score)
	else:
		return 0
