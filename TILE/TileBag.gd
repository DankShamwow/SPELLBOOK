extends Control
class_name TileBag

var starting_bag = StartingTiles.StartingTileArray
var current_deck = GeneralManager.current_deck
var available_tiles = GeneralManager.available_tiles
var tiles_in_play = GeneralManager.tiles_in_play
var buffered_tiles = GeneralManager.buffered_tiles

@export var tile_scene: PackedScene = preload("res://TILE/LetterTile.tscn")
@export var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")
@export var bag_grid: GridContainer

var tile: LetterTile

func _ready():
	for i in current_deck.size():
		## bag_tile is a GridTile scene, which wants data from the LetterTile class.
		var bag_tile = grid_tile_scene.instantiate()
		
		## We get the LetterTile data from the current index of the deck
		bag_tile.tile = current_deck[i]
		
		## Then we add the bag_tile to the bag_grid, a GridContainer.
		bag_grid.add_child(bag_tile)
		
		#print(bag_tile)
		#print("Tile ", bag_tile.tile.tile_index, " Created")
		#print(bag_tile.tile.type, " ", bag_tile.tile.letter)
		

#func _process(delta):
	#for i in tiles_in_play.size():
		#if current_deck.has(tiles_in_play[i]):
			#var tile_index = tiles_in_play[i].tile_index
			#bag_tile_grid.get_child(tile_index).fade()

func _on_update_bag_tiles() -> void:
	print("Emission Received!")
	for i in tiles_in_play.size():
		if current_deck.has(tiles_in_play[i]):
			var tile_index = tiles_in_play[i].tile_index
			bag_grid.get_child(tile_index).fade()

	for i in available_tiles.size():
		if current_deck.has(available_tiles[i]):
			var tile_index = available_tiles[i].tile_index
			bag_grid.get_child(tile_index).unfade()

	for i in buffered_tiles.size():
		if current_deck.has(buffered_tiles[i]):
			var tile_index = buffered_tiles[i].tile_index
			bag_grid.get_child(tile_index).mark_buffer()
			
func _on_update_buffered_tiles() -> void:
	print(buffered_tiles.size())
	print(available_tiles.size())
	print(tiles_in_play.size())
	for i in buffered_tiles.size():
		var popped_buffer = buffered_tiles.pop_front()
		if popped_buffer:
			var popped_index = popped_buffer.tile_index
			available_tiles.append(popped_buffer)
			bag_grid.get_child(popped_index).mark_buffer()
			await get_tree().create_timer(0.01).timeout
	_on_update_bag_tiles()
