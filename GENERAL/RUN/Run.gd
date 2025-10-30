extends Control
class_name Run

const COMBAT_SCENE := preload("res://GENERAL/GAME_SCENES/COMBAT/PlayArea2.tscn")
const RELIQUARY_SCENE := preload("res://GENERAL/GAME_SCENES/RELIQUARY/Reliquary.tscn")
const LIBRARY_SCENE := preload("res://GENERAL/GAME_SCENES/LIBRARY/Library.tscn")
const SHOP_SCENE := preload("res://GENERAL/GAME_SCENES/SHOP/Shop.tscn")
const REST_SCENE := preload("res://GENERAL/GAME_SCENES/REST/Rest.tscn")
const RANDOM_EVENT_SCENE := preload("res://GENERAL/GAME_SCENES/RANDOM_EVENT/RandomEventScene.tscn")

const SPECIALTY_REWARDS_SCENE := preload("res://COMBAT/TOOLS/SpecialtyRewards.tscn")
const TILE_MODIFY_SCENE := preload("res://TILE/TileModifyScreen.tscn")

const TEST_CHARACTER_SCENE := preload("res://COMBAT/CHARACTERS/TestCharacter.tscn")

@onready var current_view: Node = $CurrentView
@onready var map_button: Button = %MAP
@onready var combat_button: Button = %COMBAT
@onready var reliquary_button: Button = %RELIQUARY
@onready var library_button: Button = %LIBRARY
@onready var shop_button: Button = %SHOP
@onready var rest_button: Button = %REST
@onready var random_event_button: Button = %RANDOM_EVENT

var character = null

func _ready() -> void:
	GameEventHandler.specialty_rewards_popup.connect(self.popup_specialty_rewards)
	GameEventHandler.tile_modify_popup.connect(self.popup_tile_modify_screen)
	
	GeneralManager.replace_character_path = %Character
	if not character:
		var test_character = TEST_CHARACTER_SCENE
		character = test_character
		#RandomStartingTiles._randomize_start_tiles()
		_start_new_run()

func _start_new_run() -> void:
	_setup_event_connections()
	
	EncounterManager._load_area_encounters("WoodsOfTheWitless")
	
	GeneralManager.chapter_boss_encounter = EncounterManager.grab_new_encounter("BOSS")
	GeneralManager.prepare_word_dict()
	GeneralManager._on_run_start()
	
	RelicManager._load_relics()
	
	%NewMapHandler.generate_map()
	
	var character_instance = character.instantiate()
	%Character.add_child(character_instance)
	character_instance.scale = Vector2(1.5, 1.5)
	character_instance.position = Vector2(72, 192)
	GeneralManager.character_path = character_instance
	GameEventHandler.gold_changed.emit(100)
	
	var starting_bag = StartingTiles.generate_starting_tiles()
	for i in starting_bag.size():
		GeneralManager.current_deck.append(starting_bag[i])
	
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

func popup_specialty_rewards(reward_notch_count: int = 0, reward_notch_uncommons: int = 0, reward_notch_rares: int = 0, reward_notch_specified: Array = [], allow_tiles: bool = false, draw_size: int = 0, refresh: bool = false, use_shop_rng: bool = false):
	print("Bringing up specialty rewards!")
	var popup = SPECIALTY_REWARDS_SCENE.instantiate()
	$CurrentView.get_child(0).add_child(popup)
	popup._bringup_specialty_rewards(reward_notch_count, reward_notch_uncommons, reward_notch_rares, reward_notch_specified, allow_tiles, draw_size, refresh, use_shop_rng)

func popup_tile_modify_screen(tile: GridTile):
	print("Bringing up tile modify screen!")
	var popup = TILE_MODIFY_SCENE.instantiate()
	$CurrentView.get_child(0).add_child(popup)
	popup._write_tile(tile)

func _setup_event_connections() -> void:
	GameEventHandler.combat_exited.connect(_show_map)
	GameEventHandler.shop_exited.connect(_show_map)
	GameEventHandler.reliquary_exited.connect(_show_map)
	GameEventHandler.rest_exited.connect(_show_map)
	GameEventHandler.random_event_exited.connect(_show_map)
	GameEventHandler.map_exited.connect(_on_map_exited)
	
	combat_button.pressed.connect(_change_view.bind(COMBAT_SCENE))
	combat_button.pressed.connect(_close_map)
	shop_button.pressed.connect(_change_view.bind(SHOP_SCENE))
	shop_button.pressed.connect(_close_map)
	reliquary_button.pressed.connect(_change_view.bind(RELIQUARY_SCENE))
	reliquary_button.pressed.connect(_close_map)
	library_button.pressed.connect(_change_view.bind(LIBRARY_SCENE))
	library_button.pressed.connect(_close_map)
	rest_button.pressed.connect(_change_view.bind(REST_SCENE))
	rest_button.pressed.connect(_close_map)
	random_event_button.pressed.connect(_change_view.bind(RANDOM_EVENT_SCENE))
	random_event_button.pressed.connect(_close_map)
	map_button.pressed.connect(_show_map)

func _close_map() -> void:
	%NewMapHandler._force_close_map()

func _on_map_exited(room: Room) -> void:
	match room.type:
		
		Room.RoomType.MONSTER:
			if GeneralManager.chapter_combat_clear_count < 3:
				GeneralManager.combat_encounter = EncounterManager.grab_new_encounter("BASIC")
			else:
				GeneralManager.combat_encounter = EncounterManager.grab_new_encounter("NORMAL")
			_change_view(COMBAT_SCENE)
			GeneralManager.is_combat_active = true
			GeneralManager.current_location = "COMBAT"

				
		Room.RoomType.ELITE:
			GeneralManager.combat_encounter = EncounterManager.grab_new_encounter("ELITE")
			_change_view(COMBAT_SCENE)
			GeneralManager.is_combat_active = true
			GeneralManager.current_location = "COMBAT"
			
		Room.RoomType.BOSS:
			GeneralManager.combat_encounter = GeneralManager.chapter_boss_encounter
			_change_view(COMBAT_SCENE)
			GeneralManager.is_combat_active = true
			GeneralManager.current_location = "COMBAT"
			
		Room.RoomType.TREASURE:
			_change_view(RELIQUARY_SCENE)
			GeneralManager.current_location = "RELIQUARY"
			
		Room.RoomType.LIBRARY:
			_change_view(LIBRARY_SCENE)
			GeneralManager.current_location = "LIBRARY"
			
		Room.RoomType.SHOP:
			_change_view(SHOP_SCENE)
			GeneralManager.current_location = "SHOP"
			
		Room.RoomType.REST:
			_change_view(REST_SCENE)
			GeneralManager.current_location = "REST"
			
		Room.RoomType.RANDOM:
			_change_view(RANDOM_EVENT_SCENE)
			GeneralManager.current_location = "EVENT"
