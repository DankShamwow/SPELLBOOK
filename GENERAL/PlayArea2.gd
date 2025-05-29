extends Control
class_name PlayArea2

## filePath is the path to the wordlist file that will be used to check words.
var filePath = "res://WORDLISTS/STANDARD/"

## current_deck is the list of LetterTiles in your deck.
var current_deck = GeneralManager.current_deck

## current_combat_deck is the list of LetterTiles in the player's deck for this combat only.
var current_combat_deck = GeneralManager.current_combat_deck

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles = GeneralManager.available_tiles

## tiles_in_play is the list of LetterTiles currently in the grid or being used to play a word.
var tiles_in_play = GeneralManager.tiles_in_play

## buffered_tiles is the list of LetterTiles that was just played, and will be returned to the
## list of available tiles at the start of the next turn, or when the next shuffling event happens to the player's deck.
var buffered_tiles = GeneralManager.buffered_tiles

## destryoed_tiles is the list of LetterTiles that should be excluded for the current combat, and
## will be added back into circulation at the start of the next combat.
var destroyed_tiles = GeneralManager.destroyed_tiles

## vaporized_tiles is the list of LetterTiles that will be removed from current_deck at the end of this combat.
var vaporized_tiles = GeneralManager.vaporized_tiles

## current_relics is the list of Relics that the player currently has.
var current_relics = GeneralManager.current_relics

## modified_wordlist is the list of words that has been added to by various Relics.
var modified_wordlist := []

## scored_letter_count is the sum total of the numbers that have been scored.
var scored_tile_count = GeneralManager.scored_letter_count

## played_words_count is the sum total of the number of words that have been played.
var played_words_count = GeneralManager.played_words_count

## current_character is the player's character; this should NEVER be unloaded once instantiated.
var current_character = GeneralManager.current_character

## current_target is the last GameEntity that the player has clicked on for targeting.
var current_target := GeneralManager.current_target

## who_has_initiative is the GameEntity that currently has the initiative.
var who_has_initiative := GeneralManager.who_has_initiative

## point_values determines the number of points that a letter scores for.
var point_values  	:= GeneralManager.point_values

## mult_values determines the multiplier on the score based on the length of a word.
var mult_values		:= GeneralManager.mult_values

## word_list starts as an empty dictionary but is populated at startup with the contents of a wordlist file.
var word_list = GeneralManager.word_list

## relic_dictionary is a list of every relic in the game.
var relic_dictionary = RelicDictionary.RelicList

## tile_rng is the RandomNumberGenerator for tiles. This should be consistent if the seed is the same.
var tile_rng = RandomnessManager.tile_rng

## letters_from_tiles is a list of letters pulled from the GridTiles in tiles_in_word
var letters_from_tiles := PackedStringArray([])

## word is the string that contains the word that we look up in the word lists.
var word := ""

## possible_grid_positions lists all valid grid positions.
## If you're modding the game and you're seeing this, you're going to want to either increase the number of indeces here
## or rewrite the handling of this entirely. I did NOT want to make an item that increases the grid size, because
## it would completely fuck up the UI. You have been warned!!!
var possible_grid_positions := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

## bag_open determines if the Tile Bag is open or not.
var bag_open := false

## scoring_check determines if a word is currently being played. It prevents you from adding letters to a word while it's being played.
var scoring_check := false

## sticky_target is the Enemy whose tiles are currently shown in the enemy attack list
var sticky_target = null

@export var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")
var relic_scene = preload("res://RELIC/Relic.tscn")

## enemy_attack_container is the HBox container that contains the GridTiles that compose an enemy's attack.
@export var enemy_attack_container: PackedScene = preload("res://h_box_container.tscn")

## racked_tiles is the parent of all the tiles in the rack. We use the grid_index of a GridTile to recognize which child it is.
@export var racked_tiles: Node2D

## tiles_in_word is the parent of all the tiles currently being used to make a word. We do this because enemy tiles will also be spawned
## but they will never be part of the player's tile rack.
@export var tiles_in_word: Node2D

## tiles_to_kill is the parent of all tiles about to be destroyed, such as when words are played.
@export var tiles_to_kill: Node2D

## relics_collection is the parent of all relic nodes. Parent your relics to this.
@export var relics_collection: Node2D

## combatants is the parent of all GameEntity scenes. Parent characters and enemies to this.
@export var combatants: Node2D

## attack_list is the VBoxContainer that contains all of an enemy's attacks. It loads the attacks of the current target.
@export var attack_list: VBoxContainer

signal update_bag_tiles()
signal update_buffered_tiles()
signal disable_tile_bag(state)
signal enemy_attack_finished()
signal tile_tooltip_requested(which)
signal tile_tooltip_hide_requested()

