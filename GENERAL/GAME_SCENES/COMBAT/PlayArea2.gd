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

## modified_wordlist is the list of words that has been added to by various Relics.
var modified_wordlist := []

## scored_letter_count is the sum total of the numbers that have been scored.
var scored_tile_count = GeneralManager.scored_letter_count

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

## relic_dictionary is a list of every relic in the game.
var relic_dictionary = RelicDictionary.RelicList

## status_dictionary is a list of every status effect in the game.
var status_dictionary = StatusDictionary.StatusEffectList

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

## Don't ask.
var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

## bag_open determines if the Tile Bag is open or not.
var bag_open := false

## scoring_check determines if a word is currently being played. It prevents you from adding letters to a word while it's being played.
var scoring_check := false

## sticky_target is the Enemy whose tiles are currently shown in the enemy attack list
var sticky_target = null

## This is here while I try and figure out a good way to end combat.
var end_of_combat = false

@export var grid_tile_scene: PackedScene = preload("res://TILE/GRID_TILE/GridTile.tscn")
@export var mini_grid_tile_scene: PackedScene = preload("res://TILE/GRID_TILE/MiniGridTile.tscn")
@export var status_effect_scene: PackedScene = preload("res://COMBAT/STATUSES/StatusEffect.tscn")
@export var intent_icon_scene: PackedScene = preload("res://COMBAT/GAME_ENTITY/IntentIcon.tscn")
var relic_scene = preload("res://RELIC/Relic.tscn")

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

## sine_timer is the timer for the sine wave pattern of tiles in your played word.
var sine_timer = 0

signal update_bag_tiles()
signal update_buffered_tiles()
signal disable_tile_bag(state)
signal enemy_attack_finished()
signal tile_tooltip_requested(which)
signal tile_mini_tooltip_requested(which)
signal tile_tooltip_hide_requested()

func _ready():
	
	# Clear ALL of these before we even start combat, just to be safe.
	current_combat_deck.clear()
	available_tiles.clear()
	buffered_tiles.clear()
	tiles_in_play.clear()
	destroyed_tiles.clear()
	vaporized_tiles.clear()
	
	# Clone the player's deck into these arrays
	for i in current_deck.size():
		current_combat_deck.append(current_deck[i])
		available_tiles.append(current_deck[i])
		
		if current_deck[i].notch1 == LetterTile.NotchTypes.EAGER \
		or current_deck[i].notch2 == LetterTile.NotchTypes.EAGER \
		or current_deck[i].notch3 == LetterTile.NotchTypes.EAGER:
			priority_draw_list.append(current_deck[i])
	
	# Give the player character the first turn, then pull him into the scene.
	who_has_initiative = character_path
	character_path.has_initiative = true
	character_path.reparent(combatants)
	character_path.update_buffered_tiles.connect(self._update_buffered_tiles_call)
	character_path.update_tile_graphics.connect(self._update_tile_graphics)
	
	## Making space here to drag enemies from within the Encounter to the inside of the Combatants node
	
	for i in %Combatants.get_child_count():
		# For ALL Combatants
		%Combatants.get_child(i).entity_clicked.connect(self._on_entity_clicked)
		
		if %Combatants.get_child(i) is Enemy:
			%Combatants.get_child(i).entity_hovered.connect(%EnemyTooltip._on_enemy_hovered)
			%Combatants.get_child(i).perform_attack.connect(self._spawn_new_enemy_word)
			%Combatants.get_child(i).pass_turn.connect(self._pass_turn)
			%Combatants.get_child(i).update_tooltip_tile_graphics.connect(self._update_tooltip_tile_graphics)
			self.enemy_attack_finished.connect(%Combatants.get_child(i)._perform_next_attack)
			%Combatants.get_child(i).plan_next_turn()
	
	on_combat_start()
	_check_turn_status()
	tile_tooltip_hide_requested.emit()

func _process(delta: float) -> void:
	var sine_tiles = get_tree().get_nodes_in_group("Tiles In Word")
	if sine_tiles.size() > 0:
		sine_timer += delta
		var phase = sine_timer * PI
		#print(0.1 * sin(phase))
		for i in sine_tiles.size():
			sine_tiles[i].position.x = float(sine_tiles[i].position.x + (0.1 * cos(phase + (0.33 * i))))
			sine_tiles[i].position.y = float(sine_tiles[i].position.y + (0.1 * sin(phase + (0.33 * i))))

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_BACKSPACE:
				for tile: GridTile in racked_tiles.get_children():
					if tile.hovering:
						tile.scale = self.scale / 1.1
						tile.z_index = tile.original_z
						tile.tile_hovered.emit(tile, false)
						return;
				if tiles_in_word.get_children().size() > 0:
					await _send_back_to_grid(tiles_in_word.get_child(-1))
					tiles_in_word.get_child(-1).reparent(racked_tiles)
					_tiles_in_word_update()
					await get_tree().create_timer(0.004).timeout
					_normalize_grid_tile_size()
				return;
			var string_letter = event.as_text().to_upper()
			var tile_list = [];
			for tile: GridTile in racked_tiles.get_children():
				if tile.tile.TileLetter.keys()[tile.tile.played_letter] == string_letter:
					tile_list.push_back(tile);
				elif tile.hovering:
					tile.scale = self.scale / 1.1
					tile.z_index = tile.original_z
					tile.tile_hovered.emit(tile, false)
					tile.play_tile_sound()
					tile.tile_clicked.emit(
						tile, tile.GridTileAction.PLAY
					)

			tile_list.sort_custom(func(a,b): return a.tile.grid_index < b.tile.grid_index);
			var start_index = -1;
			var end_index = -1;
			for tile in tile_list:
				end_index = tile.tile.grid_index;
				if tile.hovering:
					tile.tile_hovered.emit(tile, false)
					start_index = tile.tile.grid_index;

			for tile in tile_list:
				if start_index < end_index && start_index < tile.tile.grid_index:
					tile.original_z = tile.z_index
					tile.scale = tile.scale * 1.1
					tile.z_index = 128
					tile.tile_hovered.emit(tile, true)
					break;

