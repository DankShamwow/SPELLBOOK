extends Control
class_name PlayArea

var filePath = "res://WORDLISTS/STANDARD/"


## current_deck is the list of LetterTiles in your deck.
var current_deck = GeneralManager.current_deck

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles = GeneralManager.available_tiles

## tiles_in_play is the list of LetterTiles currently in the grid or being used to play a word.
var tiles_in_play = GeneralManager.tiles_in_play

## buffered_tiles is the list of LetterTiles that was just played, and will be returned to the
## list of available tiles at the start of the next turn, or when the next shuffling event happens to the player's deck.
var buffered_tiles = GeneralManager.buffered_tiles

## current_relics is the list of Relics that the player currently has.
var current_relics = GeneralManager.current_relics

## modified_wordlist is the list of words that has been added to by various Relics.
var modified_wordlist 	= []

## scored_letter_count is the sum total of the numbers that have been scored.
var scored_letter_count = GeneralManager.scored_letter_count

## played_words_count is the sum total of the number of words that have been played.
var played_words_count = GeneralManager.played_words_count

## clicked_tile_array is a list of the GridTiles that have been clicked on.
var clicked_tile_array = []

## letters_from_tiles is a list of letters pulled from the GridTiles in clicked_tile_array
var letters_from_tiles = PackedStringArray([])

## word is the string that contains the word that we look up in the word lists.
var word = ""

## point_values determines the number of points that a letter scores for.
var point_values  	= [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

## mult_values determines the multiplier on the score based on the length of a word.
var mult_values		= [1, 1, 2, 2, 3, 3, 4, 5, 7, 10, 13, 18, 24, 30, 35, 40, 50, 60, 80, 100]

## possible_grid_positions lists all valid grid positions.
## If you're modding the game and you're seeing this, you're going to want to either increase the number of indeces here
## or rewrite the handling of this entirely. I did NOT want to make an item that increases the grid size, because
## it would completely fuck up the UI. You have been warned!!!
var possible_grid_positions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

## bag_open determines if the Tile Bag is open or not.
var bag_open = false

## scoring_check determines if a word is currently being played. It prevents you from adding letters to a word while it's being played.
var scoring_check = false

@export var tile_scene: PackedScene = preload("res://TILE/LetterTile.tscn")
@export var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")
var relic_scene = preload("res://RELIC/Relic.gd")

## bag_grid is the parent of all the tiles that spawn when you open the Tile Bag.
@export var bag_grid: GridContainer

## tile_grid is the parent of all the tiles in the grid. We use the grid_index of a GridTile to recognize which child it is.
@export var tile_grid: Node2D

## to_be_destroyed is the parent of all tiles about to be destroyed, such as when words are played.
@export var to_be_destroyed: Node2D

## relics_collection is the parent of all relic nodes. Parent your relics to this.
@export var relics_collection: Node2D

var tiles: LetterTile
var tile_slots: Array[GridTile]

signal update_bag_tiles()
signal update_buffered_tiles()
signal disable_tile_bag(state)

func spawn_new_tile(grid_index):
	## added_tile is a GridTile with the data from a LetterTile
	var added_tile = grid_tile_scene.instantiate()
	
	## called_tile is a LetterTile
	var called_tile = available_tiles.pop_at(randi() % available_tiles.size())
	
	# Add the LetterTile to the GridTile so it has data
	added_tile.tile = called_tile
	
	# Append the called_tile to the tiles_in_play array, add the added_tile to the tile_grid
	tiles_in_play.append(called_tile)
	tile_grid.add_child(added_tile)
	
	added_tile.spawned_in()
	
	# Give it a grid index,
	added_tile.tile.grid_index = grid_index
	added_tile.set_name(str("GridTile" + str(added_tile.tile.grid_index)))
	added_tile.tile_clicked.connect(self._on_tile_clicked)
	added_tile.tile_hovered.connect(self._is_tile_hovered)
	
	# Set the tile's drop position as well as the target position after dropping
	# We use modulo of 4 to determine the column, and the floor of dividing by four to determine the row. This should be foolproof.
	added_tile.tile.target = Vector2((((added_tile.tile.grid_index % 4) * 32) + 8),((floor(added_tile.tile.grid_index / 4) * 32) + 8))
	# Based on the index, we tell it what column to drop from, and it spawns above.
	added_tile.position = Vector2((((added_tile.tile.grid_index % 4 ) * 32) + 8), -32)
	update_bag_tiles.emit()
	

## Instantiate each GridTile, pop a LetterTile from the available tile array, 
## then give the data to our new Gridtile. We also give it a grid index.
func _on_test_button_pressed():
	get_node("TestButton").set_disabled(true)
	
	for i in range(0, 16):
		var grid_index = 15 - i
		spawn_new_tile(grid_index)
		await get_tree().create_timer(0.04).timeout
	
	print(buffered_tiles.size())
	print(available_tiles.size())
	print(tiles_in_play.size())
	get_node("TestButton").set_disabled(false)
	
func _on_relic_button_pressed():
	get_node("RelicButton").set_disabled(true)
	print("Giving you an Upper Case!")
	var new_relic = preload("res://RELIC/relic_0.tscn").instantiate()
	new_relic.position = Vector2((-216 + (32 * current_relics.size())), -132)
	current_relics.append(new_relic)
	relics_collection.add_child(new_relic)
	var new_relic_2 = preload("res://RELIC/relic_-1.tscn").instantiate()
	new_relic_2.position = Vector2((-216 + (32 * current_relics.size())), -132)
	current_relics.append(new_relic_2)
	relics_collection.add_child(new_relic_2)
	get_node("RelicButton").set_disabled(false)
	
func _on_shuffle_button_pressed():
	update_buffered_tiles.emit()
	get_node("ShuffleButton").set_disabled(true)
	get_node("ScoreLabel").text = ""
	tiles_in_play.clear()
	letters_from_tiles.clear()
	clicked_tile_array.clear()
	word_from_tiles(letters_from_tiles)
	
	for i in tile_grid.get_child_count():
		## tile_to_push is a GridTile that will be deleted.
		var tile_to_push = tile_grid.get_child(i)
		
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
		
		## buffered_tiles is a list of the LetterTiles that are in the buffer area between played words and turns.
		buffered_tiles.append(tile_to_push.tile)
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32) + 8), 160)
		tile_to_push_array.append(tile_to_push)
		tile_to_push.is_dying()
	
	for i in range(0, 16):
		var grid_index = 15 - i
		spawn_new_tile(grid_index)
		update_bag_tiles.emit()
		await get_tree().create_timer(0.04).timeout

	get_node("ShuffleButton").set_disabled(false)
	