func _ready():
	who_has_initiative = %TestCharacter
	current_character = %TestCharacter.get_path()
	%TestCharacter.on_turn_start()
	%TestCharacter.target_query()
	
	%TestCharacter.update_buffered_tiles.connect(self._update_buffered_tiles_call)
	
	%TestEnemy.perform_attack.connect(self._spawn_new_enemy_word)
	%TestEnemy.pass_turn.connect(self._pass_turn)
	
	%TestCharacter.entity_clicked.connect(self._on_entity_clicked)
	%TestEnemy.entity_clicked.connect(self._on_entity_clicked)
	
	self.enemy_attack_finished.connect(%TestEnemy._perform_next_attack)
	
	%TestCharacter.update_tile_graphics.connect(self._update_tile_graphics)
	%TestEnemy.update_tooltip_tile_graphics.connect(self._update_tooltip_tile_graphics)
	
	_check_turn_status()
	tile_tooltip_hide_requested.emit()


func _update_buffered_tiles_call():
	update_buffered_tiles.emit()

func _spawn_new_player_tile(grid_index: int):
	## added_tile is a GridTile with the data from a LetterTile
	var added_tile = grid_tile_scene.instantiate()
	
	## called_tile is a LetterTile
	var called_tile = available_tiles.pop_at(tile_rng.randi() % available_tiles.size())
	
	# Add the LetterTile to the GridTile so it has data
	added_tile.tile = called_tile
	
	# Append the called_tile to the tiles_in_play array, add the added_tile to the tile_grid
	tiles_in_play.append(called_tile)
	racked_tiles.add_child(added_tile)
	
	added_tile.spawned_in()
	
	# Give it a grid index,
	added_tile.tile.grid_index = grid_index
	added_tile.scale = Vector2(2, 2)
	added_tile.set_name(str("GridTile" + str(added_tile.tile.grid_index)))
	added_tile.tile_clicked.connect(self._on_tile_clicked)
	added_tile.tile_hovered.connect(self._is_tile_hovered)
	
	if added_tile.tile.notch1 == LetterTile.NotchTypes.ECHOING:
		added_tile.tile.echo1 = true
	if added_tile.tile.notch2 == LetterTile.NotchTypes.ECHOING:
		added_tile.tile.echo2 = true
	if added_tile.tile.notch3 == LetterTile.NotchTypes.ECHOING:
		added_tile.tile.echo3 = true
	
	
	# Set the tile's drop position as well as the target position after dropping
	# We use modulo of 4 to determine the column, and the floor of dividing by four to determine the row. This should be foolproof.
	added_tile.position = Vector2((((added_tile.tile.grid_index % 4 ) * 64.0) + 528.0), 288.0)
	added_tile.tile.target = Vector2((((added_tile.tile.grid_index % 4) * 64.0) + 528.0),((floor(added_tile.tile.grid_index / 4) * 64.0) + 376.0))
	# Based on the index, we tell it what column to drop from, and it spawns above.
	
	added_tile.spawned_in()
	await added_tile.move_to_position()
	added_tile.play_tile_sound()
	update_bag_tiles.emit()

func _spawn_new_enemy_word(attack_to_perform, attack_letter_tiles, _pivot_position, target):
	
	var enemy_letters = []
	var tile_score 		= 0
	var mult_score 		= 0
	var points_score 	= 0
	var total_score 	= 0
	
	for i in attack_to_perform.size():
		if attack_letter_tiles[i].type == LetterTile.TileType.LOCKED:
			continue
		
		var added_tile = grid_tile_scene.instantiate()
		added_tile.tile = attack_letter_tiles[i]
		added_tile.scale = Vector2(2, 2)
		added_tile.tile.is_friendly = false
		
		tiles_in_word.add_child(added_tile)
		enemy_letters.append(added_tile)
		added_tile.spawned_in()
		added_tile.position = %TestEnemy.position + %TestEnemy.pivot_offset
		
		if tiles_in_word.get_child_count() == 1:
			added_tile.tile.target = Vector2(624.0, 160.0)
			
		else:
			added_tile.tile.target = Vector2(tiles_in_word.get_child(0).tile.target.x + (76.0 * float(i)), 160.0)
		
		await added_tile.move_to_position()
		
		added_tile.play_tile_sound()
		_tiles_in_word_update()
		await get_tree().create_timer(0.04).timeout
	
	await get_tree().create_timer(0.4).timeout
	
	for i in tiles_in_word.get_child_count():
		tile_score = enemy_letters[i].score_tile()
		points_score += tile_score
		mult_score = mult_values[i]
		total_score = points_score * mult_score
		get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
		await get_tree().create_timer(0.075).timeout
	
	if target == Character:
		var damage = total_score
		%TestCharacter.take_damage(damage)
	else:
		%TestEnemy.gain_block(total_score)
	
	await get_tree().create_timer(1.25).timeout
	
	for i in tiles_in_word.get_child_count():
		tiles_in_word.get_child(-1).tile.target = %TestEnemy.position + %TestEnemy.pivot_offset
		tiles_in_word.get_child(-1).move_to_position()
		tiles_in_word.get_child(-1).is_dying()
		tiles_in_word.get_child(-1).reparent(tiles_to_kill)
		await get_tree().create_timer(0.04).timeout
	
	_cleanup_killed_tiles()
	enemy_attack_finished.emit()

