extends Relic
class_name TheLowerCase

var relic_id = 1

func grid_index_effect(grid_index):
	if grid_index >= 8:
		juice_relic()
		return 5

func get_relic_name():
	var relic_name = "The Lower Case"
	return relic_name
	
func get_relic_description():
	var relic_description = "The lower case from a printing press. It is vaguely magical, and makes you feel a bit heavier."
	return relic_description
	
func get_relic_sprite():
	$Relic_Button/Relic_Sprite.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)))
	$Relic_Button/Relic_Mask.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10) * 2))
