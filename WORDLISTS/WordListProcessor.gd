extends Node2D

var text_file_path = "res://WORDLISTS/words_alpha.txt"
var exported_words = "res://WORDLISTS/STANDARD/"

var filter = ""

func _ready():
	var text_content = get_text_file_content(text_file_path, exported_words)
	
func get_text_file_content(filePath, filePath2):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var cachedfile = null;
	var cachedfilename = "";
	for c1 in "abcdefghijklmnopqrstuvwxyz":
		for c2 in "abcdefghijklmnopqrstuvwxyz":
			FileAccess.open(exported_words + c1 + c2 + ".txt", FileAccess.WRITE).close()
	while file.get_position() < file.get_length():
		filter = file.get_line()
		if filter.length() >= 3 && filter.length() <= 20:
			var filter_pass = str(filter[0] + filter[0] + filter[0])
			if not filter == filter_pass:
				var export
				if cachedfilename == filter[0] + filter[1] +  filter[2]:
					export = cachedfile
				else:
					if cachedfile != null:
						cachedfile.close();
					export = FileAccess.open(exported_words + filter[0] + filter[1] + ".txt", FileAccess.READ_WRITE)
					cachedfile = export;
				export.seek_end()
				export.store_line(filter)
	if cachedfile != null:
		cachedfile.close();
