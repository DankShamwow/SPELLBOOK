extends Relic
class_name Ampersandvich

var golden_dict = {
	"sandvich": true,
	"dalokohs": true,
	"dalokohsbar": true,
	"buffalosteak": true,
	"buffalosteaksandvich": true,
	"secondbanana": true,
	"thesecondbanana": true,
	"ampersandvich": true
}

func _ready():
	relic_id = 7
	relic_name = "Ampersandvich"
	relic_rarity = RelicRarity.COMMON
	relic_description = str("Playing a word that contains " + '"and"' + " heals you for 10 and increases the played word's effective length by 2.")
	relic_flavor_text = '"Ampersandvich makes me strooong!"'
	%Relic_Label.set_text("")
	super()

func on_pickup_effect():
	GeneralManager.add_bonus_words(golden_dict)

func word_length_bonus_effect(word: String):
	if golden_dict.get(word):
		juice_relic()
		total_activations += 1
		GeneralManager.character_path.gain_health(20)
		await get_tree().create_timer(0.025).timeout
		return 2
		
	elif word.contains("and"):
		juice_relic()
		total_activations += 1
		GeneralManager.character_path.gain_health(10)
		await get_tree().create_timer(0.025).timeout
		return 1
	else:
		return 0