func _on_tile_bag_toggle(toggled_on):
	bag_open = toggled_on
	print(bag_open)

			# Vector2(((bag_tile.tile.tile_index % 10) * 32), ((floor(bag_tile.tile.tile_index / 10) * 32)))
func _physics_process(delta):
	for i in tile_grid.get_child_count():
		## tile_to_move is a GridTile with a target that it needs to move to.
		var tile_to_move = tile_grid.get_child(i)
		
		## target_index_location is the target for that tile to move to, and it's stored in the LetterTile.
		var target_index_location = tile_to_move.tile.target
		
		var velocity = 0.05 * tile_to_move.position.direction_to(target_index_location)
		velocity = velocity / delta
		
		# Cutoffs for how fast the tile should be moving, or if it should get snapped into place.
		if tile_to_move.position.distance_to(target_index_location) > 0.5:
			tile_to_move.position += (velocity) * tile_to_move.position.distance_to(target_index_location)/10
		elif tile_to_move.position.distance_to(target_index_location) > 0:
			tile_to_move.position = target_index_location
			if not clicked_tile_array.has(tile_to_move):
				if not buffered_tiles.has(tile_to_move.tile):
					$TileSound.play()
	
		# Kill our tiles that are being told to go to the buffer.
		if buffered_tiles.has(tile_to_move.tile) && tile_to_move.position == tile_to_move.tile.target:
			if not tile_to_move == null:
				tile_to_move.queue_free()

	for i in to_be_destroyed.get_child_count():
		var tile_to_move = to_be_destroyed.get_child(i)
		
		## target_index_location is the target for that tile to move to, and it's stored in the LetterTile.
		var target_index_location = tile_to_move.tile.target
		
		var velocity = 0.05 * tile_to_move.position.direction_to(target_index_location)
		velocity = velocity / delta
		
		# Cutoffs for how fast the tile should be moving, or if it should get snapped into place.
		if tile_to_move.position.distance_to(target_index_location) > 2:
			tile_to_move.position += (velocity) * tile_to_move.position.distance_to(target_index_location)/10
		elif tile_to_move.position.distance_to(target_index_location) > 0.3:
			tile_to_move.position = target_index_location
	
		# Kill our tiles that are being told to go to the buffer.
		if buffered_tiles.has(tile_to_move.tile) && tile_to_move.position == tile_to_move.tile.target:
			if not tile_to_move == null:
				tile_to_move.queue_free()

