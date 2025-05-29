extends Relic
class_name DisasterCore

var current_character = GeneralManager.current_character

func _ready():
	relic_id = 3
	relic_name = "Disaster Core"
	relic_rarity = RelicRarity.EVENT
	
	relic_description = "At the start of each turn, gain 3 Irradiation.\
						 Scored letters gain points equal to thrice your Irradiation. \
						 (Irradiation is Poison that does not decay each turn.)"
	
	relic_flavor_text = "One of the alchemical weapons used in the Great War, \
						 but it seems to have failed to detonate. \
						 Just holding it makes you feel sick."
	super()

func on_turn_start():
	get_parent().get_parent().find_child("Combatants").get_child(0).add_status("IRRADIATED_DEBUFF", 3, false, 100000)

## Function that handles what should happen when a specific letter, kind of letter, etc.
func letter_score_effect(_letter, _word):
	var irradiation = get_parent().get_parent().find_child("Combatants").get_child(0).query_status_value(8)
	if irradiation:
		juice_relic()
		return (3 * irradiation)
	else:
		return 0
