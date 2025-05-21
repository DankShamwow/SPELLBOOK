extends Relic
class_name BlankRelic

var relic_id = null

func get_relic_name():
	var relic_name = ""
	return relic_name
	
func get_relic_rarity():
	return RelicRarity.COMMON

func get_relic_description():
	var relic_description = ""
	return relic_description

func get_relic_flavor_text():
	return ""

func get_relic_sprite():
	$Relic_Button/Relic_Sprite.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)))
	$Relic_Button/Relic_Mask.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)+1))