func _is_tile_hovered(which: GridTile, is_hovering: bool):
	
	## scaling_factor determines the visaul size of tiles in certain contexts.
	var scaling_factor = float(7.0 / (clicked_tile_array.size()+1))
	
	if clicked_tile_array.has(which) && clicked_tile_array.size() <= 7 && is_hovering == false:
		which.scale = Vector2(1, 1)
	
	if clicked_tile_array.has(which) && clicked_tile_array.size() > 7 && is_hovering == false:
		which.scale_to_word_size(scaling_factor)

func _on_tile_clicked(which: GridTile, action: GridTile.GridTileAction):
	if scoring_check == false:
		if bag_open == false:
			print("This is working!")
			# If the clicked tile array does NOT have this tile, then add it to the array and do stuff.
			if action == GridTile.GridTileAction.PLAY:
				var first_tile = null
				var scaling_factor = float(7.0 / (clicked_tile_array.size()+1))
				
				if not clicked_tile_array.has(which):
					$TileSound.play()
					var clicked_tile = which
					clicked_tile_array.append(clicked_tile)
					letters_from_tiles.append(str(which.tile.TileLetter.keys()[which.tile.letter]).to_snake_case())
					print(letters_from_tiles)
					if clicked_tile_array.size() <= 6:
						
						# We need the first tile to be able to determine the positions of the rest of the tiles.
						first_tile = clicked_tile_array.front()
						first_tile.tile.target = Vector2(56 - (19 * clicked_tile_array.size() - 19), -100) # Originally 20, change to 16?
						var first_tile_x = first_tile.tile.target.x
						for i in clicked_tile_array.size():
							clicked_tile_array[i].tile.target = Vector2(first_tile_x + (38 * i), -100) # Originally 40, change to 32?
							
					elif clicked_tile_array.size() > 6:
						scaling_factor = float(7.0 / (clicked_tile_array.size()+1))
						first_tile = clicked_tile_array.front()
						first_tile.tile.target = Vector2(56 - (19 * clicked_tile_array.size() - 19)*scaling_factor, -100) # Originally 10 and 20, change to 8 and 16?
						var first_tile_x = first_tile.tile.target.x
						for i in clicked_tile_array.size():
							clicked_tile_array[i].tile.target = Vector2((first_tile_x + (38 * i *scaling_factor)), -100) # Originally 40, change to 32?
				
				elif clicked_tile_array.has(which):
					
					# Get the tile we clicked on, then pop it from the arrays
					var clicked_tile = which
					
					## popped_tile_index is the location of the tile that was just clicked on.
					var popped_tile_index = clicked_tile_array.find(clicked_tile)
					
					letters_from_tiles.remove_at(popped_tile_index)
					print(letters_from_tiles)
					
					## popped_tile is a tile that was being used to form a word, but was clicked on and removed.
					var popped_tile = clicked_tile_array.pop_at(clicked_tile_array.find(clicked_tile))
					popped_tile.tile.target = Vector2((((popped_tile.tile.grid_index % 4) * 32) + 8),((floor(popped_tile.tile.grid_index / 4) * 32) + 8))
					popped_tile.scale_back_to_grid()
					
					# Readjust tile goal positions based on the number of tiles in clicked_tiles_array
					if clicked_tile_array:
						first_tile = clicked_tile_array.front()
						if clicked_tile_array.size() > 6:
							scaling_factor = float(7.0 / (clicked_tile_array.size()+1))
							first_tile.tile.target = Vector2(56 - (19 * clicked_tile_array.size() - 19) * scaling_factor, -100) # Originally 10 and 20, change to 8 and 16?
							var first_tile_x = first_tile.tile.target.x
							for i in clicked_tile_array.size():
								clicked_tile_array[i].tile.target = Vector2(first_tile_x + (38 * i * scaling_factor), -100) # Originally 40, change to 32?
						
						elif clicked_tile_array.size() <= 6:
							first_tile.tile.target = Vector2(56 - (19 * clicked_tile_array.size() - 19), -100) # Originally 20, change to 16?
							var first_tile_x = first_tile.tile.target.x
							for i in clicked_tile_array.size():
								clicked_tile_array[i].tile.target = Vector2(first_tile_x + (38 * i), -100) # Originally 40, change to 32?

				if clicked_tile_array.size() > 6:
					scaling_factor = float(6.5 / (clicked_tile_array.size()+1))
					print(scaling_factor)
					for i in clicked_tile_array.size():
						clicked_tile_array[i].scale_to_word_size(scaling_factor)
				elif clicked_tile_array.size() <= 6:
					print(scaling_factor)
					scaling_factor = 1.0
					for i in clicked_tile_array.size():
						clicked_tile_array[i].scale_to_word_size(scaling_factor)
				
			word_from_tiles(letters_from_tiles)
		else:
			pass
	else:
		pass

