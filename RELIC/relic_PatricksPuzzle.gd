extends Relic
class_name PatricksPuzzle

var relic_dict: Dictionary[String, bool] = {
	"parabox": true,
}

func _ready():
	relic_id = 17
	relic_name = "Patrick's Pink\nPuzzle Box"
	relic_rarity = Relic.RelicRarity.COMMON
	relic_type = Relic.RelicType.RELIC
	relic_description = "If the played word contains another word, the played word's effective length is increased by 1."
	relic_flavor_text = "When you look inside the puzzle box, you see a smaller version of yourself looking into a smaller version of the puzzle box."
	%Relic_Label.set_text("")
	super()
	
## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	GeneralManager.add_bonus_words(relic_dict)
	return null
	
func word_length_bonus_effect(word):
	if relic_dict.get(word):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 2
	
	elif teardown_word(word):
		juice_relic()
		total_activations += 1
		await get_tree().create_timer(0.025).timeout
		return 1
	
	#else:
		#var trie = RustTrie.new()
		#var sequence = word.split("", false)
		#trie_word(sequence, trie.get_root_node(), word)
	
	else:
		return 0

func teardown_word(word: String):
	var test_word = word.split("", false)
	var iterations = 0
	
	for j in test_word.size():
		test_word = word.split("", false)

		for i in j:
			test_word.remove_at(0)
		
		for i in test_word.size():
			var joined_word = ""
			joined_word = joined_word.join(test_word)
			#print(joined_word)
			if (not joined_word == word and word.contains(joined_word) and GeneralManager.word_list.has(joined_word)):
				print("Found Word: " + joined_word)
				return true
			else:
				iterations += 1
				test_word.remove_at(test_word.size() - 1)
				#print("Word: " + joined_word)
				#print("Iterations: " + str(iterations))
	
	return false

#func trie_word(sequences: Array, node: RustTrieNode, word: String):
	#var found_words: Array[String] = []
	#
	#if node.is_leaf():
		#var checked_word = node.get_prefix()
		#found_words.append(checked_word)
		#if not checked_word == word and word.contains(checked_word) and GeneralManager.word_list.has(checked_word):
			#return true
			#
		#
	#pass
