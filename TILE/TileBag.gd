extends Control
class_name TileBag

var starting_bag = StartingTiles2.StartingTileArray
var current_deck = GeneralManager.current_deck
var available_tiles = GeneralManager.available_tiles
var tiles_in_play = GeneralManager.tiles_in_play
var buffered_tiles = GeneralManager.buffered_tiles

@export var tile_scene: PackedScene = preload("res://TILE/LetterTile.tscn")
@export var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")
@export var no_click_area: CanvasLayer
@export var bag_scroller: ScrollContainer
@export var bag_grid: GridContainer

var tile: LetterTile

var bag_list = []

signal tile_bag_toggle(toggled_on)

func _on_tile_bag_button_toggled(toggled_on: bool):
	tile_bag_toggle.emit(toggled_on)
	print(buffered_tiles.size())
	print(available_tiles.size())
	print(tiles_in_play.size())
	if toggled_on == true:
		no_click_area.set_layer(3)
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

			if available_tiles.has(bag_tile.tile):
				bag_tile.unfade()
			
	if toggled_on == false:
		
		get_node("TileBagButton").set_disabled(true)
		for i in bag_grid.get_child_count():
			var tile_to_bag = bag_list.pop_back()
			tile_to_bag.is_being_bagged()
		get_node("TileBagButton").set_disabled(false)
		
		no_click_area.set_layer(-128)
	print(bag_grid.get_child_count())
	
func _on_update_bag_tiles() -> void:
	print("Emission Received!")
	for i in current_deck.size():
		if tiles_in_play.has(current_deck[i]):
			var tile_index = current_deck[i].tile_index
			if $TileBagButton.is_pressed():
				bag_grid.get_child(tile_index).fade()

		elif buffered_tiles.has(current_deck[i]):
			var tile_index = current_deck[i].tile_index
			if $TileBagButton.is_pressed():
				bag_grid.get_child(tile_index).mark_buffer()

		elif available_tiles.has(current_deck[i]):
			var tile_index = current_deck[i].tile_index
			if $TileBagButton.is_pressed():
				bag_grid.get_child(tile_index).unfade()
			

			
func _on_update_buffered_tiles() -> void:
	for i in buffered_tiles.size():
		var popped_buffer = buffered_tiles.pop_front()
		if popped_buffer:
			available_tiles.append(popped_buffer)
			await get_tree().create_timer(0.01).timeout
	_on_update_bag_tiles()
	
func _on_disable_tile_bag(state):
	$TileBagButton.set_disabled(state)
