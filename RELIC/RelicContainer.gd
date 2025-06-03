extends TextureRect
class_name RelicContainer

@export var relic_control = Control 

## current_relics is the list of Relics that the player currently has.
var current_relics = GeneralManager.current_relics

var relic_dictionary = RelicDictionary.RelicList
const RELIC_SCENE := preload("res://RELIC/Relic.tscn")

func _ready() -> void:
	pass

func add_relics(relics_array: Array[Relic]) -> void:
	for relic: Relic in relics_array:
		add_relic(relic.relic_id)
		
func add_relic(relic_id: int) -> void:
	#if has_relic(relic_id):
		#return
	
	print("Adding relic " + str(relic_id) + ".")
	var new_relic = relic_dictionary.get(str(relic_id))
	var relic_node = RELIC_SCENE.instantiate() as Relic
	relic_node.set_script(new_relic)
	%RelicCollection.add_child(relic_node)
	current_relics.append(relic_node)

func has_relic(id: int) -> bool:
	for relic in %RelicCollection.get_children():
		if relic.relic_id == id and is_instance_valid(relic):
			return true
	
	return false
