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

## priority_draw_list is the list of LetterTiles that should be drawn first.
var priority_draw_list = GeneralManager.priority_draw_list

## tiles_in_play is the list of LetterTiles currently in the rack or being used to play a word.
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

## played_words_count is the sum total of the number of words that have been played.
var played_words_count = GeneralManager.played_words_count

## current_character is the player's character; this should NEVER be unloaded once instantiated.
var character_path = GeneralManager.character_path

## current_target is the last GameEntity that the player has clicked on for targeting.
var current_target := GeneralManager.current_target

## who_has_initiative is the GameEntity that currently has the initiative.
var who_has_initiative := GeneralManager.who_has_initiative

## point_values determines the number of points that a letter scores for.
var point_values  	:= GeneralManager.point_values

## word_list starts as an empty dictionary but is populated at startup with the contents of a wordlist file.
var word_list = GeneralManager.word_list

## bonus_word_list starts as an empty dictionary but is populated over the course of a run with words not present in the main wordlist.
var bonus_word_list = GeneralManager.bonus_word_list

## tile_rng is the RandomNumberGenerator for tiles. This should be consistent if the seed is the same.
var tile_rng = RandomnessManager.tile_rng

## letters_from_tiles is a list of letters pulled from the GridTiles in tiles_in_word
var letters_from_tiles := PackedStringArray([])

## word is the string that contains the word that we look up in the word lists.
var word = GeneralManager.current_word

## true_word is a valid word stripped of its prefixes or suffixes.
var true_word = GeneralManager.true_word

## possible_grid_positions lists all valid grid positions.
## If you're modding the game and you're seeing this, you're going to want to either increase the number of indeces here
## or rewrite the handling of this entirely. I did NOT want to make an item that increases the grid size, because
## it would completely fuck up the UI. You have been warned!!!
var possible_grid_positions := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

## Don't ask.
var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

var no_delay_list = [
	LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.REPEATING,
	LetterTile.NotchTypes.WEIGHTED, LetterTile.NotchTypes.INERT,
	LetterTile.NotchTypes.EAGER, LetterTile.NotchTypes.PATIENT,
	LetterTile.NotchTypes.QUICK, LetterTile.NotchTypes.BALANCED,
	LetterTile.NotchTypes.LOCAL, LetterTile.NotchTypes.DISTANT,
	LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.LEXICAL,
	LetterTile.NotchTypes.ECHOING, LetterTile.NotchTypes.REJUVENATING
]

## bag_open determines if the Tile Bag is open or not.
var bag_open := false

var current_enemy_tooltip: Enemy = null

## sticky_target is the Enemy whose tiles are currently shown in the enemy attack list
var sticky_target = null

## This is here while I try and figure out a good way to end combat.
var end_of_combat = false

## sine_timer is the timer for the sine wave effect for the currently played tiles.
var sine_timer = 0

## player_turn_count is the number of turns that the player has started.
var player_turn_count: int = 0

## enemy_turn_count is the number of turns that the enemies have started.
var enemy_turn_count: int = 0

## allow_interaction is a flag that determines if the player can interact with tiles, game entities, etc.
var allow_interaction: bool = false

## new_encounter is a variable used to instantiate a new encounter in the combat scene.
var new_encounter

## combatant_array is the list of all combatants in the current combat.
var combatant_array = []

@export var grid_tile_scene: PackedScene = preload("res://TILE/GRID_TILE/GridTile.tscn")
@export var mini_grid_tile_scene: PackedScene = preload("res://TILE/GRID_TILE/MiniGridTile.tscn")
@export var intent_icon_scene: PackedScene = preload("res://COMBAT/GAME_ENTITY/IntentIcon.tscn")

func _ready():
	
	GameEventHandler.tile_clicked.connect(_on_tile_clicked)
	GameEventHandler.entity_clicked.connect(_on_entity_clicked)
	GameEventHandler.perform_attack.connect(_spawn_new_enemy_word)
	GameEventHandler.pass_turn.connect(_pass_turn)
	GameEventHandler.update_tile_graphics.connect(_update_tile_graphics)
	GameEventHandler.update_tile_tooltip_graphics.connect(_update_enemy_tooltip)
	GameEventHandler.entity_has_died.connect(_check_for_dead_enemies)

	# Clear all of the lists relating to tiles before starting combat, just to be safe.
	current_combat_deck.clear()
	available_tiles.clear()
	buffered_tiles.clear()
	tiles_in_play.clear()
	destroyed_tiles.clear()
	vaporized_tiles.clear()
	
	# Clone the player's deck into the current combat deck.
	# If a tile has an Eager notch, add it to the priority draw list.
	# For every other tile, add it to the available tiles list.
	for i in current_deck.size():
		current_combat_deck.append(current_deck[i])
	
		if current_deck[i].notch1 == LetterTile.NotchTypes.EAGER \
		or current_deck[i].notch2 == LetterTile.NotchTypes.EAGER \
		or current_deck[i].notch3 == LetterTile.NotchTypes.EAGER:
			priority_draw_list.append(current_deck[i])
	
		else:
			available_tiles.append(current_deck[i])
	
	# Grant the player character initiative, and then pull them into the scene.
	who_has_initiative = character_path
	character_path.has_initiative = true
	character_path.reparent(%Combatants)
	
	# Drag enemies from the instantiated encounter into the combat scene.
	new_encounter = GeneralManager.combat_encounter.instantiate()
	add_child(new_encounter)
	
	for i in %Combatants.get_child_count():
		# This section is for all combatants:
		var combatant = %Combatants.get_child(i)
		combatant_array.append(combatant)
		
		if combatant is Enemy:
			combatant.plan_next_turn()
			
	_on_combat_start()
	_check_turn_status()
	GameEventHandler.tile_tooltip_hide_requested.emit(false)
	
func _process(delta: float) -> void:
	if get_viewport().has_focus():
		var sine_tiles = get_tree().get_nodes_in_group("Tiles In Word")
		if sine_tiles.size() > 0:
			sine_timer += delta
			var phase = sine_timer * PI
			for i in sine_tiles.size():
				sine_tiles[i].position.x = float(sine_tiles[i].position.x + (0.1 * cos(phase + (0.33 * i))))
				sine_tiles[i].position.y = float(sine_tiles[i].position.y + (0.1 * sin(phase + (0.33 * i))))

func _input(event: InputEvent):
	if get_viewport().has_focus():
		#region Keyboard Inputs
		if event is InputEventKey and event.pressed:
			var input_string = OS.get_keycode_string(event.keycode).to_lower()
			
			if not event.shift_pressed or not event.alt_pressed:
				%InputLabel.text = input_string
			if event.shift_pressed:
				%InputLabel.text = str("Shift + " + input_string)
			if event.alt_pressed:
				%InputLabel.text = str("Alt + " + input_string)
			
			if event.keycode == KEY_BACKSPACE:
				for tile: GridTile in %RackedTiles.get_children():
					if tile.hovering:
						tile._on_tile_button_mouse_exited()
						if not event.shift_pressed:
							return
				
				if %TilesInWord.get_child_count() > 0:
					if event.shift_pressed:
						for tile: GridTile in %TilesInWord.get_children():
							if tile.hovering:
								tile._on_tile_button_mouse_exited()
						_tiles_in_word_force_clear()
						
					else:
						%TilesInWord.get_child(-1)._on_tile_button_mouse_exited()
						GameEventHandler.play_tile_sound.emit(%TilesInWord.get_child(-1))
						GameEventHandler.tile_clicked.emit(%TilesInWord.get_child(-1), GridTile.GridTileAction.PLAY)
						
			
			if event.keycode == KEY_SPACE:
				for tile: GridTile in %RackedTiles.get_children():
					if tile.hovering:
						tile._on_tile_button_mouse_exited()
						GameEventHandler.play_tile_sound.emit(tile)
						GameEventHandler.tile_clicked.emit(tile, GridTile.GridTileAction.PLAY)
			
			else:
				print(input_string)
				var tile_list = []
				if letters.has(input_string):
					
					for tile: GridTile in %RackedTiles.get_children():
						if tile.tile.is_playable and tile.tile.TileLetter.keys()[tile.tile.played_letter].to_lower() == input_string:
							tile_list.append(tile)
						
						elif tile.hovering:
							tile._on_tile_button_mouse_exited()
							if not event.alt_pressed:
								GameEventHandler.play_tile_sound.emit(tile)
								GameEventHandler.tile_clicked.emit(tile, GridTile.GridTileAction.PLAY)
								await get_tree().create_timer(0.05).timeout
					
					# Thanks, Iris!
					tile_list.sort_custom(func(a,b): return a.tile.grid_index < b.tile.grid_index)
					var start_index = -1
					var end_index = -1
					for tile in tile_list:
						if tile_list.size() == 1:
							for word_tile: GridTile in %TilesInWord.get_children():
								word_tile._on_tile_button_mouse_exited()
							if not event.alt_pressed:
								tile._on_tile_button_mouse_exited()
								GameEventHandler.play_tile_sound.emit(tile)
								GameEventHandler.tile_clicked.emit(tile, GridTile.GridTileAction.PLAY)
							else:
								tile._on_tile_button_mouse_entered()
						
						elif event.shift_pressed:
							tile._on_tile_button_mouse_exited()
							GameEventHandler.play_tile_sound.emit(tile)
							GameEventHandler.tile_clicked.emit(tile, GridTile.GridTileAction.PLAY)
							break
						
						else:
							end_index = tile.tile.grid_index
							if tile.hovering:
								tile._on_tile_button_mouse_exited()
								
								if event.shift_pressed:
									tile._on_tile_button_mouse_exited()
									GameEventHandler.play_tile_sound.emit(tile)
									GameEventHandler.tile_clicked.emit(tile, GridTile.GridTileAction.PLAY)
									break
									
								else:
									start_index = tile.tile.grid_index
					
					for tile in tile_list:
						if start_index < end_index and start_index < tile.tile.grid_index:
							tile._on_tile_button_mouse_entered()
							break
			_tiles_in_word_update()
			
		else:
			return
		#endregion

func _on_combat_start():
	GeneralManager.is_combat_active = true
	allow_interaction = true
	player_turn_count += 1
	character_path.on_turn_start(player_turn_count)
	character_path.target_query()
	
	for i in current_relics.size():
		current_relics[i].on_combat_start()
		current_relics[i].on_turn_start(player_turn_count)

	for i in current_combat_deck.size():
		if current_combat_deck[i].notch1 == LetterTile.NotchTypes.REJUVENATING:
			current_combat_deck[i].heal1 = false
		if current_combat_deck[i].notch2 == LetterTile.NotchTypes.REJUVENATING:
			current_combat_deck[i].heal2 = false
		if current_combat_deck[i].notch3 == LetterTile.NotchTypes.REJUVENATING:
			current_combat_deck[i].heal3 = false

	_populate_rack()
	
	await get_tree().create_timer(1).timeout
	%TurnCounterLabel.display_turn_text(player_turn_count, true)