func _tiles_in_word_update():
	letters_from_tiles = []
	var scaling_factor = float(7.0 / (tiles_in_word.get_child_count()+1))
	for i in tiles_in_word.get_child_count():
		
		letters_from_tiles.append(str(tiles_in_word.get_child(i).tile.TileLetter.keys()[tiles_in_word.get_child(i).tile.letter]).to_snake_case())
				
		# Add any of the extra letters a tile may have to the word.
		if not tiles_in_word.get_child(i).tile.bonus_letter1 == "":
			letters_from_tiles.append(str(tiles_in_word.get_child(i).tile.bonus_letter1))
		if not tiles_in_word.get_child(i).tile.bonus_letter2 == "":
			letters_from_tiles.append(str(tiles_in_word.get_child(i).tile.bonus_letter2))
		if not tiles_in_word.get_child(i).tile.bonus_letter3 == "":
			letters_from_tiles.append(str(tiles_in_word.get_child(i).tile.bonus_letter3))
		
		if tiles_in_word.get_child_count() <= 6:
			
			scaling_factor = 1
			tiles_in_word.get_child(0).tile.target = Vector2(624.0 - (38.0 * float(tiles_in_word.get_child_count()-1)), 160.0)
			tiles_in_word.get_child(i).tile.target = Vector2(tiles_in_word.get_child(0).tile.target.x + (76.0 * float(i)), 160.0)
			tiles_in_word.get_child(i).scale_to_word_size(scaling_factor)
			tiles_in_word.get_child(i).move_to_position(0.35)
			
		if tiles_in_word.get_child_count() > 6:
			
			tiles_in_word.get_child(0).tile.target = Vector2(624.0 - (38.0 * float(tiles_in_word.get_child_count()-1))*scaling_factor, 160.0)
			tiles_in_word.get_child(i).tile.target = Vector2(tiles_in_word.get_child(0).tile.target.x + (76.0 * float(i))*scaling_factor, 160.0)
			tiles_in_word.get_child(i).scale_to_word_size(scaling_factor)
			tiles_in_word.get_child(i).move_to_position(0.35)
	
	print(letters_from_tiles)
	
	if %TestCharacter.current_energy > 0:
		_word_from_tiles(letters_from_tiles)

func _tiles_in_word_cascade_clear(grid_tile: GridTile):
	var tile_clicked = grid_tile.get_index()
	var total_tiles = tiles_in_word.get_child_count()
	var difference = total_tiles - tile_clicked
	for i in difference:
		await _send_back_to_grid(tiles_in_word.get_child(-1))
		tiles_in_word.get_child(-1).reparent(racked_tiles)
		_tiles_in_word_update()
		await get_tree().create_timer(0.004).timeout
	_normalize_grid_tile_size()
		
func _tiles_in_word_force_clear():
	for i in tiles_in_word.get_child_count():
		await _send_back_to_grid(tiles_in_word.get_child(-1))
		tiles_in_word.get_child(-1).reparent(racked_tiles)
		_tiles_in_word_update()
		await get_tree().create_timer(0.004).timeout
	return true

func _send_back_to_grid(grid_tile: GridTile):
	grid_tile.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 64.0) + 528.0),((floor(grid_tile.tile.grid_index / 4) * 64.0) + 376.0))
	grid_tile.move_to_position(0.35)
	grid_tile.scale_back_to_grid()
	_normalize_grid_tile_size()
	return true
	
func _on_tile_clicked(which: GridTile, action: GridTile.GridTileAction):
	if scoring_check == false and bag_open == false and %TestCharacter.has_initiative == true \
	and which.tile.is_friendly and not which.tile.type == LetterTile.TileType.LOCKED:
		if action == GridTile.GridTileAction.PLAY:
			
			if which.get_parent() == racked_tiles:
				which.reparent(tiles_in_word, true)
				_tiles_in_word_update()
			
			elif which.get_parent() == tiles_in_word:
				which.reparent(racked_tiles, true)
				_send_back_to_grid(which)
				_tiles_in_word_update()

		if action == GridTile.GridTileAction.VIEW:
		
			if which.get_parent() == racked_tiles:
				pass
				
			elif which.get_parent() == tiles_in_word:
				_tiles_in_word_cascade_clear(which)
				
	else:
		pass
		
func _word_from_tiles(letters_from_tiles):
	word = "".join(letters_from_tiles)
	print(word)
	if word.length() >= 3 and current_target is GameEntity:
		
		var is_word = word_list.get(word)
		if is_word:
			get_node("WordLabel").text = str(word.to_upper() + " is a valid word!")
			get_node("PlayButton").set_disabled(false)
			
		elif not is_word:
			get_node("WordLabel").text = ""
			get_node("PlayButton").set_disabled(true)
			
	else:
		get_node("WordLabel").text = ""
		get_node("PlayButton").set_disabled(true)
			
		#if modified_wordlist.has(word):
			#
			#get_node("WordLabel").text = str(word.to_upper() + " is a valid word!")
			#get_node("PlayButton").set_disabled(false)
			#
		#else:
			#var list = FileAccess.open(filePath + word[0] + word[1] + ".txt", FileAccess.READ)
			#while list.get_position() < list.get_length():
				#var line = list.get_line()
				#
				#if not line == word:
					#get_node("WordLabel").text = ""
					#get_node("PlayButton").set_disabled(true)
				#
				#if line == word:
					#get_node("WordLabel").text = str(word.to_upper() + " is a valid word!")
					#get_node("PlayButton").set_disabled(false)
					#list.close()

	
	#if not %PlayButton.is_disabled():
		#var raw_word_score = _calc_raw_word_score()
		#prompt_score_callout.emit(raw_word_score)

