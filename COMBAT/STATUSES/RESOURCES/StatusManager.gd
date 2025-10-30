extends Node

## List of all status effects found in the Status Effect directory that have been processed.
var cached_statuses: 		Dictionary[String, StringName] = {}
## List of all status effects by name.
var statuses_by_name: 		Dictionary[String, StringName] = {}
## List of all status effects by ID number.
var statuses_by_id: 		Dictionary[int, StringName] = {}
## List of all status effects that have been called thus far.
var loaded_statuses:		Dictionary[StringName, GDScript] = {}

const STATUS_SCENE = preload("res://COMBAT/STATUSES/RESOURCES/StatusEffect.tscn")

### Tile Debuff Types:
## Stoned 0, Locked 1, Burning 2, Plagued 3, Crumbling 4, Junked 5, Warped 6, 

### DoT Debuff Types:
## Burn 7, Poison 8, Bleed 9, Irradiated 10

### Attribute Status Types:
## Strength 11, Dexterity 12, Intelligence 13, Defense 14

### Utility Status Types:
## Thorns 15, Bolstered (Fast-Block) 16, Plated Armor 17, Regen 18, Purity (Debuff Resist) 19,
## 

func _ready() -> void:
	
	var full_path: String = "res://COMBAT/STATUSES/"
	
	var status_file_list = ResourceLoader.list_directory(full_path)
	
	for i in status_file_list.size():
		var current_file = status_file_list[i]
		if not current_file.ends_with(".gd"):
			var saved_path = full_path + current_file
			var current_line = ""
			var file = FileAccess.open(saved_path, FileAccess.READ)
			var content = file.get_as_text()
			
			while not current_line.contains("status_id = "):
				current_line = file.get_line()
			
			## We clip off everything that isn't the integer value to get the status's actual ID.
			var status_id = int(current_line.erase(0, 12))
			current_line = file.get_line()
			var status_name = String(current_line.erase(0, 14))
			
			print("Loaded: " + str(status_name) + " with ID: " + str(status_id))
			
			if cached_statuses.has(status_name):
				continue
				
			else:
				cached_statuses[current_file] = saved_path

## Function for instancing a called status and returning it to what called it.
func _instance_called_status(status: Variant) -> StatusEffect:
	## StringName
	var found_status 	= null
	## GDScript
	var loaded_status 	= null
	if statuses_by_id.has(status):
		found_status = statuses_by_id.get(status)
	elif statuses_by_name.has(status):
		found_status = statuses_by_name.get(status)
	else:
		print("ERROR: Status key was not an integer or string.")
		return null

	if found_status == null:
		print("ERROR: Status was not found! Are you sure you didn't make a typo?")
		return null

	else:
		if loaded_statuses.has(found_status):
			loaded_status = loaded_statuses.get(found_status)
			
		else:
			loaded_status = load(found_status)
			loaded_statuses[found_status] = loaded_status

	var new_status = STATUS_SCENE.instantiate()
	new_status.set_script(loaded_status)
	new_status._ready()

	return new_status