func on_combat_start():
	GeneralManager.is_combat_active = true
	character_path.on_turn_start()
	character_path.target_query()
	
	for i in current_relics.size():
		current_relics[i].on_combat_start()
		current_relics[i].on_turn_start()

	for i in current_combat_deck.size():
		if current_combat_deck[i].notch1 == LetterTile.NotchTypes.REJUVENATING:
			current_combat_deck[i].heal1 = false
		if current_combat_deck[i].notch2 == LetterTile.NotchTypes.REJUVENATING:
			current_combat_deck[i].heal2 = false
		if current_combat_deck[i].notch3 == LetterTile.NotchTypes.REJUVENATING:
			current_combat_deck[i].heal3 = false
			
	
	_populate_rack()

func _populate_rack():
	for i in range(0, 16):
		var grid_index = 15 - i
		_spawn_new_player_tile(grid_index)
		await get_tree().create_timer(0.04).timeout

func _update_buffered_tiles_call():
	GameEventHandler.update_buffered_tiles.emit()

func _spawn_new_player_tile(grid_index: int):
	if GeneralManager.is_combat_active == false:
		return
	
	if available_tiles.size() > 0:
		## added_tile is a GridTile with the data from a LetterTile
		var added_tile = grid_tile_scene.instantiate()
		var called_tile = LetterTile
		
		if not priority_draw_list.is_empty():
			called_tile = priority_draw_list.pop_back()
			available_tiles.pop_at(called_tile.tile_index)
		
		else:
			## called_tile is a LetterTile
			called_tile = available_tiles.pop_at(tile_rng.randi() % available_tiles.size())
		
		called_tile.current_age = 0
		# Add the LetterTile to the GridTile so it has data
		added_tile.tile = called_tile
		
		# Append the called_tile to the tiles_in_play array, add the added_tile to the tile_grid
		tiles_in_play.append(called_tile)
		racked_tiles.add_child(added_tile)
		
		added_tile.spawned_in()
		
		# Give it a grid index,
		added_tile.tile.grid_index = grid_index
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
		added_tile.position = Vector2((((added_tile.tile.grid_index % 4 ) * 32.0) + 256.0), 264.0)
		added_tile.tile.target = Vector2((((added_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(added_tile.tile.grid_index / 4) * 32.0) + 296.0))
		# Based on the index, we tell it what column to drop from, and it spawns above.
		
		added_tile.spawned_in()
		await added_tile.move_to_position()
		added_tile.play_tile_sound()
		GameEventHandler.update_bag_tiles.emit()
	
	else:
		return

# TODO: REWORK THIS
func _spawn_new_enemy_word(attack_to_perform, attack_letter_tiles, status_package, _pivot_position, target, attacker):
	
	print(target)
	
	var enemy_letters = []
	var tile_score 			= 0
	var mult_score 			= 0
	var points_score 		= 0
	var total_score 		= 0
	var tile_score_count	= 0
	var word_length 		= 0
	var context_power 		= 0
	var bonus_word_length	= 0

	if target == "SELF" or target == "OTHER":
		# Query Dexterity
		context_power += attacker.query_status_value(13)
		# Query Intelligence
		bonus_word_length += attacker.query_status_value(14)

	if target == "PLAYER":
		# Query Strength
		context_power += attacker.query_status_value(12)

	for i in attack_to_perform.size():
		if attack_letter_tiles[i].type == LetterTile.TileType.LOCKED:
			continue
		
		var added_tile = grid_tile_scene.instantiate()
		added_tile.tile = attack_letter_tiles[i]
		added_tile.tile.is_friendly = false
		
		tiles_in_word.add_child(added_tile)
		enemy_letters.append(added_tile)
		added_tile.position = _pivot_position
		added_tile.spawned_in()
		
		if tiles_in_word.get_child_count() == 1:
			added_tile.tile.target = Vector2(302.0, 120.0)
			
		else:
			added_tile.tile.target = Vector2(tiles_in_word.get_child(0).tile.target.x + (38.0 * float(i)), 120.0)
		
		await added_tile.move_to_position()
		added_tile.add_to_group("Tiles In Word")
		
		added_tile.play_tile_sound()
		_tiles_in_word_update()
		await get_tree().create_timer(0.04).timeout
	
	await get_tree().create_timer(0.4).timeout
	
	for i in tiles_in_word.get_child_count():
		tile_score = enemy_letters[i].score_tile(tile_score_count)
		tile_score += context_power
		tile_score_count += 1
		word_length += 1
		points_score += tile_score
		
		mult_score = floor(word_length / 2)
		
		total_score = points_score * mult_score
		get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
		
		await get_tree().create_timer(0.075).timeout
		
	if bonus_word_length > 0:
		for i in bonus_word_length:
			mult_score = floor(word_length / 2)
			
			total_score = points_score * mult_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)

		total_score = points_score * mult_score
		get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
		await get_tree().create_timer(0.075).timeout
	
	if target == "PLAYER":
		var damage = total_score
		character_path.take_damage(damage)
		
	elif target == "SELF":
		%TestEnemy.gain_block(total_score)
		
	else:
		var damage = total_score
		character_path.take_damage(damage)
	
	if not status_package.is_empty():
		for i in status_package.size():
			print(status_package)
			var subpackage = status_package[i]
			print(subpackage)
			var status_name = subpackage[0]
			var amount = subpackage[1]
			var decay_type = subpackage[2]
			var duration = subpackage[3]
			
			if subpackage[4] == "PLAYER":
				character_path.add_status(status_name, amount, decay_type, duration)
			
			if subpackage[4] == "SELF":
				attacker.add_status(status_name, amount, decay_type, duration)
		
	await get_tree().create_timer(1.25).timeout
	
	for i in tiles_in_word.get_child_count():
		tiles_in_word.get_child(-1).tile.target = _pivot_position
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
		
		letters_from_tiles.append(str(tiles_in_word.get_child(i).tile.TileLetter.keys()[tiles_in_word.get_child(i).tile.played_letter]).to_snake_case())
		
		tiles_in_word.get_child(i).tile.word_index = i
		tiles_in_word.get_child(i).tile.word_length = tiles_in_word.get_child_count()
		
		if tiles_in_word.get_child_count() <= 6:
			
			scaling_factor = 1
			tiles_in_word.get_child(0).tile.target = Vector2(302.0 - (19.0 * float(tiles_in_word.get_child_count()-1)), 120.0)
			tiles_in_word.get_child(i).tile.target = Vector2(tiles_in_word.get_child(0).tile.target.x + (38.0 * float(i)), 120.0)
			tiles_in_word.get_child(i).scale_to_word_size(scaling_factor)
			tiles_in_word.get_child(i).move_to_position(0.35)

		if tiles_in_word.get_child_count() > 6:
			
			tiles_in_word.get_child(0).tile.target = Vector2(302.0 - (19.0 * float(tiles_in_word.get_child_count()-1))*scaling_factor, 120.0)
			tiles_in_word.get_child(i).tile.target = Vector2(tiles_in_word.get_child(0).tile.target.x + (38.0 * float(i))*scaling_factor, 120.0)
			tiles_in_word.get_child(i).scale_to_word_size(scaling_factor)
			tiles_in_word.get_child(i).move_to_position(0.35)
	
	_calc_raw_word_score()
	
	print(letters_from_tiles)
	_normalize_grid_tile_size()
	
	if character_path.current_energy > 0:
		_word_from_tiles(letters_from_tiles)