func _on_play_button_pressed():
	if %TestCharacter.has_initiative and %TestCharacter.current_energy > 0:
		_score_word()
	else:
		await _tiles_in_word_force_clear()
		_pass_turn()
		
func _score_word():
	scoring_check = true
	get_node("PlayButton").set_disabled(true)
	played_words_count += 1
	var points_score = 0
	var mult_score = 0
	var tile_score = 0
	var total_score = 0
	var word_retriggers = 0
	var tile_retriggers = 0
	
	# If there are any effects that would retrigger the scoring of the word, they'll be processed here.
	# If there's any special effects, they should also be processed here.
	for i in current_relics.size():
		word_retriggers += current_relics[i].word_retrigger_effect(word)
	
	for i in word_retriggers + 1:
		
		for j in tiles_in_word.get_child_count():
			
			var scored_tile = tiles_in_word.get_child(j)
			
			for k in current_relics.size():
				
				# Pull any letter retrigger effects from relics
				tile_retriggers += current_relics[k].letter_retrigger_effect(scored_tile.tile.letter, word)
			
				# Query for if a tile has bonus letters from anything
				if not scored_tile.tile.bonus_letter1 == "":
					tile_retriggers += current_relics[k].letter_retrigger_effect(scored_tile.tile.bonus_letter1, word)
				if not scored_tile.tile.bonus_letter2 == "":
					tile_retriggers += current_relics[k].letter_retrigger_effect(scored_tile.tile.bonus_letter2, word)
				if not scored_tile.tile.bonus_letter3 == "":
					tile_retriggers += current_relics[k].letter_retrigger_effect(scored_tile.tile.bonus_letter3, word)
					
			# Query for Repeating notches
			if scored_tile.tile.notch1 == LetterTile.NotchTypes.REPEATING:
				print("Repeating of course! 1")
				tile_retriggers += 1
			if scored_tile.tile.notch2 == LetterTile.NotchTypes.REPEATING:
				print("Repeating of course! 2")
				tile_retriggers += 1
			if scored_tile.tile.notch3 == LetterTile.NotchTypes.REPEATING:
				print("Repeating of course! 3")
				tile_retriggers += 1
			
			# Score each letter for a number of times equal to their retriggers, plus one.
			for k in tile_retriggers + 1:
				
				# Score the actual letter and get the score, plus increment the scored letter count.
				tile_score +=  await scored_tile.score_tile()
				scored_tile_count += 1
				
				%TileScoreLabel.text = str(tile_score)
				# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
				
				await get_tree().create_timer(0.0025).timeout
				
				# TODO: Put Notch-based effects here? Or maybe they belong inside the tile scoring. I don't know.
				
				# Pull any bonus point effects from relics.
				for l in current_relics.size():
					
					# Grid index based effects
					tile_score += current_relics[l].grid_index_effect(scored_tile.tile.grid_index, word)
					%TileScoreLabel.text = str(tile_score)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Letter based effects
					tile_score += current_relics[l].letter_score_effect(scored_tile.tile.letter, word)
					%TileScoreLabel.text = str(tile_score)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Word based effects that trigger on each letter of a word
					tile_score += current_relics[l].word_letter_bonus_score_effect(word)
					%TileScoreLabel.text = str(tile_score)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Effects based on the total count of scored tiles
					tile_score += current_relics[l].x_letters_played_effect(scored_tile_count, tile_score, word)
					%TileScoreLabel.text = str(tile_score)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
				# If a tile has Phantom, then add two dumb clones of it to the available tiles list.
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.PHANTOM:
					print("Going ghost... 1")
					for l in 2:
						# Clone the tile, add it to the available tiles list.
						var cloned_tile = scored_tile.tile
						var new_clone = LetterTile.new().new_tile(cloned_tile.type, cloned_tile.letter, cloned_tile.notch1, cloned_tile.notch2, cloned_tile.notch3, -1)
						new_clone.type = LetterTile.TileType.CRUMBLING
						new_clone.notch1 = LetterTile.NotchTypes.EMPTY
						new_clone.is_temporary = true
						new_clone.tile_index = current_combat_deck.size()
						
						if new_clone.notch2 == LetterTile.NotchTypes.INERT or new_clone.notch2 == LetterTile.NotchTypes.ECHOING:
							new_clone.notch2 = LetterTile.NotchTypes.EMPTY
						if new_clone.notch3 == LetterTile.NotchTypes.INERT or new_clone.notch3 == LetterTile.NotchTypes.ECHOING:
							new_clone.notch3 = LetterTile.NotchTypes.EMPTY
						
						current_combat_deck.append(new_clone)
						available_tiles.append(new_clone)
				
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.PHANTOM:
					print("Going ghost... 2")
					for l in 2:
						# Clone the tile, add it to the available tiles list.
						var cloned_tile = scored_tile.tile
						var new_clone = LetterTile.new().new_tile(cloned_tile.type, cloned_tile.letter, cloned_tile.notch1, cloned_tile.notch2, cloned_tile.notch3, -1)
						new_clone.type = LetterTile.TileType.CRUMBLING
						new_clone.notch2 = LetterTile.NotchTypes.EMPTY
						new_clone.is_temporary = true
						new_clone.tile_index = current_combat_deck.size()
						
						if new_clone.notch1 == LetterTile.NotchTypes.INERT or new_clone.notch1 == LetterTile.NotchTypes.ECHOING:
							new_clone.notch1 = LetterTile.NotchTypes.EMPTY
						if new_clone.notch3 == LetterTile.NotchTypes.INERT or new_clone.notch3 == LetterTile.NotchTypes.ECHOING:
							new_clone.notch3 = LetterTile.NotchTypes.EMPTY
						
						current_combat_deck.append(new_clone)
						available_tiles.append(new_clone)
		
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.PHANTOM:
					print("Going ghost... 3")
					for l in 2:
						# Clone the tile, add it to the available tiles list.
						var cloned_tile = scored_tile.tile
						var new_clone = LetterTile.new().new_tile(cloned_tile.type, cloned_tile.letter, cloned_tile.notch1, cloned_tile.notch2, cloned_tile.notch3, -1)
						new_clone.type = LetterTile.TileType.CRUMBLING
						new_clone.notch3 = LetterTile.NotchTypes.EMPTY
						new_clone.is_temporary = true
						new_clone.tile_index = current_combat_deck.size()
						
						if new_clone.notch1 == LetterTile.NotchTypes.INERT or new_clone.notch1 == LetterTile.NotchTypes.ECHOING:
							new_clone.notch1 = LetterTile.NotchTypes.EMPTY
						if new_clone.notch2 == LetterTile.NotchTypes.INERT or new_clone.notch2 == LetterTile.NotchTypes.ECHOING:
							new_clone.notch2 = LetterTile.NotchTypes.EMPTY
						
						current_combat_deck.append(new_clone)
						available_tiles.append(new_clone)
						
				# If a tile has Reinforced, apply 5 block to the player.
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REINFORCED:
					%TestCharacter.gain_block(5)
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.REINFORCED:
					%TestCharacter.gain_block(5)
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.REINFORCED:
					%TestCharacter.gain_block(5)
				
				# If a tile has Rejuvenating, heal the player for 3.
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal1 == false:
					%TestCharacter.gain_health(3)
					scored_tile.tile.heal1 = true
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal2 == false:
					%TestCharacter.gain_health(3)
					scored_tile.tile.heal2 = true
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal3 == false:
					%TestCharacter.gain_health(3)
					scored_tile.tile.heal3 = true
				
				# If a tile has Flaming, don't do anything yet.
				
			
			points_score += tile_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
			# We're done scoring that letter, so we need to zero the letter score and prep for the next letter.
			tile_score = 0
			tile_retriggers = 0
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
	for i in tiles_in_word.get_child_count():
		var tile_to_process = tiles_in_word.get_child(-1)
		
		# Echoing overrides destructive effects.
		if tile_to_process.tile.notch1 == LetterTile.NotchTypes.ECHOING \
		and tile_to_process.tile.echo1 == true:
			print("Echo! Echo... echo... 1")
			tile_to_process.tile.echo1 = false
			tile_to_process.tile.echoed_this_word = true
			tile_to_process.reparent(racked_tiles)
			_send_back_to_grid(tile_to_process)
		
		elif tile_to_process.tile.notch2 == LetterTile.NotchTypes.ECHOING \
		and tile_to_process.tile.echo2 == true:
			print("Echo! Echo... echo... 2")
			tile_to_process.tile.echo2 = false
			tile_to_process.tile.echoed_this_word = true
			tile_to_process.reparent(racked_tiles)
			_send_back_to_grid(tile_to_process)
			
		elif tile_to_process.tile.notch3 == LetterTile.NotchTypes.ECHOING \
		and tile_to_process.tile.echo3 == true:
			print("Echo! Echo... echo... 3")
			tile_to_process.tile.echo3 = false
			tile_to_process.tile.echoed_this_word = true
			tile_to_process.reparent(racked_tiles)
			_send_back_to_grid(tile_to_process)
		
		# Vaporization.
		elif tile_to_process.tile.notch1 == LetterTile.NotchTypes.VAPORIZING \
		or tile_to_process.tile.notch2 == LetterTile.NotchTypes.VAPORIZING \
		or tile_to_process.tile.notch3 == LetterTile.NotchTypes.VAPORIZING:
			print("Vaporizing...")
			vaporized_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(tiles_to_kill)
			#current_deck.remove_at(tile_to_process.tile.tile_index) # TODO: Figure out how to do this correctly.
			tiles_in_play.remove_at(i)
			tile_to_process.is_dying() # TODO: Replace with unique effect.
		
		# Deletion of temps.
		elif tile_to_process.tile.is_temporary:
			print("Scab!!!")
			vaporized_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(tiles_to_kill)
			tiles_in_play.remove_at(i)
			tile_to_process.is_dying() # TODO: Replace with unique effect.
		
		# Crumbling.
		elif tile_to_process.tile.type == LetterTile.TileType.CRUMBLING:
			print("Crumbling!")
			destroyed_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.reparent(tiles_to_kill)
			tiles_in_play.remove_at(i)
			tile_to_process.is_dying() # TODO: Replace with unique effect.
		
		else:
			tile_to_process.reparent(tiles_to_kill)
			tiles_in_play.remove_at(i)
	
	_cleanup(total_score)
	