func word_from_tiles(letters_from_tiles):
	print("This is also working?")
	word = "".join(letters_from_tiles)
	print(word)
	if word.length() >= 3:
		
		# Check the modified wordlist first, because it's faster.
		if modified_wordlist.has(word):
			
			get_node("WordLabel").text = str(word.to_upper() + " is a valid word!")
			print("Valid word found!")
			get_node("PlayButton").set_disabled(false)
			
			var raw_word_score = calc_raw_word_score()
			
		else:
			var list = FileAccess.open(filePath + word[0] + word[1] + ".txt", FileAccess.READ)
			while list.get_position() < list.get_length():
				var line = list.get_line()
				
				if not line == word:
					get_node("WordLabel").text = ""
					get_node("PlayButton").set_disabled(true)
				
				if line == word:
					get_node("WordLabel").text = str(word.to_upper() + " is a valid word!")
					print("Valid word found!")
					get_node("PlayButton").set_disabled(false)
					list.close()
	else:
		get_node("WordLabel").text = ""
		get_node("PlayButton").set_disabled(true)
		
	if not get_node("PlayButton").is_disabled():
		var raw_word_score = calc_raw_word_score()
		if raw_word_score >= 20 and raw_word_score < 50 and not $Good.is_playing():
			$Good.play()
			
		elif raw_word_score >= 50 and raw_word_score < 100 and not $Great.is_playing():
			$Great.play()
			
		elif raw_word_score >= 100 and raw_word_score < 250 and not $Excellent.is_playing():
			$Excellent.play()
			
		elif raw_word_score >= 250 and raw_word_score < 500 and not $Amazing.is_playing():
			$Amazing.play()
			
		elif raw_word_score >= 500 and not $Fantastic.is_playing():
			$Fantastic.play()