func _tiles_in_word_cascade_clear(grid_tile: GridTile):
	var tile_clicked = grid_tile.get_index()
	var total_tiles = tiles_in_word.get_child_count()
	var difference = total_tiles - tile_clicked
	for i in difference:
		_send_back_to_grid(tiles_in_word.get_child(-1))
		tiles_in_word.get_child(-1).reparent(racked_tiles)
		_tiles_in_word_update()
		await get_tree().create_timer(0.004).timeout
	_normalize_grid_tile_size()

func _tiles_in_word_force_clear():
	for i in tiles_in_word.get_child_count():
		_send_back_to_grid(tiles_in_word.get_child(-1))
		tiles_in_word.get_child(-1).reparent(racked_tiles)
		_tiles_in_word_update()
		await get_tree().create_timer(0.004).timeout
	return true

func _send_back_to_grid(grid_tile: GridTile):
	grid_tile.toggle_word_glow()
	grid_tile.remove_from_group("Tiles In Word")
	grid_tile.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4) * 32.0) + 296.0))
	grid_tile.tile.word_index = 0
	grid_tile.tile.word_length = 0
	grid_tile.move_to_position(0.35)
	grid_tile.scale_back_to_grid()
	
	if not grid_tile.ghost_pair == null: 
		grid_tile.ghost_pair.queue_free()
	
	if grid_tile.paired_tile_1 is GridTile:
		if grid_tile.paired_tile_1.tile.is_ghost:
			grid_tile.paired_tile_1.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4) * 32.0) + 296.0))
			grid_tile.paired_tile_1.move_to_position(0.35)
			grid_tile.paired_tile_1.scale_back_to_grid()
			grid_tile.paired_tile_1.reparent(tiles_to_kill)
			grid_tile.paired_tile_1.tile_clicked.disconnect(self._on_tile_clicked)
			grid_tile.paired_tile_1.tile_hovered.disconnect(self._is_tile_hovered)
			grid_tile.paired_tile_1.is_vanishing()
			grid_tile.paired_tile_1 = null
			
	if grid_tile.paired_tile_2 is GridTile:
		if grid_tile.paired_tile_2.tile.is_ghost:
			grid_tile.paired_tile_2.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4) * 32.0) + 296.0))
			grid_tile.paired_tile_2.move_to_position(0.35)
			grid_tile.paired_tile_2.scale_back_to_grid()
			grid_tile.paired_tile_2.reparent(tiles_to_kill)
			grid_tile.paired_tile_2.tile_clicked.disconnect(self._on_tile_clicked)
			grid_tile.paired_tile_2.tile_hovered.disconnect(self._is_tile_hovered)
			grid_tile.paired_tile_2.is_vanishing()
			grid_tile.paired_tile_2 = null
			
	if grid_tile.paired_tile_3 is GridTile:
		if grid_tile.paired_tile_3.tile.is_ghost:
			grid_tile.paired_tile_3.tile.target = Vector2((((grid_tile.tile.grid_index % 4) * 32.0) + 256.0),((floor(grid_tile.tile.grid_index / 4) * 32.0) + 296.0))
			grid_tile.paired_tile_3.move_to_position(0.35)
			grid_tile.paired_tile_3.scale_back_to_grid()
			grid_tile.paired_tile_3.reparent(tiles_to_kill)
			grid_tile.paired_tile_3.tile_clicked.disconnect(self._on_tile_clicked)
			grid_tile.paired_tile_3.tile_hovered.disconnect(self._is_tile_hovered)
			grid_tile.paired_tile_3.is_vanishing()
			grid_tile.paired_tile_3 = null

	_normalize_grid_tile_size()
	_cleanup_killed_tiles()
	return true

