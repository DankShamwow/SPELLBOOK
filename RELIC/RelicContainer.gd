extends TextureRect
class_name RelicContainer

@export var relic_control = Control 

## current_relics is the list of Relics that the player currently has.
var current_relics = GeneralManager.current_relics

const RELIC_SCENE := preload("res://RELIC/Relic.tscn")

func _ready() -> void:
	GameEventHandler.add_relic.connect(self.add_relic)

func add_relics(relics_array: Array[Relic]) -> void:
	for relic: Relic in relics_array:
		add_relic(relic.relic_id)
		
func add_relic(relic_id: int) -> void:
	var found_relic = RelicManager.relic_ids.find_key(relic_id)
	var granted_relic = RelicManager.relic_list.get(found_relic)
	
	var relic_node = RELIC_SCENE.instantiate() as Relic
	
	if RelicManager.loaded_relics.get(relic_id):
		relic_node.set_script(RelicManager.loaded_relics.get(relic_id))
	
	else:
		granted_relic = load(granted_relic)
		relic_node.set_script(granted_relic)
	
	print("Adding relic " + str(relic_id) + ".")
	%RelicCollection.add_child(relic_node)
	relic_node.on_pickup_effect()
	current_relics.append(relic_node)