func _populate_rack():
	for i in range(0, 16):
		var grid_index = 15 - i
		_spawn_new_player_tile(grid_index)
		await get_tree().create_timer(0.04).timeout
		
func _spawn_new_player_tile(grid_index: int):
	if available_tiles.size() > 0:
		## added_tile is a GridTile with the data from a LetterTile
		var added_tile = grid_tile_scene.instantiate()
		## called_tile is a LetterTile to be given to a GridTile.
		var called_tile = LetterTile
		
		# Pull from the priority draw list until it is empty.
		if not priority_draw_list.is_empty():
			called_tile = priority_draw_list.pop_at(tile_rng.randi() % priority_draw_list.size())
		
		# If the priority draw list is empty, pull from the list of normally available tiles.
		else:
			called_tile = available_tiles.pop_at(tile_rng.randi() % available_tiles.size())

		# Set the tile's age to zero so that it doesn't have any scaling from things like Patient notches.
		called_tile.current_age = 0
		
		# Add the LetterTile to the GridTile so it has data
		added_tile.tile = called_tile
		
		# Append it to the list of tiles in play, and add the tile to the racked tiles parent.
		tiles_in_play.append(called_tile)
		%RackedTiles.add_child(added_tile)

		# Grant the tile its grid index and name it.
		added_tile.tile.grid_index = grid_index
		added_tile.set_name(str("GridTile" + str(added_tile.tile.grid_index)))
		
		# Set up the tile's echoing statuses.
		if added_tile.tile.notch1 == LetterTile.NotchTypes.ECHOING:
			added_tile.tile.echo1 = true
		if added_tile.tile.notch2 == LetterTile.NotchTypes.ECHOING:
			added_tile.tile.echo2 = true
		if added_tile.tile.notch3 == LetterTile.NotchTypes.ECHOING:
			added_tile.tile.echo3 = true
		added_tile.tile.special_echo = true

		# Set the tile's drop position as well as the target position after dropping
		# We use modulo of 4 to determine the column, and the floor of dividing by four to determine the row. This should be foolproof.
		added_tile.position = Vector2((((added_tile.tile.grid_index % 4 ) * 32.0) + 256.0), 264.0)
		added_tile.tile.target = Vector2((((added_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(added_tile.tile.grid_index / 4) * 32.0) + 296.0))
		# Based on the index, we tell it what column to drop from, and it spawns above.
		
		# Play the tile's spawn-in animation
		added_tile.spawned_in()
		
		# Tween the tile to its new location and play the tile sound
		await added_tile.move_to_position()
		GameEventHandler.play_tile_sound.emit(added_tile)
		
		# Update the tile bag about this new tile.
		GameEventHandler.update_bag_tiles.emit()
	
		return
	# Fallback for safety.
	else:
		return

func _calc_enemy_word_score(enemy: Enemy, enemy_word: Array, target: String):
	var tile_score = 0
	var points_score = 0
	var mult_score = 0
	var total_score = 0
	var tile_retriggers = 0
	var context_power = 0
	var bonus_word_length = 0
	var word_index = 0
	
	if target == "SELF" or target == "OTHER":
		# Query Dexterity
		context_power += enemy.query_status_value(13)
		# Query Intelligence
		bonus_word_length += enemy.query_status_value(14)

	if target == "PLAYER":
		# Query Strength
		context_power += enemy.query_status_value(12)
		# Query Intelligence
		bonus_word_length += enemy.query_status_value(14)
	
	for i in enemy_word.size():
		
		var word_length = enemy_word.size()
		
		# Enemy words are imported as an array of LetterTiles.
		var scored_tile = enemy.current_enemy_deck[enemy_word[i]]
		
		if scored_tile.type == LetterTile.TileType.LOCKED:
			continue
		
		# The position of the tile in the word for effects like Local, Distant, and Eager.
		scored_tile.word_index = word_index
		# We pass along the word's length as well to help determine scoring.
		scored_tile.word_length = enemy_word.size()
		
		# Increase the word index for the next tile in sequence.
		word_index += 1
		
		# Query for Repeating notches
		if scored_tile.notch1 == LetterTile.NotchTypes.REPEATING:
			tile_retriggers += 1
		if scored_tile.notch2 == LetterTile.NotchTypes.REPEATING:
			tile_retriggers += 1
		if scored_tile.notch3 == LetterTile.NotchTypes.REPEATING:
			tile_retriggers += 1
		
		for j in tile_retriggers + 1:
			# Send the tile to the scoring algorithm in the General Manager and tally the score.
			tile_score += GeneralManager.score_tile_quiet(scored_tile)
			tile_score += context_power
			
		points_score += tile_score
		
		tile_score = 0
		tile_retriggers = 0

		@warning_ignore("integer_division")
		mult_score = floor((word_length + bonus_word_length) / 2)
		
	total_score = points_score * mult_score
	
	return total_score

func _spawn_new_enemy_word(attack_to_perform, attack_letter_tiles, status_package, _pivot_position, target, attacker):
	
	var enemy_letters = []
	var tile_score 			= 0
	var mult_score 			= 0
	var points_score 		= 0
	var total_score 		= 0
	var tile_retriggers		= 0
	var tile_score_count	= 0
	var word_length 		= 0
	var context_power 		= 0
	var bonus_word_length	= 0

	context_power += attacker.point_bonus
	bonus_word_length += attacker.length_bonus

	if target == "SELF" or target == "OTHER":
		# Query Dexterity
		context_power += attacker.query_status_value(13)
		# Query Intelligence
		bonus_word_length += attacker.query_status_value(14)

	if target == "PLAYER":
		# Query Strength
		context_power += attacker.query_status_value(12)
		# Query Intelligence
		bonus_word_length += attacker.query_status_value(14)

	for i in attack_to_perform.size():
		if attack_letter_tiles[i].type == LetterTile.TileType.LOCKED:
			continue
		
		var added_tile = grid_tile_scene.instantiate()
		added_tile.tile = attack_letter_tiles[i]
		added_tile.tile.is_friendly = false
		
		%TilesInWord.add_child(added_tile)
		enemy_letters.append(added_tile)
		added_tile.position = _pivot_position
		added_tile.spawned_in()
		
		if %TilesInWord.get_child_count() == 1:
			added_tile.tile.target = Vector2(304.0, 120.0)
			
		else:
			added_tile.tile.target = Vector2(%TilesInWord.get_child(0).tile.target.x + (38.0 * float(i)), 120.0)
		
		await added_tile.move_to_position()
		added_tile.add_to_group("Tiles In Word")
		_adjust_word_tile_position(true)
		GameEventHandler.play_tile_sound.emit(added_tile)
		_tiles_in_word_update()
		
		await get_tree().create_timer(0.04).timeout
	
	await get_tree().create_timer(0.2).timeout
	
	for i in %TilesInWord.get_child_count():
		%TilesInWord.get_child(i).toggle_word_glow(true)
	
	await get_tree().create_timer(0.2).timeout
	
	GeneralManager.scoring_is_active = true
	
	for i in %TilesInWord.get_child_count():
		var scored_tile = enemy_letters[i]
		word_length += 1
		
		scored_tile.tile.word_index = i
		scored_tile.tile.word_length = %TilesInWord.get_child_count()
		
		# Query for Repeating notches
		if scored_tile.tile.notch1 == LetterTile.NotchTypes.REPEATING:
			#print("Repeating of course! 1")
			tile_retriggers += 1
			scored_tile.juice_notch(1)
		if scored_tile.tile.notch2 == LetterTile.NotchTypes.REPEATING:
			# print("Repeating of course! 2")
			tile_retriggers += 1
			scored_tile.juice_notch(2)
		if scored_tile.tile.notch3 == LetterTile.NotchTypes.REPEATING:
			# print("Repeating of course! 3")
			tile_retriggers += 1
			scored_tile.juice_notch(3)
		
		for j in tile_retriggers + 1:
			tile_score += scored_tile.score_tile(tile_score_count)
			tile_score += context_power
			scored_tile.update_tile_score_text(tile_score)
			tile_score_count += 1
			
			scored_tile.toggle_word_glow()
			
			if no_delay_list.has(scored_tile.tile.notch1) \
			and no_delay_list.has(scored_tile.tile.notch2) \
			and no_delay_list.has(scored_tile.tile.notch3):
				print("Tile effect delay skipped!")
				await get_tree().create_timer(0.025).timeout
			
			else:
				await get_tree().create_timer(0.1).timeout
			
			#region Reinforced:
			if scored_tile.tile.notch1 == LetterTile.NotchTypes.REINFORCED \
			or scored_tile.tile.notch2 == LetterTile.NotchTypes.REINFORCED \
			or scored_tile.tile.notch3 == LetterTile.NotchTypes.REINFORCED:
			
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REINFORCED:
					attacker.gain_block(5, "REINFORCED_NOTCH")
					scored_tile.juice_notch(1)
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.REINFORCED:
					attacker.gain_block(5, "REINFORCED_NOTCH")
					scored_tile.juice_notch(2)
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.REINFORCED:
					attacker.gain_block(5, "REINFORCED_NOTCH")
					scored_tile.juice_notch(3)
					
				await get_tree().create_timer(0.1).timeout
			#endregion
		
			#region Rejuvenating:
			if scored_tile.tile.notch1 == LetterTile.NotchTypes.REJUVENATING \
			or scored_tile.tile.notch2 == LetterTile.NotchTypes.REJUVENATING \
			or scored_tile.tile.notch3 == LetterTile.NotchTypes.REJUVENATING:
			
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal1 == false:
					attacker.gain_health(3)
					scored_tile.juice_notch(1)
					scored_tile.tile.heal1 = true
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal2 == false:
					attacker.gain_health(3)
					scored_tile.juice_notch(2)
					scored_tile.tile.heal2 = true
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal3 == false:
					attacker.gain_health(3)
					scored_tile.juice_notch(3)
					scored_tile.tile.heal3 = true
			
				await get_tree().create_timer(0.1).timeout
			#endregion
			
			if target == "PLAYER":
				var burn_bonus = 0
				var bleed_bonus = 0
				
				##TODO: Query for debuff-related boosts
				
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.FLAMING \
				or scored_tile.tile.notch2 == LetterTile.NotchTypes.FLAMING \
				or scored_tile.tile.notch3 == LetterTile.NotchTypes.FLAMING:
				
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.FLAMING:
						character_path.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
						scored_tile.juice_notch(1)
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.FLAMING:
						character_path.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
						scored_tile.juice_notch(2)
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.FLAMING:
						character_path.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
						scored_tile.juice_notch(3)
						
					await get_tree().create_timer(0.1).timeout
				
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.PRICKLY \
				or scored_tile.tile.notch2 == LetterTile.NotchTypes.PRICKLY \
				or scored_tile.tile.notch3 == LetterTile.NotchTypes.PRICKLY:
				
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.PRICKLY:
						character_path.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
						scored_tile.juice_notch(1)
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.PRICKLY:
						character_path.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
						scored_tile.juice_notch(2)
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.PRICKLY:
						character_path.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
						scored_tile.juice_notch(3)
						
					await get_tree().create_timer(0.1).timeout
				
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			await get_tree().create_timer(0.12).timeout
				
		points_score += tile_score
		get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
		
		tile_score = 0
		tile_retriggers = 0
		await get_tree().create_timer(0.05).timeout
		
		@warning_ignore("integer_division")
		mult_score = floor(word_length / 2)
		get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
		await get_tree().create_timer(0.05).timeout
		
		total_score = points_score * mult_score
		get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
		await get_tree().create_timer(0.05).timeout
		
	if bonus_word_length > 0:
		for i in bonus_word_length:
			word_length += 1
			@warning_ignore("integer_division")
			mult_score = floor(word_length / 2)
			
			total_score = points_score * mult_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)

	total_score = points_score * mult_score
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	await get_tree().create_timer(0.075).timeout
	
	if target == "PLAYER":
		var damage = total_score
		character_path.take_damage(damage, "ENEMY_WORD") ## TODO: REMOVE THIS
		
		var thorns_damage = character_path.query_status_value(11)
		if thorns_damage > 0:
			attacker.take_damage(thorns_damage, "THORNS_DAMAGE") ## TODO: REMOVE THIS
		
	elif target == "SELF":
		attacker.gain_block(total_score, "ENEMY_WORD") ## TODO: REMOVE THIS
		
	else:
		attacker.take_damage(0, "FALLBACK_PROCEDURE") ## TODO: REMOVE THIS
	
	if not status_package.is_empty():
		for i in status_package.size():
			var subpackage = status_package[i]
			var status_name = subpackage[0]
			var amount = subpackage[1]
			var decay_type = subpackage[2]
			var duration = subpackage[3]
			
			if subpackage[4] == "PLAYER":
				character_path.add_status(status_name, amount, decay_type, duration)
			
			if subpackage[4] == "SELF":
				attacker.add_status(status_name, amount, decay_type, duration)
		
	await get_tree().create_timer(1.25).timeout
	
	for i in %TilesInWord.get_child_count():
		%TilesInWord.get_child(-1).tile.word_index = 0
		%TilesInWord.get_child(-1).tile.word_length = 0
		%TilesInWord.get_child(-1).tile.target = _pivot_position
		%TilesInWord.get_child(-1).move_to_position()
		%TilesInWord.get_child(-1).is_dying()
		%TilesInWord.get_child(-1).reparent(%TilesToKill)
		await get_tree().create_timer(0.04).timeout
		
	_cleanup_killed_tiles()
	GameEventHandler.enemy_attack_finished.emit(attacker)
	
	GeneralManager.scoring_is_active = false