func _cleanup(total_score):
	# Make the bag look pretty just before the tiles go into it.
	disable_tile_bag.emit(true)
	for i in tiles_to_kill.get_child_count():
		var last_letter = tiles_to_kill.get_child(i)
		
		# This is bad implementation, and might be the source of a bug.
		if last_letter.tile.notch1 == LetterTile.NotchTypes.WEIGHTED \
		or last_letter.tile.notch2 == LetterTile.NotchTypes.WEIGHTED \
		or last_letter.tile.notch2 == LetterTile.NotchTypes.WEIGHTED:
			if last_letter.tile.echo1 == false \
			and last_letter.tile.echo2 == false \
			and last_letter.tile.echo3 == false \
			and last_letter.tile.no_buffer == false \
			and last_letter.tile.vaporized == false:
				available_tiles.append(last_letter.tile)
				last_letter.z_index = 120
				last_letter.is_dying()
				last_letter.tile.target = Vector2(1184.0, 64.0)
				last_letter.move_to_position(0.35)
				await get_tree().create_timer(0.04).timeout
		
		elif last_letter.tile.no_buffer == false and last_letter.tile.vaporized == false:
			buffered_tiles.append(last_letter.tile)
			last_letter.z_index = 120
			last_letter.is_dying()
			last_letter.tile.target = Vector2(1184.0, 64.0)
			last_letter.move_to_position(0.35)
			await get_tree().create_timer(0.04).timeout
		
		else:
			pass

	_cleanup_killed_tiles()
	
	update_bag_tiles.emit()
	letters_from_tiles.clear()
	_word_from_tiles(letters_from_tiles)
	_move_tiles_into_place()
	_apply_score_to_target(total_score)
	%TestCharacter.remove_energy(1)
	_check_turn_status()
	print(%TestCharacter.current_energy)
	disable_tile_bag.emit(false)
	
