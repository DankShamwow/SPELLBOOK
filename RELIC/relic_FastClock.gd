extends Relic
class_name FastClock

var tiles_in_play = GeneralManager.tiles_in_play

func _ready():
	relic_id = 20
	relic_name = "Fast Clock"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'On pickup, draft 3 Patient Notches. Patient Notches scale twice as quickly.'
	relic_flavor_text = "While holding this clock, everything seems to speed up around you."
	%Relic_Label.set_text("")
	super()
	
func on_pickup_effect():
	GameEventHandler.specialty_rewards_popup.emit(0, 0, 0, [11, 11, 11], false, 7)

func on_turn_start(turn: int = 0):
	if turn == 1:
		return
	else:
		for i in tiles_in_play.size():
				tiles_in_play[i].current_age += 1
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return
