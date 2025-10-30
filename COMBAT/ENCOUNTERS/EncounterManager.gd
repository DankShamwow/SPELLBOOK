extends Node

var encounter_rng = RandomnessManager.encounter_rng

var basic_encounter_pool: Dictionary[String, StringName] = {}
var basic_count := 0
var basic_encounters_available: Array[String] = []

var normal_encounter_pool: Dictionary[String, StringName] = {}
var normal_count := 0
var normal_encounters_available: Array[String] = []

var elite_encounter_pool: Dictionary[String, StringName] = {}
var elite_count := 0
var elite_encounters_available: Array[String] = []

var boss_encounter_pool: Dictionary[String, StringName] = {}
var boss_count := 0
var boss_encounters_available: Array[String] = []

var cached_encounters: Dictionary[StringName, PackedScene] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _load_area_encounters(area: String):
	
	basic_encounter_pool.clear()
	normal_encounter_pool.clear()
	elite_encounter_pool.clear()
	boss_encounter_pool.clear()
	
	basic_count = 0
	normal_count = 0
	elite_count = 0
	boss_count = 0
	
	basic_encounters_available.clear()
	normal_encounters_available.clear()
	elite_encounters_available.clear()
	boss_encounters_available.clear()
	
	var full_path: String = "res://COMBAT/ENCOUNTERS/" + area + "/"
	var area_encounter_list = ResourceLoader.list_directory(full_path)
	
	for i in area_encounter_list.size():
		
		var saved_path = full_path + area_encounter_list[i]
		
		if area_encounter_list[i].contains("basic"):
			var encounter_name = area + "_basic_" + str(basic_count)
			basic_encounter_pool[encounter_name] = saved_path
			basic_encounters_available.append(encounter_name)
			basic_count += 1
			
		if area_encounter_list[i].contains("normal"):
			var encounter_name = area + "_normal_" + str(normal_count)
			normal_encounter_pool[encounter_name] = saved_path
			normal_encounters_available.append(encounter_name)
			normal_count += 1
			
		if area_encounter_list[i].contains("elite"):
			var encounter_name = area + "_elite_" + str(elite_count)
			elite_encounter_pool[encounter_name] = saved_path
			elite_encounters_available.append(encounter_name)
			elite_count += 1
			
		if area_encounter_list[i].contains("boss"):
			var encounter_name = area + "_boss_" + str(boss_count)
			boss_encounter_pool[encounter_name] = saved_path
			boss_encounters_available.append(encounter_name)
			print(saved_path)
			boss_count += 1
		
		
func grab_new_encounter(tier: String):
	var grabbed_encounter: String
	
	if tier == "BASIC":
		if basic_encounters_available.size() > 0:
			
			grabbed_encounter = basic_encounters_available.pop_at(encounter_rng.randi() % basic_encounters_available.size())
			
			if cached_encounters.has(grabbed_encounter):
				return cached_encounters.get(grabbed_encounter)
			
			else:
				print("Loading encounter...")
				var loaded_encounter = ResourceLoader.load(basic_encounter_pool.get(grabbed_encounter))
				cached_encounters[grabbed_encounter] = loaded_encounter
				return loaded_encounter
			
		else:
			basic_encounters_available.append(basic_encounter_pool.keys())
			grabbed_encounter = basic_encounters_available.pop_at(encounter_rng.randi() % basic_encounters_available.size())
			return cached_encounters.get(grabbed_encounter)
			
	if tier == "NORMAL":
		if normal_encounters_available.size() > 0:
			
			grabbed_encounter = normal_encounters_available.pop_at(encounter_rng.randi() % normal_encounters_available.size())
			
			if cached_encounters.has(grabbed_encounter):
				return cached_encounters.get(grabbed_encounter)
			
			else:
				print("Loading encounter...")
				var loaded_encounter = ResourceLoader.load(normal_encounter_pool.get(grabbed_encounter))
				cached_encounters[grabbed_encounter] = loaded_encounter
				return loaded_encounter
			
		else:
			normal_encounters_available.append(normal_encounter_pool.keys())
			grabbed_encounter = normal_encounters_available.pop_at(encounter_rng.randi() % normal_encounters_available.size())
			return cached_encounters.get(grabbed_encounter)
		
	if tier == "ELITE":
		if elite_encounters_available.size() > 0:
			
			grabbed_encounter = elite_encounters_available.pop_at(encounter_rng.randi() % elite_encounters_available.size())
			
			if cached_encounters.has(grabbed_encounter):
				return cached_encounters.get(grabbed_encounter)
			
			else:
				print("Loading encounter...")
				var loaded_encounter = ResourceLoader.load(elite_encounter_pool.get(grabbed_encounter))
				cached_encounters[grabbed_encounter] = loaded_encounter
				return loaded_encounter
			
		else:
			elite_encounters_available.append(elite_encounter_pool.keys())
			grabbed_encounter = elite_encounters_available.pop_at(encounter_rng.randi() % elite_encounters_available.size())
			return cached_encounters.get(grabbed_encounter)
		
	if tier == "BOSS":
		if boss_encounters_available.size() > 0:
			
			grabbed_encounter = boss_encounters_available.pop_at(encounter_rng.randi() % boss_encounters_available.size())
			
			if cached_encounters.has(grabbed_encounter):
				return cached_encounters.get(grabbed_encounter)
			
			else:
				print("Loading encounter...")
				var loaded_encounter = ResourceLoader.load(boss_encounter_pool.get(grabbed_encounter))
				cached_encounters[grabbed_encounter] = loaded_encounter
				print(grabbed_encounter)
				return loaded_encounter
			
		else:
			boss_encounters_available.append(boss_encounter_pool.keys())
			grabbed_encounter = boss_encounters_available.pop_at(encounter_rng.randi() % boss_encounters_available.size())
			return cached_encounters.get(grabbed_encounter)