func _on_tile_clicked(which: GridTile, action: GridTile.GridTileAction):
	if scoring_check == false and bag_open == false and GeneralManager.is_map_open == false and character_path.has_initiative == true \
	and which.tile.is_friendly and not which.tile.type == LetterTile.TileType.LOCKED:
		if action == GridTile.GridTileAction.PLAY:
			
			if which.get_parent() == racked_tiles:
				var ghost_tile = which.tile
				if not which.tile.is_ghost:
					var new_ghost = LetterTile.new().new_tile(ghost_tile.type, ghost_tile.true_letter, ghost_tile.notch1, ghost_tile.notch2, ghost_tile.notch3, -1, true)
					var rack_ghost = grid_tile_scene.instantiate()
					rack_ghost.tile = new_ghost
					rack_ghost.grid_ghost = true
					which.ghost_pair = rack_ghost
					rack_ghost.ghost_pair = which
					%GhostParent.add_child(rack_ghost)
					rack_ghost.tile_hovered.connect(self._is_tile_hovered)
					rack_ghost.tile_clicked.connect(self._on_tile_clicked)
					rack_ghost.position = Vector2((((which.tile.grid_index % 4) * 32.0) + 256.0),((floor(which.tile.grid_index / 4) * 32.0) + 296.0))
				which.reparent(tiles_in_word, true)
				
				if which.tile.notch1 == LetterTile.NotchTypes.LEXICAL:
					# Create new LetterTile
					var lex_letter_1 = letters.find(str(which.tile.bonus_letter1))
					print(lex_letter_1)
					var lex_tile_1 = LetterTile.new().new_tile(which.tile.type, lex_letter_1, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, -1, true)
					# Create new GridTile
					var ghost_tile_1 = grid_tile_scene.instantiate()
					# Bind new LetterTile to new GridTile
					ghost_tile_1.tile = lex_tile_1
					ghost_tile_1.tile.grid_index = which.tile.grid_index
					# Pair it with the GridTile that spawned it
					which.paired_tile_1 = ghost_tile_1
					ghost_tile_1.paired_tile_1 = which
					# Pose it to the position of the original grid tile
					ghost_tile_1.z_index = which.z_index
					
					%GhostParent.add_child(ghost_tile_1)
					ghost_tile_1.position = which.position
					ghost_tile_1.reparent(tiles_in_word, true)
					ghost_tile_1.add_to_group("Tiles In Word")
					ghost_tile_1.tile_clicked.connect(self._on_tile_clicked)
					ghost_tile_1.tile_hovered.connect(self._is_tile_hovered)
					
				if which.tile.notch2 == LetterTile.NotchTypes.LEXICAL:
					# Create new LetterTile
					var lex_letter_2 = letters.find(str(which.tile.bonus_letter2))
					print(lex_letter_2)
					var lex_tile_2 = LetterTile.new().new_tile(which.tile.type, lex_letter_2, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, -1, true)
					# Create new GridTile
					var ghost_tile_2 = grid_tile_scene.instantiate()
					# Bind new LetterTile to new GridTile
					ghost_tile_2.tile = lex_tile_2
					ghost_tile_2.tile.grid_index = which.tile.grid_index
					# Pair it with the GridTile that spawned it
					which.paired_tile_2 = ghost_tile_2
					ghost_tile_2.paired_tile_2 = which
					# Pose it to the position of the original grid tile
					ghost_tile_2.z_index = which.z_index
					
					%GhostParent.add_child(ghost_tile_2)
					ghost_tile_2.position = which.position
					ghost_tile_2.reparent(tiles_in_word, true)
					ghost_tile_2.add_to_group("Tiles In Word")
					ghost_tile_2.tile_clicked.connect(self._on_tile_clicked)
					ghost_tile_2.tile_hovered.connect(self._is_tile_hovered)
					
				if which.tile.notch3 == LetterTile.NotchTypes.LEXICAL:
					# Create new LetterTile
					var lex_letter_3 = letters.find(str(which.tile.bonus_letter3))
					print(lex_letter_3)
					var lex_tile_3 = LetterTile.new().new_tile(which.tile.type, lex_letter_3, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, -1, true)
					# Create new GridTile
					var ghost_tile_3 = grid_tile_scene.instantiate()
					# Bind new LetterTile to new GridTile
					ghost_tile_3.tile = lex_tile_3
					ghost_tile_3.tile.grid_index = which.tile.grid_index
					# Pair it with the GridTile that spawned it
					which.paired_tile_3 = ghost_tile_3
					ghost_tile_3.paired_tile_3 = which
					# Pose it to the position of the original grid tile
					ghost_tile_3.z_index = which.z_index
					
					%GhostParent.add_child(ghost_tile_3)
					ghost_tile_3.reparent(tiles_in_word, true)
					ghost_tile_3.add_to_group("Tiles In Word")
					ghost_tile_3.position = which.position
					ghost_tile_3.tile_clicked.connect(self._on_tile_clicked)
					ghost_tile_3.tile_hovered.connect(self._is_tile_hovered)
				
				which.add_to_group("Tiles In Word")
				_tiles_in_word_update()
			
			elif which.get_parent() == tiles_in_word:
				if which.tile.notch1 == LetterTile.NotchTypes.LEXICAL and which.paired_tile_1 is GridTile:
					# If this tile is not a ghost, but the paired tile is, kill the paired tile and send this one back to the rack.
					if which.paired_tile_1.tile.is_ghost:
						#_send_back_to_grid(which.paired_tile_1)
						pass
						#which.paired_tile_1.queue_free()
					# If this tile is a ghost and is paired to a non-ghost, kill this tile and send the other back to the rack.
					# WARNING: Wait. This shouldn't even be possible!!!!!
					elif which.tile.is_ghost:
						which.paired_tile_1.reparent(racked_tiles, true)
						_send_back_to_grid(which.paired_tile_1)
						#which.queue_free()
					# Fallback procedure? Fuck.
					else:
						which.reparent(racked_tiles, true)
						_send_back_to_grid(which)
						
				if which.tile.notch2 == LetterTile.NotchTypes.LEXICAL and which.paired_tile_2 is GridTile:
					if which.paired_tile_2.tile.is_ghost:
						#_send_back_to_grid(which.paired_tile_2)
						pass
						#which.paired_tile_2.queue_free()
					elif which.tile.is_ghost:
						which.paired_tile_2.reparent(racked_tiles, true)
						_send_back_to_grid(which.paired_tile_2)
						#which.queue_free()
					else:
						which.reparent(racked_tiles, true)
						_send_back_to_grid(which)
						
				if which.tile.notch3 == LetterTile.NotchTypes.LEXICAL and which.paired_tile_3 is GridTile:
					if which.paired_tile_3.tile.is_ghost:
						#_send_back_to_grid(which.paired_tile_3)
						pass
						#which.paired_tile_3.queue_free()
					elif which.tile.is_ghost:
						which.paired_tile_3.reparent(racked_tiles, true)
						_send_back_to_grid(which.paired_tile_3)
						#which.queue_free()
					else:
						which.reparent(racked_tiles, true)
						_send_back_to_grid(which)
				
				if which.tile.is_ghost:
					if which.paired_tile_1 is GridTile:
						which.reparent(racked_tiles, true)
						which.paired_tile_1.reparent(racked_tiles, true)
						_send_back_to_grid(which.paired_tile_1)
					
					if which.paired_tile_2 is GridTile:
						which.reparent(racked_tiles, true)
						which.paired_tile_2.reparent(racked_tiles, true)
						_send_back_to_grid(which.paired_tile_2)
						
					if which.paired_tile_3 is GridTile:
						which.reparent(racked_tiles, true)
						which.paired_tile_3.reparent(racked_tiles, true)
						_send_back_to_grid(which.paired_tile_3)
					
				else:
					which.reparent(racked_tiles, true)
					_send_back_to_grid(which)
				
				_tiles_in_word_update()
				
			elif which.get_parent() == %GhostParent and which.grid_ghost:
				_on_tile_clicked(which.ghost_pair, GridTile.GridTileAction.PLAY)

		if action == GridTile.GridTileAction.VIEW:
		
			if which.get_parent() == racked_tiles:
				pass
				
			elif which.get_parent() == tiles_in_word and not which.tile.is_ghost:
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
			get_tree().call_group("Tiles In Word", "toggle_word_glow", true)
			print("Tweening!")
			
		elif not is_word:
			get_node("WordLabel").text = ""
			get_node("PlayButton").set_disabled(true)
			get_tree().call_group("Tiles In Word", "toggle_word_glow")
			print("Untweening! 1")
			
	else:
		get_node("WordLabel").text = ""
		get_node("PlayButton").set_disabled(true)
		get_tree().call_group("Tiles In Word", "toggle_word_glow")
		print("Untweening! 2")
			
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
	if character_path.has_initiative and character_path.current_energy > 0:
		_score_word()
	else:
		await _tiles_in_word_force_clear()
		_pass_turn()

