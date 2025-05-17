extends Relic
class_name TheUpperCase

var relic_id = 0

func grid_index_effect(grid_index):
	if grid_index <= 7:
		juice_relic()
		return 3
	else:
		return 0

func get_relic_name():
	var relic_name = "The Upper Case"
	return relic_name
	
func get_relic_description():
	var relic_description = "The upper case from a printing press. It is vaguely magical, and makes you feel a touch lighter."
	return relic_description
	
func get_relic_sprite():
	$Relic_Button/Relic_Sprite.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)))
	$Relic_Button/Relic_Mask.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)+1))