func _tiles_in_word_update():
	letters_from_tiles = []
	
	for i in %TilesInWord.get_child_count():
		var current_tile = %TilesInWord.get_child(i)
		letters_from_tiles.append(str(current_tile.tile.TileLetter.keys()[current_tile.tile.played_letter]).to_snake_case())
		current_tile.tile.word_index = i
		current_tile.tile.word_length = %TilesInWord.get_child_count()

	if character_path.current_energy > 0:
		_word_from_tiles(letters_from_tiles)

func _adjust_word_tile_position(called_by_enemy: bool = false):
	if allow_interaction or called_by_enemy:
		var squish_factor = float(7.0 / (%TilesInWord.get_child_count() + 1))
		for i in %TilesInWord.get_child_count():
			var current_tile = %TilesInWord.get_child(i)
			
			if %TilesInWord.get_child_count() <= 6:
				%TilesInWord.get_child(0).tile.target = Vector2(304.0 - (19.0 * float(%TilesInWord.get_child_count()-1)), 120.0)
				current_tile.tile.target = Vector2(%TilesInWord.get_child(0).tile.target.x + (38.0 * float(i)), 120.0)
			else:
				%TilesInWord.get_child(0).tile.target = Vector2(304.0 - (19.0 * float(%TilesInWord.get_child_count()-1))*squish_factor, 120.0)
				current_tile.tile.target = Vector2(%TilesInWord.get_child(0).tile.target.x + (38.0 * float(i))*squish_factor, 120.0)
			current_tile.move_to_position(0.35)
			current_tile.determine_tile_scale()

func _tiles_in_word_cascade_clear(grid_tile: GridTile):
	var tile_clicked = grid_tile.get_index()
	var total_tiles = %TilesInWord.get_child_count()
	var difference = total_tiles - tile_clicked
	for i in difference:
		_send_back_to_rack(%TilesInWord.get_child(-1))
		_tiles_in_word_update()
		await get_tree().create_timer(0.004).timeout
		
func _tiles_in_word_force_clear():
	for i in %TilesInWord.get_child_count():
		_send_back_to_rack(%TilesInWord.get_child(-1))
		_tiles_in_word_update()
		await get_tree().create_timer(0.004).timeout
	return true

func _send_tile_to_word(grid_tile: GridTile):
	grid_tile.reparent(%TilesInWord, true)
	grid_tile.add_to_group("Tiles In Word")
	_tiles_in_word_update()
	_adjust_word_tile_position()
	
func _send_back_to_rack(grid_tile: GridTile):
	# Revert the tile to its default state prior to being added to the word.
	grid_tile.toggle_word_glow()
	grid_tile.remove_from_group("Tiles In Word")
	grid_tile.reparent(%RackedTiles)
	grid_tile.tile.word_index = 0
	grid_tile.tile.word_length = 0
	
	# Send it back to its proper location in the grid.
	grid_tile.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4.0) * 32.0) + 296.0))
	grid_tile.move_to_position(0.35)
	grid_tile.determine_tile_scale()
	
	if not grid_tile.ghost_pair == null:
		grid_tile.ghost_pair.queue_free()
		
	if grid_tile.paired_tile_1 is GridTile:
		if grid_tile.paired_tile_1.tile.is_ghost:
			grid_tile.paired_tile_1.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4.0) * 32.0) + 296.0))
			grid_tile.paired_tile_1.move_to_position(0.35)
			grid_tile.paired_tile_1.determine_tile_scale()
			grid_tile.paired_tile_1.reparent(%TilesToKill)
			grid_tile.paired_tile_1.is_vanishing()
			grid_tile.paired_tile_1 = null
			
	if grid_tile.paired_tile_2 is GridTile:
		if grid_tile.paired_tile_2.tile.is_ghost:
			grid_tile.paired_tile_2.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4.0) * 32.0) + 296.0))
			grid_tile.paired_tile_2.move_to_position(0.35)
			grid_tile.paired_tile_2.determine_tile_scale()
			grid_tile.paired_tile_2.reparent(%TilesToKill)
			grid_tile.paired_tile_2.is_vanishing()
			grid_tile.paired_tile_2 = null
			
	if grid_tile.paired_tile_3 is GridTile:
		if grid_tile.paired_tile_3.tile.is_ghost:
			grid_tile.paired_tile_3.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4.0) * 32.0) + 296.0))
			grid_tile.paired_tile_3.move_to_position(0.35)
			grid_tile.paired_tile_3.determine_tile_scale()
			grid_tile.paired_tile_3.reparent(%TilesToKill)
			grid_tile.paired_tile_3.is_vanishing()
			grid_tile.paired_tile_3 = null
	
	_adjust_word_tile_position()
	_tiles_in_word_update()
	_cleanup_killed_tiles()
	
	return true