func _move_tiles_into_place():
	disable_tile_bag.emit(true)
	var remaining_tiles = []
	tiles_in_play.clear()
	for i in racked_tiles.get_child_count():
		remaining_tiles.append(racked_tiles.get_child(i).tile.grid_index)
		tiles_in_play.append(racked_tiles.get_child(i).tile)
		racked_tiles.get_child(i).tile.echoed_this_word = false
		
	
	remaining_tiles.sort()
	remaining_tiles.reverse()
	print(remaining_tiles)
	
	#!# Borrowed from https://forum.godotengine.org/t/how-can-i-sort-the-children-of-a-node/1409/2
	var sorted_nodes := racked_tiles.get_children()

	sorted_nodes.sort_custom(
		# For descending order use > 0
		func(a: Node, b: Node): return a.name.naturalnocasecmp_to(b.name) > 0
		)

	for node in racked_tiles.get_children():
		racked_tiles.remove_child(node)

	for node in sorted_nodes:
		racked_tiles.add_child(node)
	#!#

	for i in racked_tiles.get_child_count():
		var found_tile = racked_tiles.get_child(i)
		if found_tile.tile.grid_index < 12:
			if found_tile.tile.grid_index < 4 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 64.0) + 528.0),((floor(found_tile.tile.grid_index / 4) * 64.0) + 376.0))
				remaining_tiles[i] += 4
				
			if found_tile.tile.grid_index < 8 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 64.0) + 528.0),((floor(found_tile.tile.grid_index / 4) * 64.0) + 376.0))
				remaining_tiles[i] += 4

			if found_tile.tile.grid_index < 12 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 64.0) + 528.0),((floor(found_tile.tile.grid_index / 4) * 64.0) + 376.0))
				remaining_tiles[i] += 4
				
			else:
				pass
		await get_tree().create_timer(0.01).timeout
		found_tile.move_to_position()
	await get_tree().create_timer(0.01).timeout
		
	_spawn_replacement_tiles(remaining_tiles)
	disable_tile_bag.emit(false)
	
func _spawn_replacement_tiles(remaining_tiles):
	var tiles_to_fill = []
	
	for i in possible_grid_positions.size():
		if not remaining_tiles.has(possible_grid_positions[i]):
			tiles_to_fill.append(possible_grid_positions[i])
	
	tiles_to_fill.reverse()
	
	for i in (16 - racked_tiles.get_child_count()):
		var grid_index = tiles_to_fill[i]
		_spawn_new_player_tile(grid_index)
		await get_tree().create_timer(0.04).timeout
		
	_rename_tiles()
	_check_turn_status()
	_tiles_in_word_update()
	update_bag_tiles.emit()
	scoring_check = false

