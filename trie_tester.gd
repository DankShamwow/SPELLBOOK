extends Node2D

func _ready():
	print("starting load timer...")
	var load_time = Time.get_ticks_usec()
	GeneralManager.prepare_word_dict()
	var end_load_time = Time.get_ticks_usec() - load_time
	print("Loading finished in " + str(float(end_load_time)/1000000) + " seconds!")
	var word = "prepostpreposterouserous"
	var words = (["prearbalest", "postageer", "postager", "preteen"])
	var prefix_array: PackedStringArray = (["pre", "post", "un", "re"])
	var suffix_array: PackedStringArray = (["er", "ous", "est", "ing", "inator"])
	word_stripper(word, prefix_array, suffix_array)
	
	for i in words.size():
		word_stripper(words[i], prefix_array, suffix_array)

func word_stripper(word: String, prefix_array: PackedStringArray, suffix_array: PackedStringArray):
	
	print("starting timer...")
	var start_time = Time.get_ticks_usec()
	
	var mangle_1 = word
	var mangle_2 = word
	var mangle_3 = word
	var mangle_4 = word
	
	var result_1: String = ""
	var result_2: String = ""
	var result_3: String = ""
	var result_4: String = ""
	
	var result_words: Array[String] = []
	var result_lengths: Array[int] = []
	
	if GeneralManager.word_list.has(word):
		@warning_ignore_start("confusable_local_declaration")
		var list_words_time = Time.get_ticks_usec()
		var time_taken = list_words_time - start_time
		print("Preexisting Word: " + word)	
		print("Time Taken: " + str(float(time_taken)/1000000) + " seconds")
		return
	
	# Suffixes First, then Prefixes
	for i in 3:
		if not suffix_array.is_empty():
			for j in suffix_array.size():
				if not mangle_1 == mangle_1.trim_suffix(suffix_array[j]):
					mangle_1 = mangle_1.trim_suffix(suffix_array[j])
					if GeneralManager.word_list.has(mangle_1):
						result_1 = mangle_1
						if not result_words.has(result_1):
							result_words.append(result_1)
						break
	
	if result_1 == "":
		for i in 3:
			if not prefix_array.is_empty():
				for j in prefix_array.size():
					if not mangle_1 == mangle_1.trim_prefix(prefix_array[j]):
						mangle_1 = mangle_1.trim_prefix(prefix_array[j])
						if GeneralManager.word_list.has(mangle_1):
							result_1 = mangle_1
							if not result_words.has(result_1):
								result_words.append(result_1)
							break
	
	# Prefixes First, then Suffixes
	for i in 3:
		if not prefix_array.is_empty():
			for j in prefix_array.size():
				if not mangle_2 == mangle_2.trim_prefix(prefix_array[j]):
					mangle_2 = mangle_2.trim_prefix(prefix_array[j])
					if GeneralManager.word_list.has(mangle_2):
						result_2 = mangle_2
						if not result_words.has(result_2):
								result_words.append(result_2)
						break
	
	if result_2 == "":
		for i in 3:
			if not suffix_array.is_empty():
				for j in suffix_array.size():
					if not mangle_2 == mangle_2.trim_suffix(suffix_array[j]):
						mangle_2 = mangle_2.trim_suffix(suffix_array[j])
						if GeneralManager.word_list.has(mangle_1):
							result_2 = mangle_2
							if not result_words.has(result_2):
								result_words.append(result_2)
							break
	
	# Back-and-Forth staring with Suffix
	for i in 3:
		if not suffix_array.is_empty():
			for j in suffix_array.size():
				if not mangle_3 == mangle_3.trim_suffix(suffix_array[j]):
					mangle_3 = mangle_3.trim_suffix(suffix_array[j])
					break
			
		if not prefix_array.is_empty():
			for j in prefix_array.size():
				if not mangle_3 == mangle_3.trim_prefix(prefix_array[j]):
					mangle_3 = mangle_3.trim_prefix(prefix_array[j])
					break
			
		if GeneralManager.word_list.has(mangle_3):
			result_3 = mangle_3
			if not result_words.has(result_3):
				result_words.append(result_3)
			break

	# Back-and-Forth staring with Prefix
	for i in 3:
		
		if not prefix_array.is_empty():
			for j in prefix_array.size():
				if not mangle_4 == mangle_4.trim_prefix(prefix_array[j]):
					mangle_4 = mangle_4.trim_prefix(prefix_array[j])
					break
		
		if not suffix_array.is_empty():
			for j in suffix_array.size():
				if not mangle_4 == mangle_4.trim_suffix(suffix_array[j]):
					mangle_4 = mangle_4.trim_suffix(suffix_array[j])
					break
			
		if GeneralManager.word_list.has(mangle_4):
			result_4 = mangle_4
			if not result_words.has(result_4):
				result_words.append(result_4)
			break

	for i in result_words.size():
		result_lengths.append(result_words[i].length())
	
	var best_length = result_lengths.max()
	var best_word = result_words[result_lengths.find(best_length)]

	var list_words_time = Time.get_ticks_usec()
	
	var time_taken = list_words_time - start_time
	
	print("Input Word: " + word)
	print("Result Words: " + str(result_words))
	print("Best Length: " + str(best_length))
	print("Best Word: " + best_word)
	print("Time Taken: " + str(float(time_taken)/1000000) + " seconds")
	print("")