func _on_tile_clicked(which: GridTile, action: GridTile.GridTileAction):
	# A bunch of controlling flags to determine if a tile should even be clickable.
	if allow_interaction and not GeneralManager.is_bag_open and not GeneralManager.is_map_open \
	and character_path.has_initiative and which.tile.is_friendly and not which.tile.type == LetterTile.TileType.LOCKED:
		if action == GridTile.GridTileAction.PLAY:
			
			if which.get_parent() == %RackedTiles:
				# Get a copy of the tile's data.
				var tile_data = which.tile
				
				# If the clicked tile is not a ghost, do the following.
				if not which.tile.is_ghost:
					# Create a new LetterTile from the copied data
					var ghost_tile_data = LetterTile.new().new_tile(tile_data.type, tile_data.true_letter, tile_data.notch1, tile_data.notch2, tile_data.notch3, -1, true)
					
					# Instantiate a new grid tile to act as a ghost in the rack.
					var rack_ghost = grid_tile_scene.instantiate()
					
					# Give the rack ghost the copied data, make sure it knows it's a ghost in the grid.
					rack_ghost.tile = ghost_tile_data
					rack_ghost.grid_ghost = true
					
					# Pair the two tiles with each other.
					which.ghost_pair = rack_ghost
					rack_ghost.ghost_pair = which
					
					# Add the ghost tile as a child to the ghost parent.
					%GhostParent.add_child(rack_ghost)
					
					# Set the position of the rack ghost to the original tile's position.
					rack_ghost.position = Vector2((((which.tile.grid_index % 4) * 32.0) + 256.0),((floor(which.tile.grid_index / 4.0) * 32.0) + 296.0))
			
				if which.tile.notch1 == LetterTile.NotchTypes.LEXICAL:
					# Create new LetterTile
					var lex_letter_1 = letters.find(str(which.tile.bonus_letter1))
					var lex_data_1 = LetterTile.new().new_tile(which.tile.type, lex_letter_1, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, -1, true)
					
					# Create new GridTile
					var lex_tile_1 = grid_tile_scene.instantiate()
					
					# Bind new LetterTile to new GridTile
					lex_tile_1.tile = lex_data_1
					lex_tile_1.tile.grid_index = which.tile.grid_index
					
					# Pair it with the GridTile that spawned it
					which.paired_tile_1 = lex_tile_1
					lex_tile_1.paired_tile_1 = which
					
					# Pose it to the position of the original grid tile
					lex_tile_1.z_index = which.z_index
						
					%GhostParent.add_child(lex_tile_1)
					lex_tile_1.position = which.position

				if which.tile.notch2 == LetterTile.NotchTypes.LEXICAL:
					# Create new LetterTile
					var lex_letter_2 = letters.find(str(which.tile.bonus_letter2))
					var lex_data_2 = LetterTile.new().new_tile(which.tile.type, lex_letter_2, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, -1, true)
					
					# Create new GridTile
					var lex_tile_2 = grid_tile_scene.instantiate()
					
					# Bind new LetterTile to new GridTile
					lex_tile_2.tile = lex_data_2
					lex_tile_2.tile.grid_index = which.tile.grid_index
					
					# Pair it with the GridTile that spawned it
					which.paired_tile_2 = lex_tile_2
					lex_tile_2.paired_tile_2 = which
					
					# Pose it to the position of the original grid tile
					lex_tile_2.z_index = which.z_index
						
					%GhostParent.add_child(lex_tile_2)
					lex_tile_2.position = which.position
					
				if which.tile.notch3 == LetterTile.NotchTypes.LEXICAL:
					# Create new LetterTile
					var lex_letter_3 = letters.find(str(which.tile.bonus_letter3))
					var lex_data_3 = LetterTile.new().new_tile(which.tile.type, lex_letter_3, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, -1, true)
					
					# Create new GridTile
					var lex_tile_3 = grid_tile_scene.instantiate()
					
					# Bind new LetterTile to new GridTile
					lex_tile_3.tile = lex_data_3
					lex_tile_3.tile.grid_index = which.tile.grid_index
					
					# Pair it with the GridTile that spawned it
					which.paired_tile_3 = lex_tile_3
					lex_tile_3.paired_tile_3 = which
					
					# Pose it to the position of the original grid tile
					lex_tile_3.z_index = which.z_index
						
					%GhostParent.add_child(lex_tile_3)
					lex_tile_3.position = which.position

				_send_tile_to_word(which)
				if not which.paired_tile_1 == null:
					_send_tile_to_word(which.paired_tile_1)
				if not which.paired_tile_2 == null:
					_send_tile_to_word(which.paired_tile_2)
				if not which.paired_tile_3 == null:
					_send_tile_to_word(which.paired_tile_3)
			
			elif which.get_parent() == %TilesInWord:
				if which.tile.notch1 == LetterTile.NotchTypes.LEXICAL and which.paired_tile_1 is GridTile:
					# If, somehow, the clicked tile is a ghost tile AND has a Lexical notch applied to it, we instead send its pairing back to the rack.
					if which.tile.is_ghost:
						_send_back_to_rack(which.paired_tile_1)
					# The default behaviour should be that the clicked tile is not a ghost, so it should always activate this else statement.
					else:
						_send_back_to_rack(which)
						
				if which.tile.notch2 == LetterTile.NotchTypes.LEXICAL and which.paired_tile_2 is GridTile:
					if which.tile.is_ghost:
						_send_back_to_rack(which.paired_tile_2)
					else:
						_send_back_to_rack(which)
				
				if which.tile.notch3 == LetterTile.NotchTypes.LEXICAL and which.paired_tile_3 is GridTile:
					if which.tile.is_ghost:
						_send_back_to_rack(which.paired_tile_3)
					else:
						_send_back_to_rack(which)
					
				# If the clicked tile is a ghost in the word, we send the ghost's pairing back to the rack, which will take care of the ghosts.
				if which.tile.is_ghost:
					if which.paired_tile_1 is GridTile:
						_send_back_to_rack(which.paired_tile_1)
					if which.paired_tile_2 is GridTile:
						_send_back_to_rack(which.paired_tile_2)
					if which.paired_tile_3 is GridTile:
						_send_back_to_rack(which.paired_tile_3)
				
				else:
					_send_back_to_rack(which)
			
			elif which.get_parent() == %GhostParent and which.grid_ghost:
				_on_tile_clicked(which.ghost_pair, GridTile.GridTileAction.PLAY)
			
		if action == GridTile.GridTileAction.VIEW:
			
			if which.get_parent() == %RackedTiles:
				pass
			
			elif which.get_parent() == %TilesInWord and not which.tile.is_ghost:
				_tiles_in_word_cascade_clear(which)
		
		_calc_raw_word_score()
		
	else:
		pass

func _word_from_tiles(played_letters: PackedStringArray):
	word = "".join(played_letters)
	true_word = ""
	
	if word.length() >= 3 and current_target is GameEntity:
		var is_word = word_list.get(word)
		var is_secret_word = bonus_word_list.get(word)
		var mixed_word = false
		var mangled_word = false
	
		if not is_word or not is_secret_word:
			for i in current_relics.size():
				mixed_word = current_relics[i].mixer_check(word)
				if mixed_word:
					break
		
		if not is_word and not is_secret_word and not mixed_word:
			mangled_word = mangled_word_check(word)
		
		if is_word and allow_interaction:
			%WordLabel.text = str(word.to_upper() + " is a valid word!")
			%PlayButton.set_disabled(false)
			true_word = word
			await get_tree().create_timer(0.05).timeout
			get_tree().call_group("Tiles In Word", "toggle_word_glow", true)
			
			
		elif is_secret_word and allow_interaction:
			%WordLabel.text = str(word.to_upper() + " is a bonus word!")
			%PlayButton.set_disabled(false)
			true_word = word
			await get_tree().create_timer(0.05).timeout
			get_tree().call_group("Tiles In Word", "toggle_word_glow", true)
			
		
		elif mixed_word and allow_interaction:
			%WordLabel.text = str(word.to_upper() + " is a valid wordrow dilav a si " + word.reverse().to_upper())
			%PlayButton.set_disabled(false)
			true_word = word
			await get_tree().create_timer(0.05).timeout
			get_tree().call_group("Tiles In Word", "toggle_word_glow", true)
			
		elif mangled_word and allow_interaction:
			%WordLabel.text = str(word.to_upper() + " is a mangled word! " + word.reverse().to_upper())
			%PlayButton.set_disabled(false)
			await get_tree().create_timer(0.05).timeout
			get_tree().call_group("Tiles In Word", "toggle_word_glow", true)
		
		elif not is_word or not mixed_word or not mangled_word:
			if allow_interaction:
				%WordLabel.text = ""
				%PlayButton.set_disabled(true)
				await get_tree().create_timer(0.05).timeout
				get_tree().call_group("Tiles In Word", "toggle_word_glow")
		
	else:
		if character_path.has_initiative:
			%WordLabel.text = ""
			%PlayButton.set_disabled(true)
			await get_tree().create_timer(0.05).timeout
			get_tree().call_group("Tiles In Word", "toggle_word_glow")

func mangled_word_check(input_word: String):
	
	var mangle_1 = input_word
	var mangle_2 = input_word
	var mangle_3 = input_word
	var mangle_4 = input_word
	
	var result_1: String = ""
	var result_2: String = ""
	var result_3: String = ""
	var result_4: String = ""
	
	var result_words: Array[String] = []
	var result_lengths: Array[int] = []
	
	# Suffixes First, then Prefixes
	for i in 3:
		if not GeneralManager.suffix_array.is_empty():
			for j in GeneralManager.suffix_array.size():
				if not mangle_1 == mangle_1.trim_suffix(GeneralManager.suffix_array[j]):
					mangle_1 = mangle_1.trim_suffix(GeneralManager.suffix_array[j])
					if GeneralManager.word_list.has(mangle_1):
						result_1 = mangle_1
						if not result_words.has(result_1):
							result_words.append(result_1)
						break
	
	if result_1 == "":
		for i in 3:
			if not GeneralManager.prefix_array.is_empty():
				for j in GeneralManager.prefix_array.size():
					if not mangle_1 == mangle_1.trim_prefix(GeneralManager.prefix_array[j]):
						mangle_1 = mangle_1.trim_prefix(GeneralManager.prefix_array[j])
						if GeneralManager.word_list.has(mangle_1):
							result_1 = mangle_1
							if not result_words.has(result_1):
								result_words.append(result_1)
							break
	
	# Prefixes First, then Suffixes
	for i in 3:
		if not GeneralManager.prefix_array.is_empty():
			for j in GeneralManager.prefix_array.size():
				if not mangle_2 == mangle_2.trim_prefix(GeneralManager.prefix_array[j]):
					mangle_2 = mangle_2.trim_prefix(GeneralManager.prefix_array[j])
					if GeneralManager.word_list.has(mangle_2):
						result_2 = mangle_2
						if not result_words.has(result_2):
							result_words.append(result_2)
						break
	
	if result_2 == "":
		for i in 3:
			if not GeneralManager.suffix_array.is_empty():
				for j in GeneralManager.suffix_array.size():
					if not mangle_2 == mangle_2.trim_suffix(GeneralManager.suffix_array[j]):
						mangle_2 = mangle_2.trim_suffix(GeneralManager.suffix_array[j])
						if GeneralManager.word_list.has(mangle_1):
							result_2 = mangle_2
							if not result_words.has(result_2):
								result_words.append(result_2)
							break
	
	# Back-and-Forth staring with Suffix
	for i in 3:
		if not GeneralManager.suffix_array.is_empty():
			for j in GeneralManager.suffix_array.size():
				if not mangle_3 == mangle_3.trim_suffix(GeneralManager.suffix_array[j]):
					mangle_3 = mangle_3.trim_suffix(GeneralManager.suffix_array[j])
					break
			
		if not GeneralManager.prefix_array.is_empty():
			for j in GeneralManager.prefix_array.size():
				if not mangle_3 == mangle_3.trim_prefix(GeneralManager.prefix_array[j]):
					mangle_3 = mangle_3.trim_prefix(GeneralManager.prefix_array[j])
					break
			
		if GeneralManager.word_list.has(mangle_3):
			result_3 = mangle_3
			if not result_words.has(result_3):
				result_words.append(result_3)
			break

	# Back-and-Forth staring with Prefix
	for i in 3:
		if not GeneralManager.prefix_array.is_empty():
			for j in GeneralManager.prefix_array.size():
				if not mangle_4 == mangle_4.trim_prefix(GeneralManager.prefix_array[j]):
					mangle_4 = mangle_4.trim_prefix(GeneralManager.prefix_array[j])
					break
		
		if not GeneralManager.suffix_array.is_empty():
			for j in GeneralManager.suffix_array.size():
				if not mangle_4 == mangle_4.trim_suffix(GeneralManager.suffix_array[j]):
					mangle_4 = mangle_4.trim_suffix(GeneralManager.suffix_array[j])
					break
		
		if GeneralManager.word_list.has(mangle_4):
			result_4 = mangle_4
			if not result_words.has(result_4):
				result_words.append(result_4)
			break

	for i in result_words.size():
		result_lengths.append(result_words[i].length())
	
	var best_length = result_lengths.max()
	if best_length == null:
		return false
	
	else:
		true_word = result_words[result_lengths.find(best_length)]
		
		print("Result Words: " + str(result_words))
		print("Best Length: " + str(best_length))
		print("Best Word: " + true_word)
		print("")
		
		return true

