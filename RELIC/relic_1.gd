extends Relic
class_name TheLowerCase

var relic_id = 1
var total_activations = 0

func grid_index_effect(grid_index):
	if grid_index >= 8:
		juice_relic()
		total_activations += 1
		return 3
	else:
		return 0

func get_relic_name():
	return "The Lower Case"
	
func get_relic_rarity():
	return RelicRarity.COMMON
	
func get_relic_description():
	return "Tiles from the bottom half of the rack give an additional 3 points."
	
func get_relic_flavor_text():
	return "The lower case from a printing press. It is vaguely magical, and makes you feel a bit heavier."
	
func get_relic_sprite():
	$Relic_Button/Relic_Sprite.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)))
	$Relic_Button/Relic_Mask.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)+1))
