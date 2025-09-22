extends Relic
class_name OmegasScriptures

func _ready():
	relic_id = 14
	relic_name = "Omega's Scriptures"
	relic_rarity = RelicRarity.COMMON_BOOK
	relic_description = 'Tiles with the letter X, Y, or Z have their tile score double, but only when attacking.'
	relic_flavor_text = "Documents pertaining to the worship of a long-forgotten deity."
	super()
	%Relic_Label.set_text("")

func letter_score_effect(letter, word, target, tile_score):
	if (letter == 23 or letter == 24 or letter == 25) and target is Enemy:
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return (2 * tile_score)
	else:
		return 0
