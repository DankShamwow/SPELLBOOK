extends Relic
class_name PenNib

func _ready():
	relic_id = 12
	relic_name = "Pen Nib"
	relic_rarity = Relic.RelicRarity.COMMON
	relic_type = Relic.RelicType.RELIC
	relic_description = 'Every 10th tile scores for twice as much.'
	relic_flavor_text = '"You can see the bloody history of all those who have held it. And also some sort of weird card game, for unknown reasons."'
	super()
	%Relic_Label.set_text(str(GeneralManager.scored_tile_count % 10))

func x_letters_played_effect(letter_score: int, word: String):
	%Relic_Label.set_text(str(GeneralManager.scored_tile_count % 10))
	if GeneralManager.scored_tile_count % 10 == 0:
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return letter_score
	else:
		return 0