func _on_play_button_pressed():
	if character_path.has_initiative and character_path.current_energy > 0:
		_score_word()
	else:
		await _tiles_in_word_force_clear()
		_pass_turn()

func _score_word(): ## TODO: change to the sender-recipient format?
	var word_target = current_target
	
	allow_interaction = false
	GeneralManager.scoring_is_active = true
	%PlayButton.set_disabled(true)
	played_words_count 			+= 1
	
	var points_score 			= 0
	var mult_score 				= 0
	var tile_score 				= 0
	var total_score 			= 0
	var word_retriggers 		= 0
	var tile_retriggers 		= 0
	var tile_score_count 		= 0
	var word_length 			= 0
	var context_power 			= 0
	var bonus_word_length 		= 0
	
	character_path.remove_energy(1) ## TODO: Update to reference the sender.

	# If there are any effects that would retrigger the scoring of the word, they'll be processed here.
	# If there's any effects with context-based power, they should also go here.
	# i.e. checking a word type belongs in this category
	for i in current_relics.size():		## TODO: Rewrite as "for relic: Relic in current_relics:"
		word_retriggers += await current_relics[i].word_retrigger_effect(word)
		context_power +=  await current_relics[i].word_tile_bonus_score_effect(word)
		await current_relics[i].word_played_effect(word, word_target)

	if word_target is Enemy:
		# Query Player Strength
		context_power += character_path.query_status_value(12)
	
	if word_target is Character:
		# Query Player Dexterity
		context_power += character_path.query_status_value(13)
	
	# Query Player Intelligence
	bonus_word_length += character_path.query_status_value(14)
	
	for i in word_retriggers + 1:
	#region Word Scoring Loop
		## TODO: ADD SECTION FOR RESISTANCE/WEAKNESS SCORE BONUS
		## TODO: ADD WORD SCORED SIGNAL
		
		# Word Retrigger Loop
		for j in %TilesInWord.get_child_count():
		#region Tile Scoring Loop
			
			var scored_tile = %TilesInWord.get_child(j) as GridTile
			word_length += 1
			
			if scored_tile.ghost_pair is GridTile:
				scored_tile.ghost_pair.is_being_bagged()
				scored_tile.ghost_pair = null
				
			scored_tile.toggle_word_glow()
			
			if not scored_tile.paired_tile_1 == null:
				scored_tile.paired_tile_1 = null
			if not scored_tile.paired_tile_2 == null:
				scored_tile.paired_tile_2 = null
			if not scored_tile.paired_tile_3 == null:
				scored_tile.paired_tile_3 = null
			
			## INFO: PLAYER ONLY
			# Retriggers from Relics subloop
			for k in current_relics.size():
				# Pull any letter retrigger effects from relics
				tile_retriggers += await current_relics[k].letter_retrigger_effect(scored_tile.tile.played_letter, word)
			## END INFO: PLAYER ONLY
			
			# Query for Repeating notches
			if scored_tile.tile.notch1 == LetterTile.NotchTypes.REPEATING:
				tile_retriggers += 1
				scored_tile.juice_notch(1)
			if scored_tile.tile.notch2 == LetterTile.NotchTypes.REPEATING:
				tile_retriggers += 1
				scored_tile.juice_notch(2)
			if scored_tile.tile.notch3 == LetterTile.NotchTypes.REPEATING:
				tile_retriggers += 1
				scored_tile.juice_notch(3)
				
			# Score each letter for a number of times equal to their retriggers, plus one.
			for k in tile_retriggers + 1:
				
				# Score the actual letter and get the score, plus increment the scored letter count.
				tile_score +=  await scored_tile.score_tile(tile_score_count)
				tile_score += context_power
				scored_tile.update_tile_score_text(tile_score)
				tile_score_count += 1
				
				## INFO: PLAYER ONLY
				GeneralManager.scored_tile_count += 1
				## END INFO: PLAYER ONLY
				
				%TileScoreLabel.text = str(tile_score)
				# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
				
				if no_delay_list.has(scored_tile.tile.notch1) \
				and no_delay_list.has(scored_tile.tile.notch2) \
				and no_delay_list.has(scored_tile.tile.notch3):
					print("Tile effect delay skipped!")
					await get_tree().create_timer(0.025).timeout
			
				else:
					await get_tree().create_timer(0.1).timeout
				
				## INFO: PLAYER ONLY
				# Pull any bonus point effects from relics.
				for l in current_relics.size():
					# Grid index based effects
					tile_score += await current_relics[l].grid_index_effect(scored_tile.tile.grid_index, word)
					scored_tile.update_tile_score_text(tile_score)
					%TileScoreLabel.text = str(tile_score)
				
				for l in current_relics.size():
					# Letter based effects
					tile_score += await current_relics[l].letter_score_effect(scored_tile.tile.played_letter, word, word_target, tile_score)
					scored_tile.update_tile_score_text(tile_score)
					%TileScoreLabel.text = str(tile_score)
				
				for l in current_relics.size():
					# Effects based on the total count of scored tiles
					tile_score += await current_relics[l].x_letters_played_effect(tile_score, word)
					scored_tile.update_tile_score_text(tile_score)
					%TileScoreLabel.text = str(tile_score)
				## END INFO: PLAYER ONLY
				
				## INFO: PLAYER NOTCH ONLY
				#region Phantom
				# If a tile has Phantom, then add two dumb clones of it to the available tiles list.
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.PHANTOM \
				or scored_tile.tile.notch2 == LetterTile.NotchTypes.PHANTOM \
				or scored_tile.tile.notch3 == LetterTile.NotchTypes.PHANTOM:
				
					GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.PHANTOM)
				
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.PHANTOM:
						scored_tile.juice_notch(1)
						# print("Going ghost... 1")
						for l in 2:
							# Clone the tile, add it to the available tiles list.
							var cloned_tile = scored_tile.tile
							var new_clone = LetterTile.new().new_tile(LetterTile.TileType.CRUMBLING, cloned_tile.true_letter, LetterTile.NotchTypes.EMPTY, cloned_tile.notch2, cloned_tile.notch3, -1)
							new_clone.is_temporary = true
							new_clone.tile_index = current_combat_deck.size()
							
							if new_clone.notch2 == LetterTile.NotchTypes.INERT or new_clone.notch2 == LetterTile.NotchTypes.ECHOING:
								new_clone.notch2 = LetterTile.NotchTypes.EMPTY
							if new_clone.notch3 == LetterTile.NotchTypes.INERT or new_clone.notch3 == LetterTile.NotchTypes.ECHOING:
								new_clone.notch3 = LetterTile.NotchTypes.EMPTY
							
							current_combat_deck.append(new_clone)
							available_tiles.append(new_clone)
					
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.PHANTOM:
						scored_tile.juice_notch(2)
						# print("Going ghost... 2")
						for l in 2:
							# Clone the tile, add it to the available tiles list.
							var cloned_tile = scored_tile.tile
							var new_clone = LetterTile.new().new_tile(LetterTile.TileType.CRUMBLING, cloned_tile.true_letter, cloned_tile.notch1, LetterTile.NotchTypes.EMPTY, cloned_tile.notch3, -1)
							new_clone.is_temporary = true
							new_clone.tile_index = current_combat_deck.size()
							
							if new_clone.notch1 == LetterTile.NotchTypes.INERT or new_clone.notch1 == LetterTile.NotchTypes.ECHOING:
								new_clone.notch1 = LetterTile.NotchTypes.EMPTY
							if new_clone.notch3 == LetterTile.NotchTypes.INERT or new_clone.notch3 == LetterTile.NotchTypes.ECHOING:
								new_clone.notch3 = LetterTile.NotchTypes.EMPTY
							
							current_combat_deck.append(new_clone)
							available_tiles.append(new_clone)
					
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.PHANTOM:
						scored_tile.juice_notch(3)
						# print("Going ghost... 3")
						for l in 2:
							# Clone the tile, add it to the available tiles list.
							var cloned_tile = scored_tile.tile
							var new_clone = LetterTile.new().new_tile(LetterTile.TileType.CRUMBLING, cloned_tile.true_letter, cloned_tile.notch1, cloned_tile.notch2, LetterTile.NotchTypes.EMPTY, -1)
							new_clone.is_temporary = true
							new_clone.tile_index = current_combat_deck.size()
							
							if new_clone.notch1 == LetterTile.NotchTypes.INERT or new_clone.notch1 == LetterTile.NotchTypes.ECHOING:
								new_clone.notch1 = LetterTile.NotchTypes.EMPTY
							if new_clone.notch2 == LetterTile.NotchTypes.INERT or new_clone.notch2 == LetterTile.NotchTypes.ECHOING:
								new_clone.notch2 = LetterTile.NotchTypes.EMPTY
							
							current_combat_deck.append(new_clone)
							available_tiles.append(new_clone)
							
					await get_tree().create_timer(0.1).timeout
				#endregion
				## END INFO: PLAYER NOTCH ONLY
				
				#region Reinforced
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REINFORCED \
				or scored_tile.tile.notch2 == LetterTile.NotchTypes.REINFORCED \
				or scored_tile.tile.notch3 == LetterTile.NotchTypes.REINFORCED:
					# If a tile has Reinforced, apply 5 block to the player.
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.REINFORCED:
						character_path.gain_block(5, "REINFORCED_NOTCH")
						scored_tile.juice_notch(1)
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.REINFORCED:
						character_path.gain_block(5, "REINFORCED_NOTCH")
						scored_tile.juice_notch(2)
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.REINFORCED:
						character_path.gain_block(5, "REINFORCED_NOTCH")
						scored_tile.juice_notch(3)
					
					await get_tree().create_timer(0.1).timeout
				#endregion
				
				#region Rejuvenating
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REJUVENATING \
				or scored_tile.tile.notch2 == LetterTile.NotchTypes.REJUVENATING \
				or scored_tile.tile.notch3 == LetterTile.NotchTypes.REJUVENATING:
				
					# If a tile has Rejuvenating, heal the player for 3.
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal1 == false:
						character_path.gain_health(3, "REJUVENATING_NOTCH")
						scored_tile.juice_notch(1)
						scored_tile.tile.heal1 = true
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal2 == false:
						character_path.gain_health(3, "REJUVENATING_NOTCH")
						scored_tile.juice_notch(2)
						scored_tile.tile.heal2 = true
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal3 == false:
						character_path.gain_health(3, "REJUVENATING_NOTCH")
						scored_tile.juice_notch(3)
						scored_tile.tile.heal3 = true
						
					await get_tree().create_timer(0.05).timeout
				#endregion
				
				#region Flaming & Prickly
				## TODO: Rewrite this for sender-recipient format
				# If a tile has Flaming, apply Burn to the enemy.
				if current_target is Enemy:
					var burn_bonus = 0
					var bleed_bonus = 0
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.FLAMING or scored_tile.tile.notch2 == LetterTile.NotchTypes.FLAMING or scored_tile.tile.notch3 == LetterTile.NotchTypes.FLAMING:
						for l in current_relics.size():
							burn_bonus += current_relics[l].debuff_boost("BURN_DEBUFF")
					
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.PRICKLY or scored_tile.tile.notch2 == LetterTile.NotchTypes.PRICKLY or scored_tile.tile.notch3 == LetterTile.NotchTypes.PRICKLY:
						for l in current_relics.size():
							bleed_bonus += current_relics[l].debuff_boost("BLEED_DEBUFF")
					
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.FLAMING \
					or scored_tile.tile.notch2 == LetterTile.NotchTypes.FLAMING \
					or scored_tile.tile.notch3 == LetterTile.NotchTypes.FLAMING:
					
						if scored_tile.tile.notch1 == LetterTile.NotchTypes.FLAMING:
							current_target.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
							scored_tile.juice_notch(1)
						if scored_tile.tile.notch2 == LetterTile.NotchTypes.FLAMING:
							current_target.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
							scored_tile.juice_notch(2)
						if scored_tile.tile.notch3 == LetterTile.NotchTypes.FLAMING:
							current_target.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
							scored_tile.juice_notch(3)
							
						await get_tree().create_timer(0.1).timeout
					
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.PRICKLY \
					or scored_tile.tile.notch2 == LetterTile.NotchTypes.PRICKLY \
					or scored_tile.tile.notch3 == LetterTile.NotchTypes.PRICKLY:
					
						if scored_tile.tile.notch1 == LetterTile.NotchTypes.PRICKLY:
							current_target.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
							scored_tile.juice_notch(1)
						if scored_tile.tile.notch2 == LetterTile.NotchTypes.PRICKLY:
							current_target.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
							scored_tile.juice_notch(2)
						if scored_tile.tile.notch3 == LetterTile.NotchTypes.PRICKLY:
							current_target.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
							scored_tile.juice_notch(3)
							
						await get_tree().create_timer(0.1).timeout
				#endregion
				
				points_score += tile_score
				
				%ScoreLabel.text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
				await get_tree().create_timer(0.05).timeout
				
				## INFO: POTENTIALLY PLAYER NOTCH ONLY
				#region Overloaded
				
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.OVERLOADED \
				or scored_tile.tile.notch2 == LetterTile.NotchTypes.OVERLOADED \
				or scored_tile.tile.notch3 == LetterTile.NotchTypes.OVERLOADED:
				
					if character_path.current_energy > 0:
						GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.OVERLOADED)
					
					# If a tile has OVERLOADED and the player has at least one energy, remove an energy and double the word score.
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.OVERLOADED and character_path.current_energy > 0:
						character_path.remove_energy(1)
						scored_tile.juice_notch(1)
						scored_tile.update_tile_score_text((tile_score + points_score))
						%TileScoreLabel.text = str(tile_score + points_score)
						points_score = points_score * 2
						# print("OVERLOADING... 1")
						%ScoreLabel.text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.OVERLOADED and character_path.current_energy > 0:
						character_path.remove_energy(1)
						scored_tile.juice_notch(2)
						scored_tile.update_tile_score_text((tile_score + points_score))
						%TileScoreLabel.text = str(tile_score + points_score)
						points_score = points_score * 2
						# print("OVERLOADING... 2")
						%ScoreLabel.text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.OVERLOADED and character_path.current_energy > 0:
						character_path.remove_energy(1)
						scored_tile.juice_notch(3)
						scored_tile.update_tile_score_text((tile_score + points_score))
						%TileScoreLabel.text = str(tile_score + points_score)
						points_score = points_score * 2
						# print("OVERLOADING... 3")
						%ScoreLabel.text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
					
					await get_tree().create_timer(0.1).timeout
					#endregion
				## END INFO: POTENTIALLY PLAYER NOTCH ONLY
				
				tile_score = 0
				
				await get_tree().create_timer(0.07).timeout
			# End Tile Retrigger Loop
			
			tile_retriggers = 0
			await get_tree().create_timer(0.05).timeout
			
			@warning_ignore("integer_division")
			mult_score = floor(word_length / 2)
				
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			await get_tree().create_timer(0.05).timeout
			
			total_score = points_score * mult_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
			await get_tree().create_timer(0.05).timeout
			#endregion
		# End Tile Scoring Loop
			
	#endregion
	# End Word Retrigger Loop
	
	## INFO: PLAYER ONLY
	# If something is going to modify the mult score, it goes here.
	for i in current_relics.size():
		bonus_word_length += await current_relics[i].word_length_bonus_effect(word)
	## END INFO: PLAYER ONLY
	
	if bonus_word_length >= 0:
		for i in bonus_word_length:
			word_length += 1
			@warning_ignore("integer_division")
			mult_score = floor(word_length / 2)
	
			total_score = points_score * mult_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	await get_tree().create_timer(0.075).timeout
	
	total_score = points_score * mult_score
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	
	## INFO: PLAYER ONLY
	# If something is going to modify the total word score, it goes here.
	for i in current_relics.size():
		total_score = total_score * await current_relics[i].word_score_multiplier_effect(word, current_target)
	## END INFO: PLAYER ONLY
	
	## TODO: ADD SECTION FOR RESISTANCE/WEAKNESS MULTIPLIER
	
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	await get_tree().create_timer(0.125).timeout

	# Post-processing for the scoring algorithm.
	for i in %TilesInWord.get_child_count():
		var tile_to_process = %TilesInWord.get_child(-1) as GridTile
		
		tile_to_process.tile.word_index = 0
		tile_to_process.tile.word_length = 0
		
		## INFO: PLAYER ONLY
		for j in current_relics.size():
			var echo_check = current_relics[j].tile_echo_effect(tile_to_process.tile)
			if tile_to_process.tile.special_echo and echo_check and not tile_to_process.tile.echoed_this_word:
				tile_to_process.tile.special_echo = false
				tile_to_process.tile.echoed_this_word = true
				tile_to_process.reparent(%RackedTiles)
				GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.ECHOING)
				_send_back_to_rack(tile_to_process)
		## END INFO: PLAYER ONLY
		
		## INFO: PLAYER NOTCH ONLY
		# Echoing overrides destructive effects.
		if tile_to_process.tile.notch1 == LetterTile.NotchTypes.ECHOING \
		and tile_to_process.tile.echo1 and not tile_to_process.tile.echoed_this_word:
			tile_to_process.tile.echo1 = false
			tile_to_process.tile.echoed_this_word = true
			tile_to_process.reparent(%RackedTiles)
			GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.ECHOING)
			tile_to_process.juice_notch(1)
			_send_back_to_rack(tile_to_process)
		
		
		elif tile_to_process.tile.notch2 == LetterTile.NotchTypes.ECHOING \
		and tile_to_process.tile.echo2 and not tile_to_process.tile.echoed_this_word:
			tile_to_process.tile.echo2 = false
			tile_to_process.tile.echoed_this_word = true
			tile_to_process.reparent(%RackedTiles)
			GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.ECHOING)
			tile_to_process.juice_notch(2)
			_send_back_to_rack(tile_to_process)
			
		elif tile_to_process.tile.notch3 == LetterTile.NotchTypes.ECHOING \
		and tile_to_process.tile.echo3 and not tile_to_process.tile.echoed_this_word:
			tile_to_process.tile.echo3 = false
			tile_to_process.tile.echoed_this_word = true
			tile_to_process.reparent(%RackedTiles)
			GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.ECHOING)
			tile_to_process.juice_notch(3)
			_send_back_to_rack(tile_to_process)
		## END INFO: PLAYER NOTCH ONLY
		
		## QUESTION: Is this even going to be relevant to enemies?
		# Being a ghost overrides all other destructive effects.
		elif tile_to_process.tile.is_ghost:
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(%TilesToKill)
			tile_to_process.is_destroyed()
		
		# Vaporization.
		elif tile_to_process.tile.notch1 == LetterTile.NotchTypes.VAPORIZING \
		or tile_to_process.tile.notch2 == LetterTile.NotchTypes.VAPORIZING \
		or tile_to_process.tile.notch3 == LetterTile.NotchTypes.VAPORIZING:
			print("Vaporizing...")
			vaporized_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(%TilesToKill)
			#current_deck.remove_at(tile_to_process.tile.tile_index) # TODO: Figure out how to do this correctly.
			tiles_in_play.erase(tile_to_process.tile)
			
			if tile_to_process.tile.notch1 == LetterTile.NotchTypes.VAPORIZING:
				tile_to_process.juice_notch(1)
			if tile_to_process.tile.notch1 == LetterTile.NotchTypes.VAPORIZING:
				tile_to_process.juice_notch(2)
			if tile_to_process.tile.notch1 == LetterTile.NotchTypes.VAPORIZING:
				tile_to_process.juice_notch(3)
			
			tile_to_process.is_destroyed() # TODO: Replace with unique effect.
			## TODO: If sender is Enemy, remove this tile from the attack's list of tiles.
		
		## QUESTION: Is this even going to be relevant to enemies?
		# Deletion of temps.
		elif tile_to_process.tile.is_temporary:
			vaporized_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(%TilesToKill)
			tiles_in_play.erase(tile_to_process.tile)
			tile_to_process.is_destroyed() # TODO: Replace with unique effect.
		
		# Crumbling.
		elif tile_to_process.tile.type == LetterTile.TileType.CRUMBLING:
			print("Crumbling!")
			destroyed_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.reparent(%TilesToKill)
			tiles_in_play.erase(tile_to_process.tile)
			tile_to_process.is_destroyed() # TODO: Replace with unique effect.
			## TODO: If sender is Enemy, remove this tile from the attack's list of tiles.
		
		else:
			tile_to_process.reparent(%TilesToKill)
			tiles_in_play.erase(tile_to_process.tile)
		
		## INFO: PLAYER NOTCH ONLY
		if tile_to_process.tile.notch1 == LetterTile.NotchTypes.WEIGHTED \
		or tile_to_process.tile.notch2 == LetterTile.NotchTypes.WEIGHTED \
		or tile_to_process.tile.notch3 == LetterTile.NotchTypes.WEIGHTED:
			if tile_to_process.tile.echo1 == false \
			and tile_to_process.tile.echo2 == false \
			and tile_to_process.tile.echo3 == false \
			and tile_to_process.tile.no_buffer == false \
			and tile_to_process.tile.vaporized == false:
				
				GameEventHandler.play_tile_notch_sound.emit(LetterTile.NotchTypes.WEIGHTED)
				
				if tile_to_process.tile.notch1 == LetterTile.NotchTypes.WEIGHTED:
					tile_to_process.juice_notch(1)
				if tile_to_process.tile.notch2 == LetterTile.NotchTypes.WEIGHTED:
					tile_to_process.juice_notch(2)
				if tile_to_process.tile.notch3 == LetterTile.NotchTypes.WEIGHTED:
					tile_to_process.juice_notch(3)

				await get_tree().create_timer(0.1).timeout
		## END INFO: PLAYER NOTCH ONLY
	
	total_score = int(floor(total_score))
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	
	## INFO: PLAYER ONLY
	GeneralManager.played_words_dict[word] = total_score
	## END INFO: PLAYER ONLY
	
	await get_tree().create_timer(0.25).timeout
	
	_cleanup(total_score, word_target)

