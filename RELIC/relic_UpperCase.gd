extends Relic
class_name TheUpperCase

func _ready():
	relic_id = 1
	relic_name = "The Upper Case"
	relic_rarity = Relic.RelicRarity.COMMON
	relic_type = Relic.RelicType.RELIC
	relic_description = "Tiles from the top half of the rack grant an additional point."
	relic_flavor_text = "The upper case from a printing press. It is vaguely magical, and makes you feel a touch lighter."
	%Relic_Label.set_text("")
	super()
	
func grid_index_effect(grid_index, word):
	if grid_index <= 7:
		if word == "uppercase":
			juice_relic()
			total_activations += 1
			await get_tree().create_timer(0.025).timeout
			return 3
			
		else:
			juice_relic()
			total_activations += 1
			await get_tree().create_timer(0.025).timeout
			return 1
	else:
		return 0