func _score_word():
	var word_target = current_target
	
	scoring_check = true
	get_node("PlayButton").set_disabled(true)
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
	
	character_path.remove_energy(1)
	
	# If there are any effects that would retrigger the scoring of the word, they'll be processed here.
	# If there's any effects with context-based power, they should also go here.
	# i.e. checking a word type belongs in this category
	for i in current_relics.size():
		word_retriggers += current_relics[i].word_retrigger_effect(word)
		context_power += current_relics[i].word_tile_bonus_score_effect(word)
	
	if word_target is Enemy:
		# Query Player Strength
		context_power += character_path.query_status_value(12)
	
	if word_target is Character:
		# Query Player Dexterity
		context_power += character_path.query_status_value(13)
		
	bonus_word_length += character_path.query_status_value(14)
	
	for i in word_retriggers + 1:
		
		for j in tiles_in_word.get_child_count():
			
			var scored_tile = tiles_in_word.get_child(j)
			word_length += 1
			
			if scored_tile.ghost_pair is GridTile:
				scored_tile.ghost_pair.is_being_bagged()
				scored_tile.ghost_pair = null
				
			scored_tile.toggle_word_glow()
			
			for k in current_relics.size():
				
				# Pull any letter retrigger effects from relics
				tile_retriggers += current_relics[k].letter_retrigger_effect(scored_tile.tile.played_letter, word)
					
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
				tile_score +=  await scored_tile.score_tile(tile_score_count)
				tile_score += context_power
				tile_score_count += 1
				scored_tile_count += 1
				
				%TileScoreLabel.text = str(tile_score)
				# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
				
				await get_tree().create_timer(0.025).timeout
				
				# Pull any bonus point effects from relics.
				for l in current_relics.size():
					
					# Grid index based effects
					tile_score += current_relics[l].grid_index_effect(scored_tile.tile.grid_index, word)
					%TileScoreLabel.text = str(tile_score)
					# TODO: Add a thing that shows the total score of a letter as it iterates through scoring.
					
					# Letter based effects
					tile_score += current_relics[l].letter_score_effect(scored_tile.tile.played_letter, word)
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
						var new_clone = LetterTile.new().new_tile(cloned_tile.type, cloned_tile.true_letter, cloned_tile.notch1, cloned_tile.notch2, cloned_tile.notch3, -1)
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
						var new_clone = LetterTile.new().new_tile(cloned_tile.type, cloned_tile.true_letter, cloned_tile.notch1, cloned_tile.notch2, cloned_tile.notch3, -1)
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
						var new_clone = LetterTile.new().new_tile(cloned_tile.type, cloned_tile.true_letter, cloned_tile.notch1, cloned_tile.notch2, cloned_tile.notch3, -1)
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
					character_path.gain_block(5)
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.REINFORCED:
					character_path.gain_block(5)
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.REINFORCED:
					character_path.gain_block(5)
				
				# If a tile has Rejuvenating, heal the player for 3.
				if scored_tile.tile.notch1 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal1 == false:
					character_path.gain_health(3)
					scored_tile.tile.heal1 = true
				if scored_tile.tile.notch2 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal2 == false:
					character_path.gain_health(3)
					scored_tile.tile.heal2 = true
				if scored_tile.tile.notch3 == LetterTile.NotchTypes.REJUVENATING and scored_tile.tile.heal3 == false:
					character_path.gain_health(3)
					scored_tile.tile.heal3 = true
				
				# If a tile has Flaming, apply Burn to the enemy.
				if current_target is Enemy:
					var burn_bonus = 0
					var bleed_bonus = 0
					for l in current_relics.size():
						pass
						##TODO: Query for debuff-related boosts
					
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.FLAMING:
						current_target.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.FLAMING:
						current_target.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.FLAMING:
						current_target.add_status("BURN_DEBUFF", (3 + burn_bonus), true, (3 + burn_bonus))
					
					if scored_tile.tile.notch1 == LetterTile.NotchTypes.PRICKLY:
						current_target.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
					if scored_tile.tile.notch2 == LetterTile.NotchTypes.PRICKLY:
						current_target.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
					if scored_tile.tile.notch3 == LetterTile.NotchTypes.PRICKLY:
						current_target.add_status("BLEED_DEBUFF", (point_values[scored_tile.tile.played_letter] + bleed_bonus), true, (point_values[scored_tile.tile.played_letter] + bleed_bonus))
				
				await get_tree().create_timer(0.12).timeout
			
			points_score += tile_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
						# If a tile has OVERLOADED and the player has at least one energy, remove an energy and double the word score.
			if scored_tile.tile.notch1 == LetterTile.NotchTypes.OVERLOADED and character_path.current_energy > 0:
				character_path.remove_energy(1)
				points_score = points_score * 2
				print("OVERLOADING... 1")
				get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			if scored_tile.tile.notch2 == LetterTile.NotchTypes.OVERLOADED and character_path.current_energy > 0:
				character_path.remove_energy(1)
				points_score = points_score * 2
				print("OVERLOADING... 2")
				get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			if scored_tile.tile.notch3 == LetterTile.NotchTypes.OVERLOADED and character_path.current_energy > 0:
				character_path.remove_energy(1)
				points_score = points_score * 2
				print("OVERLOADING... 3")
				get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
			# We're done scoring that letter, so we need to zero the letter score and prep for the next letter.
			tile_score = 0
			tile_retriggers = 0
			await get_tree().create_timer(0.05).timeout
			
			mult_score = floor(word_length / 2)
				
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			await get_tree().create_timer(0.05).timeout
			
			total_score = points_score * mult_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
			await get_tree().create_timer(0.05).timeout
			
	# If something is going to modify the mult score, it goes here.
	for i in current_relics.size():
		bonus_word_length = current_relics[i].word_length_bonus_effect(word)
		
	if bonus_word_length >= 0:
		for i in bonus_word_length:
			word_length += 1
			mult_score = floor(word_length / 2)
	
			total_score = points_score * mult_score
			get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
			
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	await get_tree().create_timer(0.075).timeout
	
	total_score = points_score * mult_score
	
	# If something is going to modify the total word score, it goes here.
	for i in current_relics.size():
		total_score = total_score * current_relics[i].word_score_multiplier_effect(word)
	
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(total_score)
	await get_tree().create_timer(0.075).timeout
			
	#$Subaluwa.play()

	# Post-processing for the scoring algorithm.
	for i in tiles_in_word.get_child_count():
		var tile_to_process = tiles_in_word.get_child(-1)
		
		tile_to_process.tile.word_index = 0
		tile_to_process.tile.word_length = 0
		
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
		
		elif tile_to_process.tile.is_ghost:
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(tiles_to_kill)
			tile_to_process.is_destroyed()
		
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
			tiles_in_play.erase(tile_to_process.tile)
			tile_to_process.is_destroyed() # TODO: Replace with unique effect.
		
		# Deletion of temps.
		elif tile_to_process.tile.is_temporary:
			print("Scab!!!")
			vaporized_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.tile.vaporized = true
			tile_to_process.reparent(tiles_to_kill)
			tiles_in_play.erase(tile_to_process.tile)
			tile_to_process.is_destroyed() # TODO: Replace with unique effect.
		
		# Crumbling.
		elif tile_to_process.tile.type == LetterTile.TileType.CRUMBLING:
			print("Crumbling!")
			destroyed_tiles.append(tile_to_process.tile)
			tile_to_process.tile.no_buffer = true
			tile_to_process.reparent(tiles_to_kill)
			tiles_in_play.erase(tile_to_process.tile)
			tile_to_process.is_destroyed() # TODO: Replace with unique effect.
		
		else:
			tile_to_process.reparent(tiles_to_kill)
			tiles_in_play.erase(tile_to_process.tile)

		
	_cleanup(total_score, word_target)

