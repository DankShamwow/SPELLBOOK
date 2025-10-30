extends Node2D

func _ready():
	GeneralManager.prepare_word_dict()
	var word = "prepostpreposterouserous"
	var prefix_array: PackedStringArray = (["pre", "post"])
	var suffix_array: PackedStringArray = (["er", "ous"])
	word_stripper(word, prefix_array, suffix_array)

func word_stripper(word: String, prefix_array: PackedStringArray, suffix_array: PackedStringArray):
	
	var mangle_1 = word
	var mangle_2 = word
	var mangle_3 = word
	var mangle_4 = word
	
	var result_1: String = ""
	var result_2: String = ""
	var result_3: String = ""
	var result_4: String = ""
	
	# Suffixes First, then Prefixes
	for i in 3:
		print("Mangle 1: " + mangle_1)
		if not suffix_array.is_empty():
			for j in suffix_array.size():
				if not mangle_1 == mangle_1.trim_suffix(suffix_array[j]):
					mangle_1 = mangle_1.trim_suffix(suffix_array[j])
					if GeneralManager.word_list.has(mangle_1):
						result_1 = mangle_1
						break
		
	if result_1 == "":
		for i in 3:
			print("Mangle 1: " + mangle_1)
			if not prefix_array.is_empty():
				for j in prefix_array.size():
					if not mangle_1 == mangle_1.trim_prefix(prefix_array[j]):
						mangle_1 = mangle_1.trim_prefix(prefix_array[j])
						if GeneralManager.word_list.has(mangle_1):
							result_1 = mangle_1
							break
	
	# Prefixes First, then Suffixes
	for i in 3:
		print("Mangle 2: " + mangle_2)
		if not prefix_array.is_empty():
			for j in prefix_array.size():
				if not mangle_2 == mangle_2.trim_prefix(prefix_array[j]):
					mangle_2 = mangle_2.trim_prefix(prefix_array[j])
					if GeneralManager.word_list.has(mangle_2):
						result_2 = mangle_2
						break
	
	if result_2 == "":
		for i in 3:
			print("Mangle 2: " + mangle_2)
			if not suffix_array.is_empty():
				for j in suffix_array.size():
					if not mangle_2 == mangle_2.trim_suffix(suffix_array[j]):
						mangle_2 = mangle_2.trim_suffix(suffix_array[j])
						if GeneralManager.word_list.has(mangle_1):
							result_2 = mangle_2
							break
	
	# Back-and-Forth staring with Suffix
	for i in 3:
		print("Mangle 3: " + mangle_3)
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
			break

	# Back-and-Forth staring with Prefix
	for i in 3:
		print("Mangle 4: " + mangle_4)
		
		if not prefix_array.is_empty():
			for j in prefix_array.size():
				if not mangle_3 == mangle_3.trim_prefix(prefix_array[j]):
					mangle_3 = mangle_3.trim_prefix(prefix_array[j])
					break
		
		if not suffix_array.is_empty():
			for j in suffix_array.size():
				if not mangle_3 == mangle_3.trim_suffix(suffix_array[j]):
					mangle_3 = mangle_3.trim_suffix(suffix_array[j])
					break
			
		if GeneralManager.word_list.has(mangle_4):
			result_4 = mangle_4
			break

	print(result_1)
	print(result_2)
	print(result_3)
	print(result_4)
