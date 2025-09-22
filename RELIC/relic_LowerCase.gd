extends Relic
class_name TheLowerCase

func _ready():
	relic_id = 2
	relic_name = "The Lower Case"
	relic_rarity = RelicRarity.COMMON
	relic_description ="Tiles from the bottom half of the rack give an additional 3 points."
	relic_flavor_text = "The lower case from a printing press. It is vaguely magical, and makes you feel a bit heavier."
	%Relic_Label.set_text("")
	super()

func grid_index_effect(grid_index, word):
	if grid_index >= 8:
		if word == "lowercase":
			juice_relic()
			total_activations += 1
			await get_tree().create_timer(0.025).timeout
			return 5
		else:
			juice_relic()
			total_activations += 1
			await get_tree().create_timer(0.025).timeout
			return 3
	else:
		return 0