func _cleanup(total_score, word_target):
	# Make the bag look pretty just before the tiles go into it.
	GameEventHandler.disable_tile_bag.emit(true)
	for i in tiles_to_kill.get_child_count():
		var last_letter = tiles_to_kill.get_child(i)
		last_letter.remove_from_group("Tiles In Word")

		if last_letter == null:
			print("UH OH! FUCKY WUCKY!")
			continue
		
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
				last_letter.tile.target = Vector2(592.0, 32.0)
				last_letter.move_to_position(0.35)
				play_weighted_notch_sound()
				await get_tree().create_timer(0.075).timeout
		
		elif last_letter.tile.no_buffer == false and last_letter.tile.vaporized == false:
			buffered_tiles.append(last_letter.tile)
			last_letter.z_index = 120
			last_letter.is_dying()
			last_letter.tile.target = Vector2(592.0, 32.0)
			last_letter.move_to_position(0.35)
			await get_tree().create_timer(0.075).timeout
		
		else:
			pass

	_cleanup_killed_tiles()
	
	GameEventHandler.update_bag_tiles.emit()
	letters_from_tiles.clear()
	_word_from_tiles(letters_from_tiles)
	_apply_score_to_target(total_score, word_target)
	_move_tiles_into_place()
	print(character_path.current_energy)
	GameEventHandler.disable_tile_bag.emit(false)

