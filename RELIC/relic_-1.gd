extends Relic
class_name FallbackRelic

var relic_id = -1

func get_relic_name():
	var relic_name = "Cart Chow"
	return relic_name
	
func get_relic_description():
	var relic_description = "It's got what carts crave! Also, you shouldn't have this."
	return relic_description

func get_relic_sprite():
	$Relic_Button/Relic_Sprite.set_frame_coords(Vector2i(0, 0))
	$Relic_Button/Relic_Mask.set_frame_coords(Vector2i(0, 1))
