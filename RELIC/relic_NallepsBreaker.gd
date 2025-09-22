extends Relic
class_name NallepsBreaker

func _ready():
	relic_id = 19
	relic_name = "Nallep's Breaker"
	relic_rarity = RelicRarity.COMMON
	relic_description = 'Emordnilaps inflict Stoned for one turn equal to the length of the word.'
	relic_flavor_text = "Nallep, twin of Pallen, was also a capable adventurer, but did not acquire as great of renown."
	%Relic_Label.set_text("")
	super()
	
func word_played_effect(word, target = null):
	print("Breaking...")
	if GeneralManager.word_list.has(word.reverse()) and target is Enemy:
		target.add_status("STONED", word.length(), true, 1)
		await get_tree().create_timer(0.025).timeout
		return
