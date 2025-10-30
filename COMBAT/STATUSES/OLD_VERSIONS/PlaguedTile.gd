extends StatusEffect
class_name PlaguedTile_OLD

var tiles_in_play 	= GeneralManager.tiles_in_play
var debuff_rng		= RandomnessManager.debuff_rng
var affected_tile_list = []
var affected_tile_indices = []
var previous_debuff_index: int

func _ready():
	id = 3
	status_name = "Plagued"
	status_description = "Plagued Tiles spread their disease to adjacent tiles at the start of your turn, and are worth one less point."
	tile_status = true
	print("STATUS ID: " + str(id))
	super()
	
func _update_graphics():
	status_name = "Plagued"
	status_description = "Plagued Tiles spread their disease to adjacent tiles at the start of your turn, and are worth one less point."
	super()

func _on_status_effect_mouse_entered():
	status_description = "Plagued Tiles spread their disease to adjacent tiles at the start of your turn, and are worth one less point."
	super()

func on_application(status_amount: int, does_status_decay: bool, status_duration: int):
	var potential_tiles = []
	
	if does_status_decay:
		does_decay = true
		duration = status_duration
		%NumberLabel.text = str(duration)
		
	if not does_status_decay:
		duration = 1
		%NumberLabel.text = ""
	
	if get_parent().get_parent() is Character:
		var attempts = 0
		
		for i in tiles_in_play.size():
			if not tiles_in_play[i].type == LetterTile.TileType.PLAGUED:
				potential_tiles.append(tiles_in_play[i])
		
		if potential_tiles.size() == 0:
			return affected_tile_indices
		
		while affected_tile_indices.size() < status_amount and attempts < 20:
			var affected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()]
			
			if affected_tile_indices.has(affected_tile.tile_index):
				attempts += 1
				continue
				
			elif affected_tile.type == LetterTile.TileType.PLAGUED:
				continue
		
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				attempts += 1
				if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue

				else:
					affected_tile.type = LetterTile.TileType.PLAGUED
					affected_tile_list.append(affected_tile)
	
	if get_parent().get_parent() is Enemy:
		var attempts = 0
		
		for i in get_parent().get_parent().enemy_deck.size():
			if not get_parent().get_parent().enemy_deck[i].type == LetterTile.TileType.PLAGUED:
				potential_tiles.append(get_parent().get_parent().enemy_deck[i])
		
		if potential_tiles.size() == 0:
			return affected_tile_indices
		
		while affected_tile_indices.size() < status_amount and attempts < 20:
			var affected_tile = potential_tiles[debuff_rng.randi() % (potential_tiles.size())]
		
			if affected_tile_indices.has(affected_tile.tile_index):
				attempts += 1
				continue
				
			elif affected_tile.type == LetterTile.TileType.PLAGUED:
				continue
		
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				attempts += 1
				if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue

				else:
					affected_tile.type = LetterTile.TileType.PLAGUED
					affected_tile_list.append(affected_tile)
	
	return affected_tile_indices
	
func on_turn_start():
	var current_grid_tiles = []
	
	for i in affected_tile_list.size():
		var potential_tiles = []
		
		if get_parent().get_parent() is Character:
			var spreader_index = affected_tile_list[i].grid_index
			
			# Need to know if the spreader tile is still in the rack, so we gather all the
			# tile indices of the tiles in play.
			for j in tiles_in_play.size():
				current_grid_tiles.append(tiles_in_play[j].tile_index)
			
			# If our tile is NOT a match, we stop here. This isn't a problem for enemies.
			if not current_grid_tiles.has(affected_tile_list[i].tile_index):
				return affected_tile_indices
			
			for j in tiles_in_play.size():
				if not tiles_in_play[j].type == LetterTile.TileType.PLAGUED and (\
				# Up, Down, Right, Left, in that order.
				tiles_in_play[j].grid_index == spreader_index + 4 \
				or tiles_in_play[j].grid_index == spreader_index - 4 \
				or tiles_in_play[j].grid_index == spreader_index + 1 \
				or tiles_in_play[j].grid_index == spreader_index - 1 ):
					potential_tiles.append(tiles_in_play[j])
					
			if not potential_tiles.size() == 0 and affected_tile_list[i].type == LetterTile.TileType.PLAGUED:
				var infected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()]
			
				if infected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or infected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or infected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue
					
				else:
					infected_tile.type = LetterTile.TileType.PLAGUED
					affected_tile_indices.append(infected_tile.tile_index)
					affected_tile_list.append(infected_tile)
			
		if get_parent().get_parent() is Enemy:
			var spreader_index = affected_tile_list[i].tile_index
			var enemy_deck = get_parent().get_parent().enemy_deck
			for j in enemy_deck.size():
				if not enemy_deck[j].type == LetterTile.TileType.PLAGUED and (\
				enemy_deck[j].tile_index == spreader_index + 4 \
				or enemy_deck[j].tile_index == spreader_index - 4 \
				or enemy_deck[j].tile_index == spreader_index + 1 \
				or enemy_deck[j].tile_index == spreader_index - 1 ):
					potential_tiles.append(enemy_deck[j])
					
			if not potential_tiles.size() == 0 and affected_tile_list[i].type == LetterTile.TileType.PLAGUED:
				var infected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()]
				
				if infected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or infected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or infected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue
					
				else:
					infected_tile.type = LetterTile.TileType.PLAGUED
					affected_tile_indices.append(infected_tile.tile_index)
					affected_tile_list.append(infected_tile)
	
	return affected_tile_indices

func on_turn_end():
	if does_decay:
		duration -= 1
		%NumberLabel.text = str(duration)
	
	if duration == 0:
		on_duration_expiry()
		return

func on_duration_expiry():
	# When the duration hits zero, do all this stuff.
	for i in affected_tile_list.size():
		# Check to see if the tile is still Stoned.
		if affected_tile_list[i].type == LetterTile.TileType.PLAGUED:
			# If it is, clear it. If it isn't, we do nothing and let the debuff expire anyway.
			affected_tile_list[i].type = LetterTile.TileType.BASIC
	
	return affected_tile_indices

func on_combat_end():
	on_duration_expiry()

func on_force_clear():
	on_duration_expiry()
