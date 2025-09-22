extends Relic
class_name DisasterCore

var current_character = GeneralManager.current_character

func _ready():
	relic_id = 0
	relic_name = "Disaster Core"
	relic_rarity = RelicRarity.EVENT
	
	relic_description = "At the start of each turn, gain 3 Irradiation.\
						 Scored letters gain points equal to thrice your Irradiation. \
						 (Irradiation is Poison that does not decay each turn.)"
	
	relic_flavor_text = "One of the alchemical weapons used in the Great War, \
						 but it seems to have failed to detonate. \
						 Just holding it makes you feel sick."
	%Relic_Label.set_text("")
	super()



func on_turn_start():
	GeneralManager.character_path.add_status("IRRADIATED_DEBUFF", 3, false, 1)

## Function that handles what should happen when a specific letter, kind of letter, etc.
func letter_score_effect(_letter, _word, _target, _tile_score):
	var irradiation = GeneralManager.character_path.query_status_value(8)
	if irradiation:
		juice_relic()
		return (3 * irradiation)
	else:
		return 0
