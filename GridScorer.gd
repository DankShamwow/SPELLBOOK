extends Node2D

var starting_deck_numbers = [4, 2, 2, 4, 5, 2, 2, 1, 4, 0, 0, 2, 2, 3, 4, 2, 0, 3, 2, 3, 2, 1, 1, 0, 1, 0]
var letters = (["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"])
var point_values = [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

var repetitions = 1000

var minimum_word_length: int = 15

var starting_deck = []
var available_letters = ([])

var racked_letters: String = ""
var found_words = []

var word_scores: Dictionary[String, int] = {}
var highest_scores: Array[int] = []
var lowest_scores: Array[int] = []
var average_word_scores: Array[float] = []

var average_rack_score: float = 0


func _ready() -> void:
	GeneralManager.prepare_word_dict()
	var trie = RustTrie.new()
	var valid_words = GeneralManager.word_list.keys()
	
	for i in valid_words.size():
		if valid_words[i].length() >= minimum_word_length:
			trie.add_word(valid_words[i])
	
	for i in starting_deck_numbers.size():
		for j in starting_deck_numbers[i]:
			starting_deck.append(letters[i])
	
	for j in repetitions:
		word_scores.clear()
		found_words.clear()
		racked_letters = ""
		available_letters = starting_deck.duplicate()
		var new_letters: PackedStringArray = ([])
		
		for i in 16:
			new_letters.append(available_letters.pop_at(randi() % available_letters.size()))
			
		racked_letters = "".join(new_letters)
		
		found_words = get_all_words(racked_letters, trie)
		
		for i in found_words:
			_score_word(i)
		
		_calc_average_rack_score()
		
	_calc_superaverage_score()
	
	print("Repetitions: " + str(repetitions))
	print("Minimum Word Length: " + str(minimum_word_length))
	print("Highest Word Scores: " + str(highest_scores))
	print("Lowest Word Scores: " + str(lowest_scores))
	print("Average Word Scores: " + str(average_word_scores))
	print("Average Rack Score: " + str(average_rack_score))

func _score_word(word: String):
	var score: int = 0
	
	if word.length() >= minimum_word_length:
		for i in word:
			score += point_values[letters.find(i)]
			
		@warning_ignore("integer_division")
		score = score * floor(word.length() / 2)
		word_scores[word] = score

func _calc_average_rack_score():
	var score_sum = 0
	var average_score: float 
	var highest_score: int = 0
	var lowest_score: int = 10000000000000000
	var word_keys = word_scores.keys()
	
	if word_keys.size() > 0:
		for i in word_keys.size():
			score_sum += word_scores.get(word_keys[i])
			if word_scores.get(word_keys[i]) > highest_score:
				highest_score = word_scores.get(word_keys[i])
			if word_scores.get(word_keys[i]) < lowest_score:
				lowest_score = word_scores.get(word_keys[i])
		
		average_score = float(score_sum / word_keys.size())
		average_word_scores.append(average_score)
		if not highest_scores.has(highest_score):
			highest_scores.append(highest_score)
		if not lowest_scores.has(lowest_score):
			lowest_scores.append(lowest_score)

func _calc_superaverage_score():
	var score_sum = 0
	
	if average_word_scores.size() > 0:
		for i in average_word_scores.size():
			score_sum += average_word_scores[i]
			
		average_rack_score = float(score_sum / average_word_scores.size())
	

func get_all_words(input_rack: String, trie: RustTrie) -> Array[String]:
	var sequences = []
	for i in input_rack:
		sequences.append(i)
	
	return get_all_words_helper(sequences, trie.get_root_node())
	
func get_all_words_helper(sequences: Array, node: RustTrieNode) -> Array[String]:
	var all_words: Array[String] = []
	if node.is_leaf():
		all_words.append(node.get_prefix())
		
	var already_checked = {}
	for i in sequences:
		if already_checked.has(i):
			continue
		else:
			already_checked[i] = true
			
		var next = node
		var sequence_found = true
		for j in i:
			next = next.get_child(j)
			if next == null:
				sequence_found = false
				break
			if sequence_found:
				var new_sequence = sequences.duplicate()
				new_sequence.erase(i)
				all_words.append_array(get_all_words_helper(new_sequence, next))
				
	return all_words