func _move_tiles_into_place():
	GameEventHandler.disable_tile_bag.emit(true)
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
		if GeneralManager.is_combat_active == false or end_of_combat == true:
			return
		var found_tile = racked_tiles.get_child(i)
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
	_tiles_in_word_update()
	GameEventHandler.update_bag_tiles.emit()
	scoring_check = false
	_check_turn_status()

func _rename_tiles():
	for i in racked_tiles.get_child_count():
		var temp_name = str("GridTile" + str(randi_range(100, 200)))
		racked_tiles.get_child(i).set_name(temp_name)

	await get_tree().create_timer(0.04).timeout
	
	for i in racked_tiles.get_child_count():
		if not racked_tiles.get_child(i).name == str("GridTile"+str(racked_tiles.get_child(i).tile.grid_index)):
			racked_tiles.get_child(i).set_name(str("GridTile"+str(racked_tiles.get_child(i).tile.grid_index)))

func _calc_raw_word_score():
	var tile_score
	var points_score = 0
	var mult_score = 0
	var raw_word_score = 0
	var word_length = 0
	for i in tiles_in_word.get_child_count():
		tile_score = tiles_in_word.get_child(i).score_tile_quiet()
		points_score += tile_score
		word_length += 1
		mult_score = floor(word_length / 2)
		raw_word_score = points_score * mult_score
		
	get_node("ScoreLabel").text = str(points_score) + "x" + str(mult_score) + "=" + str(raw_word_score)
	return raw_word_score

func _calc_enemy_word_score(enemy: Enemy, word: Array):
	var points_score = 0
	var mult_score = 0
	var total_score = 0
	var tile_retriggers = 0
	for i in word.size():
		var word_length = word.size()
		var scored_tile = enemy.current_enemy_deck[word[i]]
		
		# Query for Repeating notches
		if scored_tile.notch1 == LetterTile.NotchTypes.REPEATING:
			print("Repeating of course! 1")
			tile_retriggers += 1
		if scored_tile.notch2 == LetterTile.NotchTypes.REPEATING:
			print("Repeating of course! 2")
			tile_retriggers += 1
		if scored_tile.notch3 == LetterTile.NotchTypes.REPEATING:
			print("Repeating of course! 3")
			tile_retriggers += 1
		
		for j in tile_retriggers + 1:
			var tile_score = 0
			if scored_tile.type == 0:
				tile_score += point_values[scored_tile.played_letter]

			elif scored_tile.type == 1 or scored_tile.type == 2:
				tile_score += 0
		
			elif scored_tile.type == 3:
				tile_score += point_values[scored_tile.played_letter]
		
			elif scored_tile.type == 4:
				tile_score += point_values[scored_tile.played_letter] - 1
				if tile_score == 0:
					tile_score += 1
			
			points_score += tile_score
			tile_score = 0
			tile_retriggers = 0

			mult_score = floor(word_length / 2)
			
			total_score = points_score * mult_score
		
	return total_score

