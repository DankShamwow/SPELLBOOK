extends StatusEffect
class_name BurningTile

var tiles_in_play 	= GeneralManager.tiles_in_play
var debuff_rng		= RandomnessManager.debuff_rng
var affected_tile_list = []
var affected_tile_indices = []
var previous_debuff_index: int

func _ready():
	id = 2
	tile_status = true
	print("STATUS ID: " + str(id))
	super()

func on_application(status_amount: int, does_status_decay: bool, status_duration: int):
	var potential_tiles = []
	print("Attempting to apply status...")
	
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
			if not tiles_in_play[i].type == LetterTile.TileType.BURNING:
				potential_tiles.append(tiles_in_play[i])
		
		if potential_tiles.size() == 0:
			return affected_tile_indices
		
		print("Burning Player!")
		while affected_tile_indices.size() < status_amount and attempts < 20:
			print("Player Burning Attempt: " + str(attempts))
			var affected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()]
			
			if affected_tile_indices.has(affected_tile.tile_index):
				attempts += 1
				continue
				
			elif affected_tile.type == LetterTile.TileType.BURNING:
				continue
		
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				attempts += 1
				if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue

				else:
					affected_tile.type = LetterTile.TileType.BURNING
					affected_tile_list.append(affected_tile)
	
	if get_parent().get_parent() is Enemy:
		var attempts = 0
		
		for i in get_parent().get_parent().enemy_deck.size():
			if not get_parent().get_parent().enemy_deck[i].type == LetterTile.TileType.BURNING:
				potential_tiles.append(get_parent().get_parent().enemy_deck[i])
		
		if potential_tiles.size() == 0:
			return affected_tile_indices
		
		print("Burning Enemy!")
		while affected_tile_indices.size() < status_amount and attempts < 20:
			print("Enemy Burning Attempt: " + str(attempts))
			var affected_tile = potential_tiles[debuff_rng.randi() % (potential_tiles.size())]
		
			if affected_tile_indices.has(affected_tile.tile_index):
				attempts += 1
				continue
				
			elif affected_tile.type == LetterTile.TileType.BURNING:
				continue
		
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				attempts += 1
				if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue

				else:
					affected_tile.type = LetterTile.TileType.BURNING
					affected_tile_list.append(affected_tile)
	
	return affected_tile_indices
	
func on_turn_start():
	if does_decay:
		duration -= 1
		%NumberLabel.text = str(duration)
		
	if duration == 0:
		on_duration_expiry()

func on_duration_expiry():
	# When the duration hits zero, do all this stuff.
	for i in affected_tile_list.size():
		# Check to see if the tile is still Stoned.
		if affected_tile_list[i].type == LetterTile.TileType.BURNING:
			# If it is, clear it. If it isn't, we do nothing and let the debuff expire anyway.
			affected_tile_list[i].type = LetterTile.TileType.BASIC
	
	return affected_tile_indices

func on_combat_end():
	on_duration_expiry()
