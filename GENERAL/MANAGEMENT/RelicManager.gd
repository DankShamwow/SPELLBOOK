extends Node

var relic_rng = RandomnessManager.relic_rng
var relic_scene = preload("res://RELIC/Relic.tscn")

var common_relic_pool: 				Dictionary[String, StringName] = {}
var common_book_pool: 				Dictionary[String, StringName] = {}
var common_relics_available: 		Array[String]
var common_books_available:	 		Array[String]
var uncommon_relic_pool: 			Dictionary[String, StringName] = {}
var uncommon_book_pool: 			Dictionary[String, StringName] = {}
var uncommon_relics_available: 		Array[String]
var uncommon_books_available:	 	Array[String]
var rare_relic_pool: 				Dictionary[String, StringName] = {}
var rare_book_pool: 				Dictionary[String, StringName] = {}
var rare_relics_available: 			Array[String]
var rare_books_available:	 		Array[String]
var boss_relic_pool: 				Dictionary[String, StringName] = {}
var boss_book_pool: 				Dictionary[String, StringName] = {}
var boss_relics_available: 			Array[String]
var boss_books_available:	 		Array[String]
var event_relics: 					Dictionary[String, StringName] = {}
var event_books: 					Dictionary[String, StringName] = {}

var relic_ids:						Dictionary[String, int] = {}
var relic_list:						Dictionary[String, StringName] = {}

var cached_relics:					Dictionary[String, StringName] = {}
var grabbed_relics:					Dictionary[String, StringName] = {}
var loaded_relics:					Dictionary[int, GDScript] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _load_relics():
	# Clear all pools, we'll refill them shortly.
	common_relics_available.clear()
	common_books_available.clear()
	uncommon_relics_available.clear()
	uncommon_books_available.clear()
	rare_relics_available.clear()
	rare_books_available.clear()
	boss_relics_available.clear()
	boss_books_available.clear()
	
	# Clear the pool of relics that has been seen.
	grabbed_relics.clear()

	var full_path: String = "res://RELIC/"
	
	var relic_file_list = ResourceLoader.list_directory(full_path)
	
	for i in relic_file_list.size():
		var saved_path = full_path + relic_file_list[i]
		
		if relic_file_list[i].contains("relic_"):
			var current_line = ""
			var file = FileAccess.open(saved_path, FileAccess.READ)
			var content = file.get_as_text()
			var relic_name = relic_file_list[i]
			
			while not current_line.contains("relic_id = "):
				current_line = file.get_line()
				
			var relic_id = int(current_line.erase(0, 11))
			print(str("Relic ID: " + str(relic_id)))
			print(relic_name)
			
			# Check to see if we've already got this one cached.
			if cached_relics.has(relic_name):
				continue
			# If not, add it to the cache so it can be called upon later.
			else:
				cached_relics[relic_name] = saved_path
			
			if content.contains('relic_name = "Cart Chow"') or content.contains('relic_name = "Disaster Core'):
				continue
			
			# Procrastination ends up in all pools.
			#if content.contains('relic_name = "Procrastination"'):
				#common_relic_pool[relic_name] = saved_path
				#common_book_pool[relic_name] = saved_path
				#uncommon_relic_pool[relic_name] = saved_path
				#uncommon_book_pool[relic_name] = saved_path
				#rare_relic_pool[relic_name] = saved_path
				#rare_book_pool[relic_name] = saved_path
				#boss_relic_pool[relic_name] = saved_path
				#boss_book_pool[relic_name] = saved_path
				#
				#common_relics_available.append(relic_name)
				#common_books_available.append(relic_name)
				#uncommon_relics_available.append(relic_name)
				#uncommon_books_available.append(relic_name)
				#rare_relics_available.append(relic_name)
				#rare_books_available.append(relic_name)
				#boss_relics_available.append(relic_name)
				#boss_books_available.append(relic_name)
				#
				#relic_ids[relic_name] = relic_id
				#
				#continue
			
			# Commons
			if content.contains("RelicRarity.COMMON"):
				common_relic_pool[relic_name] = saved_path
				common_relics_available.append(relic_name)
				relic_ids[relic_name] = relic_id
				
			# Common Books
			if content.contains("RelicRarity.COMMON_BOOK"):
				common_book_pool[relic_name] = saved_path
				common_books_available.append(relic_name)

			# Uncommons
			if content.contains("RelicRarity.UNCOMMON"):
				uncommon_relic_pool[relic_name] = saved_path
				uncommon_relics_available.append(relic_name)
				relic_ids[relic_name] = relic_id
				
			# Uncommon Books
			if content.contains("RelicRarity.UNCOMMON_BOOK"):
				uncommon_book_pool[relic_name] = saved_path
				uncommon_books_available.append(relic_name)

			# Rares
			if content.contains("RelicRarity.RARE"):
				rare_relic_pool[relic_name] = saved_path
				rare_relics_available.append(relic_name)
				relic_ids[relic_name] = relic_id
				
			# Rare Books
			if content.contains("RelicRarity.RARE_BOOK"):
				rare_book_pool[relic_name] = saved_path
				rare_books_available.append(relic_name)
				
			# Boss Relics
			if content.contains("RelicRarity.BOSS"):
				boss_relic_pool[relic_name] = saved_path
				boss_relics_available.append(relic_name)
				relic_ids[relic_name] = relic_id
				
			# Boss Books
			if content.contains("RelicRarity.BOSS_BOOK"):
				boss_book_pool[relic_name] = saved_path
				boss_books_available.append(relic_name)

			relic_list[relic_name] = saved_path

	
	print(common_relic_pool)
	print(common_book_pool)
	print(common_relics_available)

func grab_new_relic(type: String):
	if type == "Relic":
		var relic_tables = [common_relics_available, common_relics_available, common_relics_available] # This will go unused for now.
		var table_weights = PackedFloat32Array([65, 25, 10]) # This will go unused for now.
		
		var relic_table_roll = common_relics_available
		#var relic_table_roll = relic_tables[relic_rng.rand_weighted(table_weights)] # Unused for now.
		
		# Grab the relic's name and ID
		var grabbed_relic = relic_table_roll.pop_at(relic_rng.randi() % relic_table_roll.size())
		var grabbed_id = relic_ids.get(grabbed_relic)
		var grabbed_path = relic_list.get(grabbed_relic)
		
		# Put it in the list of rleics that has been seen.
		grabbed_relics[grabbed_relic] = grabbed_path
		
		# Load the chosen relic as a resource and pass it to the function that called this.
		var loaded_relic = load(grabbed_path)
		
		# Cache it, as we've already loaded it.
		loaded_relics[grabbed_id] = loaded_relic
		
		var new_relic = relic_scene.instantiate()
		new_relic.set_script(loaded_relic)
		new_relic._ready()
		
		print(grabbed_path)
		print(loaded_relic)
		print(new_relic)
		
		return new_relic
	