func _cleanup(total_score, word_target):
	## INFO: PLAYER ONLY
	# Make the bag look pretty just before the tiles go into it.
	GameEventHandler.disable_tile_bag.emit(true)
	## END INFO: PLAYER ONLY
	
	for i in %TilesToKill.get_child_count():
		var last_letter = %TilesToKill.get_child(i) as GridTile

		if last_letter == null:
			print("UH OH! FUCKY WUCKY!")
			continue
		
		last_letter.remove_from_group("Tiles In Word")
		
		## TODO: Put a section here for handling enemy tiles.
		
		## INFO: PLAYER ONLY
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
				
				last_letter.tile.target = Vector2(592.0, 16.0)
				last_letter.move_to_position(0.35)
				
				await get_tree().create_timer(0.075).timeout
		
		
		elif last_letter.tile.no_buffer == false and last_letter.tile.vaporized == false:
			buffered_tiles.append(last_letter.tile)
			last_letter.z_index = 120
			last_letter.is_dying()
			last_letter.tile.target = Vector2(592.0, 16.0)
			last_letter.move_to_position(0.35)
			await get_tree().create_timer(0.075).timeout
		## END INFO: PLAYER ONLY
		
		else:
			pass

	_cleanup_killed_tiles() ## This is fine as-is
	
	allow_interaction = true ## INFO: Only if sender is Character.
	GameEventHandler.update_bag_tiles.emit() ## INFO: Only if sender is Character.
	_apply_score_to_target(total_score, word_target, word)
	letters_from_tiles.clear()
	_word_from_tiles(letters_from_tiles)
	_move_tiles_into_place() ## INFO: Only if sender is Character?
	GameEventHandler.disable_tile_bag.emit(false)
	