func _rename_tiles():
	for i in racked_tiles.get_child_count():
		var temp_name = str("GridTile" + str(randi_range(100, 200)))
		racked_tiles.get_child(i).set_name(temp_name)

	await get_tree().create_timer(0.04).timeout
	
	for i in racked_tiles.get_child_count():
		if not racked_tiles.get_child(i).name == str("GridTile"+str(racked_tiles.get_child(i).tile.grid_index)):
			racked_tiles.get_child(i).set_name(str("GridTile"+str(racked_tiles.get_child(i).tile.grid_index)))
			
func _calc_raw_word_score():
	var letter_score = 0
	var mult_score = 0
	var raw_word_score = 0
	for i in tiles_in_word.get_child_count():
		letter_score += tiles_in_word.get_child(i).score_tile_quiet()
		mult_score = mult_values[i]
		raw_word_score = letter_score * mult_score
	return raw_word_score

func _check_turn_status():
	if %TestCharacter.is_target == false and %TestEnemy.is_target == false:
		%PlayButton.texture_normal.region 	= Rect2(0.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 80.0, 128.0, 40.0)
	
	elif %TestCharacter.current_energy <= 0 and %TestCharacter.has_initiative:
		%PlayButton.texture_normal.region 	= Rect2(0.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 40.0, 128.0, 40.0)
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(false)
	
	elif not %TestCharacter.has_initiative:
		%PlayButton.texture_normal.region 	= Rect2(0.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 40.0, 128.0, 40.0)
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(true)
		
	else: 
		%PlayButton.texture_normal.region 	= Rect2(0.0, 0.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 0.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 0.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(256.0, 0.0, 128.0, 40.0)
		if %TestCharacter.has_initiative:
			%ShuffleButton.set_disabled(false)

		_tiles_in_word_update()

func _pass_turn():
	
	_check_turn_status()
	
	if who_has_initiative is Character:
		for i in current_relics.size():
			current_relics[i].on_turn_end()
	
	# Perform end of turn procedures for whoever has the initiative:
	who_has_initiative.on_turn_end()
	
	# Which GameEntity in the current combat has the initiative to take their turn?
	var entity_number = who_has_initiative.get_index()

	# Since we're passing the turn, we take that away from them
	who_has_initiative.has_initiative = false
	who_has_initiative = null

	if entity_number + 1 < combatants.get_child_count():
		# And give it to the sibling directly beneath them in the list.
		combatants.get_child(entity_number + 1).has_initiative = true
		who_has_initiative = combatants.get_child(entity_number + 1)
		
	# If they're at the bottom, we wrap around back to the top.
	else:
		combatants.get_child(0).has_initiative = true
		who_has_initiative = combatants.get_child(0)
	
	who_has_initiative.on_turn_start()
	
	if who_has_initiative is Character:
		for i in current_relics.size():
			current_relics[i].on_turn_start()
	
	_check_turn_status()
	
func _on_entity_clicked(which: GameEntity, action: GameEntity.GameEntityAction) -> void:
	print(current_target)
	for child in combatants.get_children():
		if child is TestCharacter or child is TestEnemy:
			child.is_target = false

	which.is_target = true

	for child in combatants.get_children():
		if child is TestCharacter or child is TestEnemy:
			child.target_query()
	
	if which is Enemy:
		for i in attack_list.get_child_count():
			attack_list.get_child(i).queue_free()
	
		attack_list.add_spacer(true)
		
		for i in which.enemy_attack_list.size():
			sticky_target = which
			var new_attack = enemy_attack_container.instantiate()
			attack_list.add_child(new_attack)
			for j in which.enemy_attack_list[i].size():
				var current_attack = which.enemy_attack_list[i]
				var new_tile = grid_tile_scene.instantiate()
				new_tile.tile = which.current_enemy_deck[current_attack[j]]
				new_tile.tile_hovered.connect(self._is_tile_hovered)
				new_attack.add_child(new_tile)

	current_target = which
	print(current_target.name)
	_check_turn_status()
	
func _update_tile_graphics(affected_tile_indices):
	print("Updating Tile Graphics!")
	for i in racked_tiles.get_child_count():
		if affected_tile_indices.has(racked_tiles.get_child(i).tile.tile_index):
			racked_tiles.get_child(i).update_tile_graphics()
		
func _update_tooltip_tile_graphics(affected_tile_indices):
	print("Updating Tooltip Tile Graphics!")
	for i in attack_list.get_child_count():
		if i > 0:
			var attack_list_child = attack_list.get_child(i)
			for j in attack_list_child.get_child_count():
				if affected_tile_indices.has(attack_list_child.get_child(j).tile.tile_index):
					attack_list_child.get_child(j).update_tile_graphics()
	
func _apply_score_to_target(total_score):
	print("Apply Score to Target: " + str(total_score))
	for child in combatants.get_children():
		if child is TestCharacter and child.is_target:
			child.gain_block(total_score)
			
		if child is TestEnemy and child.is_target:
			child.take_damage(total_score)

func _normalize_grid_tile_size():
	for i in racked_tiles.get_child_count():
		racked_tiles.get_child(i).scale_back_to_grid()

### Buttons and stuff below here!
func _on_test_button_pressed():
	get_node("TestButton").set_disabled(true)
	
	for i in range(0, 16):
		var grid_index = 15 - i
		_spawn_new_player_tile(grid_index)
		await get_tree().create_timer(0.04).timeout
	
	%TestCharacter.add_status("PLAGUED", 1, true, 3)
	%TestEnemy.add_status("PLAGUED", 1, true, 3)
	%TestCharacter.add_status("STONED", 1, true, 3)
	%TestEnemy.add_status("STONED", 1, true, 3)
	%TestCharacter.add_status("LOCKED", 1, true, 3)
	%TestEnemy.add_status("LOCKED", 1, true, 3)
	
	get_node("TestButton").set_disabled(false)
	
func _on_relic_button_pressed():
	get_node("RelicButton").set_disabled(true)
	print("Giving you an Upper Case!")
	var new_relic = relic_dictionary.get("1")
	var new_relic_2 = relic_dictionary.get("3")
	var relic_node = relic_scene.instantiate()
	var relic_node_2 = relic_scene.instantiate()
	
	relic_node.set_script(new_relic)
	relic_node_2.set_script(new_relic_2)
	
	relic_node.scale = Vector2(2,2)
	relic_node.position = Vector2((32 + (64 * current_relics.size())), 32)
	current_relics.append(relic_node)
	relics_collection.add_child(relic_node)
	
	relic_node_2.scale = Vector2(2,2)
	relic_node_2.position = Vector2((32 + (64 * current_relics.size())), 32)
	current_relics.append(relic_node_2)
	relics_collection.add_child(relic_node_2)
	
	get_node("RelicButton").set_disabled(false)

func _on_shuffle_button_pressed():
	if %TestCharacter.current_energy > -99999:
		#%TestCharacter.remove_energy(3)
		update_buffered_tiles.emit()
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(true)
		get_node("ScoreLabel").text = ""
		tiles_in_play.clear()
		letters_from_tiles.clear()
		
		
		for i in tiles_in_word.get_child_count():
			var tile_to_push = tiles_in_word.get_child(-1)
		
			tile_to_push.reparent(tiles_to_kill)
		
			## tile_to_push_array is a list of tiles to push
			var tile_to_push_array = []
		
			## buffered_tiles is a list of the LetterTiles that are in the buffer area between played words and turns.
			if tiles_in_play.has(tile_to_push.tile):
				buffered_tiles.append(tile_to_push.tile)
			tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 64.0) + 528.0), 642.0)
			tile_to_push_array.append(tile_to_push)
			tile_to_push.is_dying()
			tile_to_push.move_to_position()
		
		for i in racked_tiles.get_child_count():
			## tile_to_push is a GridTile that will be deleted.
			var tile_to_push = racked_tiles.get_child(-1)
		
			tile_to_push.reparent(tiles_to_kill)
		
			## tile_to_push_array is a list of tiles to push
			var tile_to_push_array = []
		
			if tile_to_push.tile.no_buffer == false:
				buffered_tiles.append(tile_to_push.tile)
				
			tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 64.0) + 528.0), 642.0)
			tile_to_push_array.append(tile_to_push)
			tile_to_push.is_dying()
			tile_to_push.move_to_position()
		
		_cleanup_killed_tiles()
		
		await get_tree().create_timer(0.125).timeout
		
		for i in range(0, 16):
			var grid_index = 15 - i
			_spawn_new_player_tile(grid_index)
			update_bag_tiles.emit()
			await get_tree().create_timer(0.04).timeout

		%ShuffleButton.set_disabled(false)
		_check_turn_status()
		
	else:
		pass

