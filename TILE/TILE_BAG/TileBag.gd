extends Control
class_name TileBag

var starting_bag = StartingTiles.StartingTileArray
var random_starting_tiles = RandomStartingTiles.StartingTileArray
var current_deck = GeneralManager.current_deck
var current_combat_deck = GeneralManager.current_combat_deck
var available_tiles = GeneralManager.available_tiles
var tiles_in_play = GeneralManager.tiles_in_play
var buffered_tiles = GeneralManager.buffered_tiles
var destroyed_tiles = GeneralManager.destroyed_tiles
var vaporized_tiles = GeneralManager.vaporized_tiles

@export var tile_scene: PackedScene = preload("res://TILE/LETTER_TILE/LetterTile.tscn")
@export var grid_tile_scene: PackedScene = preload("res://TILE/GRID_TILE/GridTile.tscn")
@export var no_click_area: CanvasLayer
@export var fade_in_mask: ColorRect
@export var bag_scroller: ScrollContainer
@export var bag_grid: GridContainer

var tile: LetterTile

var bag_list = []

signal tile_bag_toggle(toggled_on)

func _ready():
	GameEventHandler.update_bag_tiles.connect(_on_update_bag_tiles)
	GameEventHandler.update_buffered_tiles.connect(_on_update_buffered_tiles)
	GameEventHandler.disable_tile_bag.connect(_on_disable_tile_bag)

func _on_tile_bag_button_toggled(toggled_on: bool):
	print(GeneralManager.is_map_open)
	print(GeneralManager.is_combat_active)
	print(current_combat_deck.size())
	if GeneralManager.is_combat_active == true:
		GeneralManager.is_bag_open = true
		tile_bag_toggle.emit(toggled_on)
		if toggled_on == true:
			no_click_area.set_layer(9)
			for i in current_combat_deck.size():
				print("Adding tile: " + str(i) + ".")
				
				## bag_tile is a GridTile with the data of a LetterTile from your deck.
				var bag_tile = grid_tile_scene.instantiate()

				bag_tile.tile = current_combat_deck[i]
				
				bag_grid.add_child(bag_tile)
				bag_list.append(bag_tile)
				#bag_tile.position = Vector2(8, 24)
				#var target = Vector2((-544 + ((bag_tile.tile.tile_index % 10) * 28)), (48+(ceil(bag_tile.tile.tile_index/10)*44)))
				
				bag_tile.spawned_from_bag()
				
				if tiles_in_play.has(bag_tile.tile):
					bag_tile.fade()

				if buffered_tiles.has(bag_tile.tile):
					bag_tile.mark_buffer()

				if destroyed_tiles.has(bag_tile.tile):
					bag_tile.mark_destroyed()
					
				if vaporized_tiles.has(bag_tile.tile):
					bag_tile.mark_vaporized()

				if available_tiles.has(bag_tile.tile):
					bag_tile.unfade()
					
		if toggled_on == false:
			for i in bag_grid.get_child_count():
				var tile_to_bag = bag_list.pop_back()
				tile_to_bag.is_being_bagged()
			%TileBagButton.set_disabled(true)
			await get_tree().create_timer(0.5).timeout
			no_click_area.set_layer(-128)
			GeneralManager.is_bag_open = false
			%TileBagButton.set_disabled(false)
		
	if GeneralManager.is_combat_active == false:
		GeneralManager.is_bag_open = true
		tile_bag_toggle.emit(toggled_on)
		if toggled_on == true:
			no_click_area.set_layer(9)
			for i in current_deck.size():
				
				## bag_tile is a GridTile with the data of a LetterTile from your deck.
				var bag_tile = grid_tile_scene.instantiate()

				bag_tile.tile = current_deck[i]
				
				bag_grid.add_child(bag_tile)
				bag_list.append(bag_tile)
				#bag_tile.position = Vector2(8, 24)
				#var target = Vector2((-544 + ((bag_tile.tile.tile_index % 10) * 28)), (48+(ceil(bag_tile.tile.tile_index/10)*44)))
				
				bag_tile.spawned_from_bag()
				
				if tiles_in_play.has(bag_tile.tile):
					bag_tile.fade()

				if buffered_tiles.has(bag_tile.tile):
					bag_tile.mark_buffer()

				if destroyed_tiles.has(bag_tile.tile):
					bag_tile.mark_destroyed()
					
				if vaporized_tiles.has(bag_tile.tile):
					bag_tile.mark_vaporized()

				if available_tiles.has(bag_tile.tile):
					bag_tile.unfade()
					
		if toggled_on == false:
			
			for i in bag_grid.get_child_count():
				var tile_to_bag = bag_list.pop_back()
				tile_to_bag.is_being_bagged()
			%TileBagButton.set_disabled(true)
			await get_tree().create_timer(0.5).timeout
			no_click_area.set_layer(-128)
			GeneralManager.is_bag_open = false
			%TileBagButton.set_disabled(false)


func _on_update_bag_tiles() -> void:
	#print("Emission Received!")
	#print(current_combat_deck.size())
	#print(buffered_tiles.size())
	#print(destroyed_tiles.size())
	#print(vaporized_tiles.size())
	#print(available_tiles.size())
	#print(tiles_in_play.size())
	
	if GeneralManager.is_combat_active == true:
		for i in current_combat_deck.size():
			if tiles_in_play.has(current_combat_deck[i]):
				var tile_index = current_combat_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).fade()
					
			elif vaporized_tiles.has(current_combat_deck[i]):
				var tile_index = current_combat_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).mark_vaporized()
					
			elif destroyed_tiles.has(current_combat_deck[i]):
				var tile_index = current_combat_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).mark_destroyed()
			
			elif buffered_tiles.has(current_combat_deck[i]):
				var tile_index = current_combat_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).mark_buffer()

			elif available_tiles.has(current_combat_deck[i]):
				var tile_index = current_combat_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).unfade()
					
			else:
				var tile_index = current_combat_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).error_vision()
	
	if GeneralManager.is_combat_active == false:
		for i in current_deck.size():
			if tiles_in_play.has(current_deck[i]):
				var tile_index = current_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).fade()
					
			elif vaporized_tiles.has(current_deck[i]):
				var tile_index = current_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).mark_vaporized()
					
			elif destroyed_tiles.has(current_deck[i]):
				var tile_index = current_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).mark_destroyed()
			
			elif buffered_tiles.has(current_deck[i]):
				var tile_index = current_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).mark_buffer()

			elif available_tiles.has(current_deck[i]):
				var tile_index = current_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).unfade()
					
			else:
				var tile_index = current_deck[i].tile_index
				if %TileBagButton.is_pressed():
					bag_grid.get_child(tile_index).error_vision()

func _on_update_buffered_tiles() -> void:
	for i in buffered_tiles.size():
		var popped_buffer = buffered_tiles.pop_front()
		if popped_buffer:
			available_tiles.append(popped_buffer)
	_on_update_bag_tiles()

func _on_disable_tile_bag(state):
	%TileBagButton.set_disabled(state)

func _on_map_toggle(toggled_on: Variant) -> void:
	pass # Replace with function body.
