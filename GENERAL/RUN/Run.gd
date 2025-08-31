extends Control
class_name Run

const COMBAT_SCENE := preload("res://GENERAL/GAME_SCENES/COMBAT/PlayArea2.tscn")
const RELIQUARY_SCENE := preload("res://GENERAL/GAME_SCENES/RELIQUARY/Reliquary.tscn")
const SHOP_SCENE := preload("res://GENERAL/GAME_SCENES/SHOP/Shop.tscn")
const REST_SCENE := preload("res://GENERAL/GAME_SCENES/REST/Rest.tscn")
const RANDOM_EVENT_SCENE := preload("res://GENERAL/GAME_SCENES/RANDOM_EVENT/RandomEventScene.tscn")

const TEST_CHARACTER_SCENE := preload("res://COMBAT/CHARACTERS/TestCharacter.tscn")

var starting_bag = StartingTiles.StartingTileArray
var current_deck = GeneralManager.current_deck

# This is intended to be temporary. Let's see if it stays that way.
signal add_relic(relic_id: int)

@onready var current_view: Node = $CurrentView
@onready var map_button: Button = %MAP
@onready var combat_button: Button = %COMBAT
@onready var reliquary_button: Button = %RELIQUARY
@onready var shop_button: Button = %SHOP
@onready var rest_button: Button = %REST
@onready var random_event_button: Button = %RANDOM_EVENT

var character = null

func _ready() -> void:
	var replace_character_path = %Character
	GeneralManager.replace_character_path = replace_character_path
	if not character:
		var test_character = TEST_CHARACTER_SCENE
		character = test_character
		#RandomStartingTiles._randomize_start_tiles()
		_start_new_run()

func _start_new_run() -> void:
	_setup_event_connections()
	GeneralManager.prepare_word_dict()
	%NewMapHandler.generate_map()
	var character_instance = character.instantiate()
	%Character.add_child(character_instance)
	character_instance.scale = Vector2(1.5, 1.5)
	character_instance.position = Vector2(72, 192)
	GeneralManager.character_path = character_instance
	
	StartingTiles.generate_starting_tiles()
	
	for i in starting_bag.size():
		current_deck.append(starting_bag[i])
	
	%NewMapHandler._on_run_start()

func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	
	return new_view
	
func _show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	%NewMapHandler._unlock_next_map_rooms()

func _on_relic_button_pressed():
	%RELIC.set_disabled(true)
	print("Giving you an Upper Case!")
	add_relic.emit(1)
	add_relic.emit(3)

	%RELIC.set_disabled(false)

func _setup_event_connections() -> void:
	GameEventHandler.combat_exited.connect(_show_map)
	GameEventHandler.shop_exited.connect(_show_map)
	GameEventHandler.reliquary_exited.connect(_show_map)
	GameEventHandler.rest_exited.connect(_show_map)
	GameEventHandler.random_event_exited.connect(_show_map)
	GameEventHandler.map_exited.connect(_on_map_exited)
	
	combat_button.pressed.connect(_change_view.bind(COMBAT_SCENE))
	shop_button.pressed.connect(_change_view.bind(SHOP_SCENE))
	reliquary_button.pressed.connect(_change_view.bind(RELIQUARY_SCENE))
	rest_button.pressed.connect(_change_view.bind(REST_SCENE))
	random_event_button.pressed.connect(_change_view.bind(RANDOM_EVENT_SCENE))
	map_button.pressed.connect(_show_map)
	
func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.RoomType.MONSTER:
			_change_view(COMBAT_SCENE)
			GeneralManager.is_combat_active = true
		Room.RoomType.ELITE:
			_change_view(COMBAT_SCENE)
			GeneralManager.is_combat_active = true
		Room.RoomType.BOSS:
			_change_view(COMBAT_SCENE)
			GeneralManager.is_combat_active = true
		Room.RoomType.TREASURE:
			_change_view(RELIQUARY_SCENE)
		Room.RoomType.LIBRARY:
			_change_view(RELIQUARY_SCENE)
		Room.RoomType.SHOP:
			_change_view(SHOP_SCENE)
		Room.RoomType.REST:
			_change_view(REST_SCENE)
		Room.RoomType.RANDOM:
			_change_view(RANDOM_EVENT_SCENE)