func _move_tiles_into_place():
	GameEventHandler.disable_tile_bag.emit(true)
	var remaining_tiles = []
	tiles_in_play.clear()
	for i in %RackedTiles.get_child_count():
		remaining_tiles.append(%RackedTiles.get_child(i).tile.grid_index)
		tiles_in_play.append(%RackedTiles.get_child(i).tile)
		%RackedTiles.get_child(i).tile.echoed_this_word = false
		
	remaining_tiles.sort()
	remaining_tiles.reverse()
	
	#!# Borrowed from https://forum.godotengine.org/t/how-can-i-sort-the-children-of-a-node/1409/2
	var sorted_nodes := %RackedTiles.get_children()

	sorted_nodes.sort_custom(
		# For descending order use > 0
		func(a: Node, b: Node): return a.name.naturalnocasecmp_to(b.name) > 0
		)

	for node in %RackedTiles.get_children():
		%RackedTiles.remove_child(node)

	for node in sorted_nodes:
		%RackedTiles.add_child(node)
	#!#

	for i in %RackedTiles.get_child_count():
		if GeneralManager.is_combat_active == false or end_of_combat == true:
			return
		var found_tile = %RackedTiles.get_child(i)
		if found_tile.tile.grid_index < 12:
			if found_tile.tile.grid_index < 4 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(found_tile.tile.grid_index / 4) * 32.0) + 296.0))
				remaining_tiles[i] += 4
				
			if found_tile.tile.grid_index < 8 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(found_tile.tile.grid_index / 4) * 32.0) + 296.0))
				remaining_tiles[i] += 4

			if found_tile.tile.grid_index < 12 && not remaining_tiles.has(found_tile.tile.grid_index + 4):
				found_tile.tile.grid_index += 4
				found_tile.tile.target = Vector2((((found_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(found_tile.tile.grid_index / 4) * 32.0) + 296.0))
				remaining_tiles[i] += 4
				
			else:
				pass
		await get_tree().create_timer(0.01).timeout
		found_tile.move_to_position()
	await get_tree().create_timer(0.01).timeout
		
	_spawn_replacement_tiles(remaining_tiles)
	GameEventHandler.disable_tile_bag.emit(false)

func _spawn_replacement_tiles(remaining_tiles):
	var tiles_to_fill = []
	
	for i in possible_grid_positions.size():
		if not remaining_tiles.has(possible_grid_positions[i]):
			tiles_to_fill.append(possible_grid_positions[i])
	
	tiles_to_fill.reverse()
	
	for i in (16 - %RackedTiles.get_child_count()):
		var grid_index = tiles_to_fill[i]
		_spawn_new_player_tile(grid_index)
		await get_tree().create_timer(0.04).timeout
		
	GeneralManager.scoring_is_active = false
		
	_rename_tiles()
	_check_turn_status()
	_tiles_in_word_update()
	GameEventHandler.update_bag_tiles.emit()
	
func _rename_tiles():
	for i in %RackedTiles.get_child_count():
		var temp_name = str("GridTile" + str(randi_range(100, 200)))
		%RackedTiles.get_child(i).set_name(temp_name)

	await get_tree().create_timer(0.04).timeout
	
	for i in %RackedTiles.get_child_count():
		if not %RackedTiles.get_child(i).name == str("GridTile"+str(%RackedTiles.get_child(i).tile.grid_index)):
			%RackedTiles.get_child(i).set_name(str("GridTile"+str(%RackedTiles.get_child(i).tile.grid_index)))

func _calc_raw_word_score():
	var tile_score
	var points_score = 0
	var mult_score = 0
	var raw_word_score = 0
	var word_length = 0
	for i in %TilesInWord.get_child_count():
		tile_score = %TilesInWord.get_child(i).score_tile_quiet()
		points_score += tile_score
		word_length += 1
		@warning_ignore("integer_division")
		mult_score = floor(word_length / 2)
		raw_word_score = points_score * mult_score
		
	%ScoreLabel.text = str(points_score) + "x" + str(mult_score) + "=" + str(raw_word_score)
	return raw_word_score
	
func _check_turn_status():
	if current_target == null:
		pass
	
	# No target is set.
	if not current_target is GameEntity:
		print("No target selected.")
		%PlayButton.texture_normal.region 	= Rect2(0.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 80.0, 128.0, 40.0)
	
	# No energy, but you have initiative. You can only end your turn.
	elif character_path.current_energy <= 0 and character_path.has_initiative:
		print("No energy.")
		%PlayButton.texture_normal.region 	= Rect2(0.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 40.0, 128.0, 40.0)
		%ShuffleButton.set_disabled(true)
		if allow_interaction:
			print("Turn can end.")
			%PlayButton.set_disabled(false)
	
	# Not your turn.
	elif not character_path.has_initiative:
		print("Not your turn.")
		%PlayButton.texture_normal.region 	= Rect2(0.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 40.0, 128.0, 40.0)
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(true)
	
	## TODO: Add states for Charmed, Target Immunity, and more later.
	
	# Your turn, and you have energy, and nothing is preventing you from playing a word.
	else:
		print("Not your turn.")
		%PlayButton.texture_normal.region 	= Rect2(0.0, 0.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 0.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 0.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(256.0, 0.0, 128.0, 40.0)
		if character_path.has_initiative:
			%ShuffleButton.set_disabled(false)

	_check_for_dead_enemies()
	
func _pass_turn():
	allow_interaction = false
	_check_turn_status()
	%PlayButton.set_disabled(true)
	var current_index = wrapi(combatant_array.find(who_has_initiative) + 1, 0, combatant_array.size())
	print("Current Index: " + str(current_index))
	
	# Perform start of turn procedures for whoever has the initiative.
	
	if who_has_initiative is Character:
		for i in current_relics.size():
			current_relics[i].on_turn_end()
		enemy_turn_count += 1
		%TurnCounterLabel.display_turn_text(enemy_turn_count, false)
		await get_tree().create_timer(1.5).timeout
		
		await who_has_initiative.on_turn_end(player_turn_count)
	
	elif who_has_initiative is Enemy:
		await who_has_initiative.on_turn_end(enemy_turn_count)

	who_has_initiative = combatant_array[current_index]
	
	if who_has_initiative is Character:
		player_turn_count += 1
		
		who_has_initiative.on_turn_start(player_turn_count)
		
		for i in current_relics.size():
			current_relics[i].on_turn_start()
			
		for i in tiles_in_play.size():
			tiles_in_play[i].current_age += 1

		%TurnCounterLabel.display_turn_text(player_turn_count, true)
		allow_interaction = true
		
		# Check the turn status for the player.
		_check_turn_status()
	
	elif who_has_initiative is Enemy:
		who_has_initiative.on_turn_start(enemy_turn_count)

func _on_entity_clicked(which: GameEntity, _action: GameEntity.GameEntityAction) -> void:
	for child in %Combatants.get_children():
		if child is Character or child is Enemy:
			child.is_target = false

	which.is_target = true

	for child in %Combatants.get_children():
		if child is Character or child is Enemy:
			child.target_query()
	
	if which is Enemy:
		_update_enemy_tooltip(which)

	current_target = which
	print(current_target.name)
	_tiles_in_word_update()
	_check_turn_status()
	
	
func _update_tile_graphics(affected_tile_indices):
	print("Updating Tile Graphics!")
	for i in %RackedTiles.get_child_count():
		if affected_tile_indices.has(%RackedTiles.get_child(i).tile.tile_index):
			%RackedTiles.get_child(i).update_tile_graphics()

## TODO: Split this off into its own Scene.
func _update_enemy_tooltip(enemy: Enemy, affected_tile_indices: Array = []):
	pass
	#if not current_enemy_tooltip == enemy and not affected_tile_indices.is_empty():
		#print("Failed to update tooltip!")
		#return
#
	#print("Updating Enemy Tooltip!")
	#for i in %EnemyAttackList.get_child_count():
		#%EnemyAttackList.get_child(i).queue_free()
			#
	#current_enemy_tooltip = enemy
	#%EnemyAttackList.add_spacer(true)
	#%EnemyAttackList.add_spacer(true)
	#
	#for i in enemy.enemy_attack_list.size():
		#sticky_target = enemy
		#var new_attack = HBoxContainer.new()
		#var new_info = HBoxContainer.new()
		#new_attack.set_alignment(BoxContainer.ALIGNMENT_BEGIN)
		#new_info.set_alignment(BoxContainer.ALIGNMENT_BEGIN)
		#%EnemyAttackList.add_child(new_attack)
		#%EnemyAttackList.add_child(new_info)
		#
		#for j in enemy.enemy_attack_list[i].size():
			#var current_attack = enemy.enemy_attack_list[i]
			#var new_tile = mini_grid_tile_scene.instantiate()
			#new_tile.tile = enemy.current_enemy_deck[current_attack[j]]
			#new_attack.add_child(new_tile)
			#if current_enemy_tooltip == enemy and affected_tile_indices.has(new_tile.tile.tile_index):
				#new_tile.update_tile_graphics()
		#
		#var attack_intent = intent_icon_scene.instantiate()
		#new_info.add_child(attack_intent)
		#attack_intent.type = IntentIcon.IntentType[enemy.enemy_attack_intents[i]]
		#attack_intent.update_intent_info()
		#
		#var attack_score_value = RichTextLabel.new()
		#attack_score_value.text = str(_calc_enemy_word_score(enemy, enemy.enemy_attack_list[i], enemy.enemy_attack_intents[i]))
		#attack_score_value.set_fit_content(true)
		#@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
		#attack_score_value.set_autowrap_mode(0)
		#attack_score_value.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		#new_info.add_child(attack_score_value)
		#
		#if not enemy.enemy_status_package_list.is_empty():
			#if not enemy.enemy_status_package_list[i].is_empty():
				#var status_package = enemy.enemy_status_package_list[i]
				#print("STATUS PACKAGE: " + str(status_package))
				#for j in status_package.size():
					#var subpackage = status_package[j]
					#print("STATUS SUBPACKAGE: " + str(subpackage))
					#var new_status = status_dictionary.get(subpackage[0])
					#var status_icon = status_effect_scene.instantiate()
					#status_icon.set_script(new_status)
					#new_info.add_child(status_icon)
					#status_icon.amount = subpackage[1]
					#status_icon.does_decay = bool(subpackage[2])
					#status_icon.duration = subpackage[3]
					#print("STATUS ID: " + str(status_icon.id))
					#status_icon._update_graphics()
		#if i < enemy.enemy_attack_list.size():
			#%EnemyAttackList.add_spacer(false)
			#%EnemyAttackList.add_spacer(false)
					
func _apply_score_to_target(total_score, word_target, scoring_word):
	if word_target is Character:
		word_target.gain_block(total_score, scoring_word) ## TODO: REMOVE THIS
			
	if word_target is Enemy:
		word_target.take_damage(total_score, scoring_word) ## TODO: REMOVE THIS
		var thorns_damage = word_target.query_status_value(11)
		if thorns_damage > 0:
			character_path.take_damage(thorns_damage, "THORNS_DAMAGE") ## TODO: REMOVE THIS

func _check_for_dead_enemies(_which: GameEntity = null, _reason: String = ""):
	var remaining_enemies = 0
	for i in %Combatants.get_child_count():
		if %Combatants.get_child(i) is Enemy:
			var current_enemy = %Combatants.get_child(i)
			if current_enemy.health > 0:
				print("Enemy Health: " + str(current_enemy.health))
				remaining_enemies += 1
	
			else:
				# TODO: Replace this once enemy death animations are a thing.
				combatant_array.remove_at(combatant_array.find(%Combatants.get_child(i)))
				if current_target == current_enemy:
					current_target = null
				current_enemy.queue_free()
	
	print("Remaining Enemies: " + str(remaining_enemies))
	print(GeneralManager.scoring_is_active)
	
	if remaining_enemies == 0 and not GeneralManager.scoring_is_active:
		on_combat_end()

func on_combat_end():
	GeneralManager.is_combat_active = false
	character_path.has_initiative = false
	GeneralManager.chapter_combat_clear_count += 1
	
	%ShuffleButton.set_disabled(true)
	%PlayButton.set_disabled(true)
	
	# TODO: add trigger for on_combat_end relics
	
	await _tiles_in_word_force_clear()
	
	for i in %RackedTiles.get_child_count():
		var current_tile = %RackedTiles.get_child(i)
		if current_tile.tile.notch1 == LetterTile.NotchTypes.GILDED or \
		current_tile.tile.notch2 == LetterTile.NotchTypes.GILDED or \
		current_tile.tile.notch3 == LetterTile.NotchTypes.GILDED:
			
			var tile_retriggers = 0
			
			if current_tile.tile.notch1 == LetterTile.NotchTypes.REPEATING:
				tile_retriggers += 1
			if current_tile.tile.notch2 == LetterTile.NotchTypes.REPEATING:
				tile_retriggers += 1
			if current_tile.tile.notch3 == LetterTile.NotchTypes.REPEATING:
				tile_retriggers += 1
	
			if current_tile.tile.notch1 == LetterTile.NotchTypes.GILDED:
				for j in tile_retriggers + 1:
					current_tile.juice_score()
					GameEventHandler.gold_changed.emit(5)
			
			if current_tile.tile.notch2 == LetterTile.NotchTypes.GILDED:
				for j in tile_retriggers + 1:
					current_tile.juice_score()
					GameEventHandler.gold_changed.emit(5)
					
			if current_tile.tile.notch3 == LetterTile.NotchTypes.GILDED:
				for j in tile_retriggers + 1:
					current_tile.juice_score()
					GameEventHandler.gold_changed.emit(5)
					
			await get_tree().create_timer(0.05).timeout
	
	# TODO: add trigger for on_combat_end Statuses
	
	character_path.clear_status_effects()
	character_path.current_energy = 0
	
	await get_tree().create_timer(1).timeout
	
	_flush_player_tiles()

	# Clear out all these arrays, sans the vaporized array.
	buffered_tiles.clear()
	destroyed_tiles.clear()
	available_tiles.clear()
	tiles_in_play.clear()
	
	%ShuffleButton.set_disabled(false)
	%PlayButton.set_disabled(false)
	
	GeneralManager.remove_tiles_from_deck()
	
	character_path.reparent(GeneralManager.replace_character_path)
	
	%CombatRewards._bringup_combat_rewards(new_encounter.reward_gold, new_encounter.reward_notch_count, new_encounter.reward_relics)

func _on_shuffle_button_pressed():
	if character_path.current_energy > 0:
		character_path.remove_energy(1)
		_shuffle_player_tiles()
		
func _shuffle_player_tiles():
	GameEventHandler.update_buffered_tiles.emit()
	%ShuffleButton.set_disabled(true)
	%PlayButton.set_disabled(true)
	get_node("ScoreLabel").text = ""
	tiles_in_play.clear()
	letters_from_tiles.clear()
	
	for i in %TilesInWord.get_child_count():
		var tile_to_push = %TilesInWord.get_child(-1)
	
		if tile_to_push.ghost_pair is GridTile:
			tile_to_push.ghost_pair.is_being_bagged()
	
		tile_to_push.reparent(%TilesToKill)
	
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
	
		## buffered_tiles is a list of the LetterTiles that are in the buffer area between played words and turns.
		if tiles_in_play.has(tile_to_push.tile):
			buffered_tiles.append(tile_to_push.tile)
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32.0) + 256.0), 420.0)
		tile_to_push_array.append(tile_to_push)
		tile_to_push.is_dying()
		tile_to_push.move_to_position()
	
	for i in %RackedTiles.get_child_count():
		## tile_to_push is a GridTile that will be deleted.
		var tile_to_push = %RackedTiles.get_child(-1)
	
		tile_to_push.reparent(%TilesToKill)
	
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
	
		if tile_to_push.tile.no_buffer == false:
			buffered_tiles.append(tile_to_push.tile)
			
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32.0) + 256.0), 420.0)
		tile_to_push_array.append(tile_to_push)
		tile_to_push.is_dying()
		tile_to_push.move_to_position()
	
	_cleanup_killed_tiles()
	
	await get_tree().create_timer(0.125).timeout
	
	for i in range(0, 16):
		var grid_index = 15 - i
		_spawn_new_player_tile(grid_index)
		GameEventHandler.update_bag_tiles.emit()
		await get_tree().create_timer(0.04).timeout

	%ShuffleButton.set_disabled(false)
	_check_turn_status()

