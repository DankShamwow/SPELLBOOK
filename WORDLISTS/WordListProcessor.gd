extends Node2D

var text_file_path = "res://WORDLISTS/words_alpha.txt"
var exported_words = "res://WORDLISTS/Starting Letter/"

func _ready():
	var text_content = get_text_file_content(text_file_path, exported_words)
	
func get_text_file_content(filePath, filePath2):
	var file = FileAccess.open(filePath, FileAccess.READ)
	for c1 in "abcdefghijklmnopqrstuvwxyz":
		for c2 in "abcdefghijklmnopqrstuvwxyz":
			FileAccess.open(exported_words + c1 + c2 + ".txt", FileAccess.WRITE).close()
	while file.get_position() < file.get_length():
		var filter = file.get_line()
		if filter.length() >= 3 && filter.length() <= 20:
			var export = FileAccess.open(exported_words + filter[0] + filter[1] + ".txt", FileAccess.READ_WRITE)
			export.seek_end()
			export.store_line(filter)
			export.close()