func _check_turn_status():
	
	if character_path.is_target == false and %TestEnemy.is_target == false:
		%PlayButton.texture_normal.region 	= Rect2(0.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 80.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 80.0, 128.0, 40.0)
	
	elif character_path.current_energy <= 0 and character_path.has_initiative:
		%PlayButton.texture_normal.region 	= Rect2(0.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_pressed.region 	= Rect2(256.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_hover.region 	= Rect2(128.0, 40.0, 128.0, 40.0)
		%PlayButton.texture_disabled.region = Rect2(384.0, 40.0, 128.0, 40.0)
		%ShuffleButton.set_disabled(true)
		%PlayButton.set_disabled(false)
	
	elif not character_path.has_initiative:
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
		if character_path.has_initiative:
			%ShuffleButton.set_disabled(false)

	_check_for_dead_enemies()

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
		for i in tiles_in_play.size():
			tiles_in_play[i].current_age += 1
	
	_check_turn_status()

func _on_entity_clicked(which: GameEntity, action: GameEntity.GameEntityAction) -> void:
	print(current_target)
	for child in combatants.get_children():
		if child is Character or child is Enemy:
			child.is_target = false

	which.is_target = true

	for child in combatants.get_children():
		if child is Character or child is Enemy:
			child.target_query()
	
	if which is Enemy:
		for i in attack_list.get_child_count():
			attack_list.get_child(i).queue_free()
	
		attack_list.add_spacer(true)
		
		for i in which.enemy_attack_list.size():
			sticky_target = which
			var new_attack = HBoxContainer.new()
			new_attack.set_alignment(BoxContainer.ALIGNMENT_BEGIN)
			attack_list.add_child(new_attack)
			
			for j in which.enemy_attack_list[i].size():
				var current_attack = which.enemy_attack_list[i]
				var new_tile = mini_grid_tile_scene.instantiate()
				new_tile.tile = which.current_enemy_deck[current_attack[j]]
				new_tile.tile_hovered.connect(self._is_mini_tile_hovered)
				new_attack.add_child(new_tile)
			
			var attack_score_value = RichTextLabel.new()
			attack_score_value.text = str(_calc_enemy_word_score(which, which.enemy_attack_list[i]))
			attack_score_value.set_fit_content(true)
			attack_score_value.set_autowrap_mode(0)
			attack_score_value.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
			new_attack.add_child(attack_score_value)
			
			var attack_intent = intent_icon_scene.instantiate()
			new_attack.add_child(attack_intent)
			attack_intent.type = IntentIcon.IntentType[which.enemy_attack_intents[i]]
			attack_intent.update_intent_info()
			
			if not which.enemy_status_package_list[i].is_empty():
				var status_package = which.enemy_status_package_list[i]
				print("STATUS PACKAGE: " + str(status_package))
				for j in status_package.size():
					var subpackage = status_package[j]
					print("STATUS SUBPACKAGE: " + str(subpackage))
					var new_status = status_dictionary.get(subpackage[0])
					var status_icon = status_effect_scene.instantiate()
					status_icon.set_script(new_status)
					new_attack.add_child(status_icon)
					status_icon.amount = subpackage[1]
					print(status_icon.amount)
					status_icon.does_decay = bool(subpackage[2])
					status_icon.duration = subpackage[3]
					status_icon.status_hovered.connect(%StatusEffectTooltip._on_status_hovered)
					print("STATUS ID: " + str(status_icon.id))
					status_icon._update_graphics()
					

	current_target = which
	print(current_target.name)
	_check_turn_status()
	_tiles_in_word_update()
	
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
	
func _apply_score_to_target(total_score, word_target):
		if word_target is Character:
			word_target.gain_block(total_score)
			
		if word_target is Enemy:
			word_target.take_damage(total_score)

func _normalize_grid_tile_size():
	for i in racked_tiles.get_child_count():
		racked_tiles.get_child(i).scale_back_to_grid()

func _check_for_dead_enemies():
	var remaining_enemies = 0
	for i in combatants.get_child_count():
		if combatants.get_child(i) is Enemy:
			var current_enemy = combatants.get_child(i)
			if current_enemy.health > 0:
				print("Enemy Health: " + str(current_enemy.health))
				remaining_enemies += 1
	
			else:
				# TODO: Replace this once enemy death animations are a thing.
				current_enemy.queue_free()
	
			print(remaining_enemies)
			
			if remaining_enemies == 0:
				on_combat_end()
			
func on_combat_end():
	GeneralManager.is_combat_active = false
	character_path.has_initiative = false
	
	%ShuffleButton.set_disabled(true)
	%PlayButton.set_disabled(true)
	
	# TODO: add trigger for on_combat_end relics
	
	# TODO: add trigger for on_combat_end Notches
	
	# TODO: add trigger for on_combat_end Statuses
	
	character_path.clear_status_effects()
	character_path.current_energy = 0
	
	await get_tree().create_timer(3).timeout
	
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
	
	# TODO: Replace these values with values from the Encounter System that will be implemented later.
	%CombatRewards._bringup_combat_rewards(50, 5, 0) 
	

### Audio Shaboingery
func play_weighted_notch_sound():
	if not $SoundParent/WeightedNotchSound.is_playing():
		$SoundParent/WeightedNotchSound.play()

### Buttons and stuff below here!
#func _on_test_button_pressed():
	#get_node("TestButton").set_disabled(true)
	#
	##character_path.add_status("PLAGUED", 1, true, 3)
	##%TestEnemy.add_status("PLAGUED", 1, true, 3)
	##character_path.add_status("STONED", 1, true, 3)
	##%TestEnemy.add_status("STONED", 1, true, 3)
	##character_path.add_status("LOCKED", 1, true, 3)
	##%TestEnemy.add_status("LOCKED", 1, true, 3)
	#
	#get_node("TestButton").set_disabled(false)
	
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
	if character_path.current_energy > -99999:
		character_path.remove_energy(0)
		_shuffle_player_tiles()

func _shuffle_player_tiles():
	GameEventHandler.update_buffered_tiles.emit()
	%ShuffleButton.set_disabled(true)
	%PlayButton.set_disabled(true)
	get_node("ScoreLabel").text = ""
	tiles_in_play.clear()
	letters_from_tiles.clear()
	
	for i in tiles_in_word.get_child_count():
		var tile_to_push = tiles_in_word.get_child(-1)
	
		if tile_to_push.ghost_pair is GridTile:
			tile_to_push.ghost_pair.is_being_bagged()
	
		tile_to_push.reparent(tiles_to_kill)
	
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
	
		## buffered_tiles is a list of the LetterTiles that are in the buffer area between played words and turns.
		if tiles_in_play.has(tile_to_push.tile):
			buffered_tiles.append(tile_to_push.tile)
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32.0) + 256.0), 420.0)
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
	for i in tiles_in_word.get_child_count():
		var tile_to_push = tiles_in_word.get_child(-1)
		
		if tile_to_push.ghost_pair is GridTile:
			tile_to_push.ghost_pair.is_being_bagged()
	
		tile_to_push.reparent(tiles_to_kill)
	
		## tile_to_push_array is a list of tiles to push
		var tile_to_push_array = []
	
		## buffered_tiles is a list of the LetterTiles that are in the buffer area between played words and turns.
		if tiles_in_play.has(tile_to_push.tile):
			buffered_tiles.append(tile_to_push.tile)
		tile_to_push.tile.target = Vector2((((tile_to_push.tile.grid_index % 4) * 32.0) + 256.0), 420.0)
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
			
func _is_tile_hovered(which: GridTile, is_hovering: bool):
	if is_hovering == true:
		which.hovering = is_hovering
		tile_tooltip_requested.emit(which)
		
	if is_hovering == false:
		which.hovering = is_hovering
		tile_tooltip_hide_requested.emit()

func _is_mini_tile_hovered(which: MiniGridTile, is_hovering: bool):
	if is_hovering == true:
		which.hovering = is_hovering
		tile_mini_tooltip_requested.emit(which)
	
	if is_hovering == false:
		tile_tooltip_hide_requested.emit()

func _on_update_buffered_tiles() -> void:
	GameEventHandler.update_buffered_tiles.emit()

func _cleanup_killed_tiles():
	await get_tree().create_timer(0.5).timeout
	for i in tiles_to_kill.get_child_count():
		var killed_tile = tiles_to_kill.get_child(-1)
		killed_tile.free()
		