func _on_tile_bag_toggle(toggled_on):
	bag_open = toggled_on
	if toggled_on:
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(true)
	if not toggled_on:
		%ShuffleButton.set_disabled(false)
		if %TestCharacter.current_energy > 0:
			_word_from_tiles(letters_from_tiles)
		elif %TestCharacter.current_energy <= 0 and %TestCharacter.has_initiative:
			%PlayButton.set_disabled(false)
		elif %TestCharacter.current_energy <= 0 and not %TestCharacter.has_initiative:
			%PlayButton.set_disabled(true)
			
func _is_tile_hovered(which: GridTile, is_hovering: bool):
	
	### scaling_factor determines the visaul size of tiles in certain contexts.
	#var scaling_factor = float(7.0 / (tiles_in_word.get_child_count()+1))
	#
	#if tiles_in_word.get_children().has(which) && tiles_in_word.get_child_count() <= 7 && is_hovering == false:
		#which.scale = Vector2(1, 1)
	#
	#if tiles_in_word.get_children().has(which) && tiles_in_word.get_child_count() > 7 && is_hovering == false:
		#which.scale_to_word_size(scaling_factor)
		
	if is_hovering == true:
		tile_tooltip_requested.emit(which)
	
	if is_hovering == false:
		tile_tooltip_hide_requested.emit()

func _on_update_buffered_tiles() -> void:
	update_buffered_tiles.emit()

func _cleanup_killed_tiles():
	await get_tree().create_timer(0.5).timeout
	for i in tiles_to_kill.get_child_count():
		var killed_tile = tiles_to_kill.get_child(-1)
		killed_tile.free()