func _on_play_button_pressed():
	scoring_check = true
	get_node("PlayButton").set_disabled(true)
	played_words_count += 1
	
	var points_score = 0
	var mult_score = 0
	var letter_score = 0
	var total_score = 0
	var word_retriggers = 0
	var letter_retriggers = 0
	
	## marked_to_replace is a list of the grid index values that tiles need to either
	## fall into, or for new tiles to spawn and fall into.
	var marked_to_replace = []
	
	# If there are any effects that would retrigger the scoring of the word, they'll be processed here.
	# If there's any special effects, they should also be processed here.
	for i in current_relics.size():
		word_retriggers += current_relics[i].word_retrigger_effect(word)
	
	for i in word_retriggers + 1:
		
		for j in clicked_tile_array.size():
			
			for k in current_relics.size():
				
				# Pull any letter retrigger effects from relics
				letter_retriggers += current_relics[k].letter_retrigger_effect(clicked_tile_array[j].tile.letter)
			
			# Score each letter for a number of times equal to their retriggers, plus one.
			for k in letter_retriggers + 1:
				
				# Score the actual letter and get the score, plus increment the scored letter count.
				letter_score += clicked_tile_array[j].score_tile()
				scored_letter_count += 1
				# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
				
				await get_tree().create_timer(0.005).timeout
				
				# TODO: Put Notch-based effects here? Or maybe they belong inside the tile scoring. I don't know.
				
				# Pull any bonus point effects from relics.
				for l in current_relics.size():
					
					# Grid index based effects
					letter_score += current_relics[l].grid_index_effect(clicked_tile_array[j].tile.grid_index)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Letter based effects
					letter_score += current_relics[l].letter_score_effect(clicked_tile_array[j].tile.letter)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Word based effects that trigger on each letter of a word
					letter_score += current_relics[l].word_letter_bonus_score_effect(word)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Effects based on the total count of scored letters
					letter_score += current_relics[l].x_letters_played_effect(scored_letter_count, letter_score)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
			
			points_score += letter_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
			# We're done scoring that letter, so we need to zero the letter score and prep for the next letter.
			letter_score = 0
			letter_retriggers = 0
			await get_tree().create_timer(0.005).timeout
			
			# We don't want the mult score to go back down when we potentially rescore a word.
			var previous_mult_score = mult_score
			mult_score = mult_values[j]
			if previous_mult_score > mult_score:
				mult_score = previous_mult_score
			
			# If something is going to modify the mult score, it goes here.
			for k in current_relics.size():
				# TODO: Add modifiers to the mult score.
				pass
			
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			await get_tree().create_timer(0.075).timeout
			
			total_score = points_score * mult_score
			
			# If something is going to modify the total word score, it goes here.
			for k in current_relics.size():
				# TODO: Add modifiers to the total score.
				pass
			
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			await get_tree().create_timer(0.075).timeout
			
	#$Subaluwa.play()

	# Post-processing for the scoring algorithm.
	for i in clicked_tile_array.size():
		marked_to_replace.append(clicked_tile_array[i].tile.grid_index)
		clicked_tile_array[i].reparent(to_be_destroyed)
		tiles_in_play.remove_at(i)
	
	# Make the bag look pretty just before the tiles go into it.
	disable_tile_bag.emit(true)
	
	for i in clicked_tile_array.size():
		var last_letter = clicked_tile_array.pop_back()
		buffered_tiles.append(last_letter.tile)
		print(buffered_tiles.size())
		last_letter.z_index = 120
		last_letter.is_dying()
		last_letter.tile.target = Vector2(340, -148)
		await get_tree().create_timer(0.04).timeout
	
	update_bag_tiles.emit()
	letters_from_tiles.clear()
	word_from_tiles(letters_from_tiles)
	move_tiles_into_place()
	scoring_check = false
	await get_tree().create_timer(0.5).timeout
	disable_tile_bag.emit(false)
	
func move_tiles_into_place():
	var remaining_tiles = []
	for i in tile_grid.get_child_count():
		remaining_tiles.append(tile_grid.get_child(i).tile.grid_index)
		var found_tile = tile_grid.get_child(i)
		if found_tile.tile.grid_index < 12:
			print(found_tile.tile.grid_index)
			if found_tile.tile.grid_index < 4 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 32) + 8),((floor(found_tile.tile.grid_index / 4) * 32) + 8))
				remaining_tiles[i] += 4

			if found_tile.tile.grid_index < 8 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 32) + 8),((floor(found_tile.tile.grid_index / 4) * 32) + 8))
				remaining_tiles[i] += 4

			if found_tile.tile.grid_index < 12 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 32) + 8),((floor(found_tile.tile.grid_index / 4) * 32) + 8))
				remaining_tiles[i] += 4
		await get_tree().create_timer(0.04).timeout
	spawn_new_tiles(remaining_tiles)

func spawn_new_tiles(remaining_tiles):
	var tiles_to_fill = []
	
	for i in possible_grid_positions.size():
		if not remaining_tiles.has(possible_grid_positions[i]):
			tiles_to_fill.append(possible_grid_positions[i])
	
	tiles_to_fill.reverse()
	
	for i in (16 - remaining_tiles.size()):
		var grid_index = tiles_to_fill[i]
		spawn_new_tile(grid_index)
		await get_tree().create_timer(0.04).timeout
		
	rename_tiles()
	word_from_tiles(letters_from_tiles)
	update_bag_tiles.emit()

func rename_tiles():
	for i in tile_grid.get_child_count():
		var temp_name = str("GridTile" + str(randi_range(100, 200)))
		tile_grid.get_child(i).set_name(temp_name)
	
	await get_tree().create_timer(0.04).timeout
	
	for i in tile_grid.get_child_count():
		if not tile_grid.get_child(i).name == str("GridTile"+str(tile_grid.get_child(i).tile.grid_index)):
			tile_grid.get_child(i).set_name(str("GridTile"+str(tile_grid.get_child(i).tile.grid_index)))
			
func calc_raw_word_score():
	var letter_score = 0
	var mult_score = 0
	var raw_word_score = 0
	for i in clicked_tile_array.size():
		letter_score += clicked_tile_array[i].score_tile_quiet()
		mult_score = mult_values[i]
		raw_word_score = letter_score * mult_score
	return raw_word_score