func _flush_player_tiles():
	for i in %TilesInWord.get_child_count():
		var tile_to_push = %TilesInWord.get_child(-1)
		
		if tile_to_push.ghost_pair is GridTile:
			tile_to_push.ghost_pair.is_being_bagged()
	
		tile_to_push.reparent(%TilesToKill)
	
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
	
		## buffered_tiles is a list of the LetterTiles that are in the buffer area between played words and turns.
		if tiles_in_play.has(tile_to_push.tile):
			buffered_tiles.append(tile_to_push.tile)
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32.0) + 256.0), 420.0)
		tile_to_push_array.append(tile_to_push)
		tile_to_push.is_dying()
		tile_to_push.move_to_position()
	
	for i in %RackedTiles.get_child_count():
		## tile_to_push is a GridTile that will be deleted.
		var tile_to_push = %RackedTiles.get_child(-1)
	
		tile_to_push.reparent(%TilesToKill)
	
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
	
		if tile_to_push.tile.no_buffer == false:
			buffered_tiles.append(tile_to_push.tile)
			
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32.0) + 256.0), 420.0)
		tile_to_push_array.append(tile_to_push)
		tile_to_push.is_dying()
		tile_to_push.move_to_position()
	
	_cleanup_killed_tiles()

func _on_tile_bag_toggle(toggled_on):
	bag_open = toggled_on
	if toggled_on:
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(true)
	if not toggled_on:
		%ShuffleButton.set_disabled(false)
		if character_path.current_energy > 0:
			_word_from_tiles(letters_from_tiles)
		elif character_path.current_energy <= 0 and character_path.has_initiative:
			%PlayButton.set_disabled(false)
		elif character_path.current_energy <= 0 and not character_path.has_initiative:
			%PlayButton.set_disabled(true)

func _cleanup_killed_tiles():
	await get_tree().create_timer(0.5).timeout
	for i in %TilesToKill.get_child_count():
		var killed_tile = %TilesToKill.get_child(-1)
		killed_tile.free()
	
func _on_kill_button_pressed() -> void:
	for i in %Combatants.get_child_count():
		if %Combatants.get_child(i) is Enemy:
			%Combatants.get_child(i).lose_health(%Combatants.get_child(i).max_health)
