extends StatusEffect
class_name WarpedDebuff

var tiles_in_play 	= GeneralManager.tiles_in_play
var debuff_rng		= RandomnessManager.debuff_rng
var affected_tile_list = []
var affected_tile_indices = []
var previous_debuff_index: int

func _ready():
	id = 10
	tile_status = true
	print("STATUS ID: " + str(id))
	super()

## When this status is applied, this determines the amount of the status applied, if it decays each turn, and the duration of it.
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
			if tiles_in_play[i].played_letter == tiles_in_play[i].true_letter:
				potential_tiles.append(tiles_in_play[i])
		
		if potential_tiles.size() == 0:
			return affected_tile_indices
		
		print("Warping Player!")
		while affected_tile_indices.size() < status_amount and attempts < 20:
			var allowed_letters = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
			print("Player Warp Attempt: " + str(attempts))
			var affected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()]
			
			if affected_tile_indices.has(affected_tile.tile_index):
				attempts += 1
				continue
		
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				attempts += 1
				if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue

				else:
					allowed_letters.remove_at(affected_tile.true_letter)
					var warped_letter = allowed_letters[debuff_rng.randi() % allowed_letters.size()]
					affected_tile.visual_letter = warped_letter
					affected_tile.played_letter = warped_letter
					affected_tile_list.append(affected_tile)

	if get_parent().get_parent() is Enemy:
		var attempts = 0
		
		for i in get_parent().get_parent().enemy_deck.size():
			if get_parent().get_parent().enemy_deck[i].visual_letter == get_parent().get_parent().enemy_deck[i].true_letter:
				potential_tiles.append(get_parent().get_parent().enemy_deck[i])
		
		if potential_tiles.size() == 0:
			return affected_tile_indices
		
		print("Warping Enemy!")
		while affected_tile_indices.size() < status_amount and attempts < 20:
			var allowed_letters = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
			print("Enemy Warping Attempt: " + str(attempts))
			var affected_tile = potential_tiles[debuff_rng.randi() % (potential_tiles.size())]
		
			if affected_tile_indices.has(affected_tile.tile_index):
				attempts += 1
				continue

			else:
				affected_tile_indices.append(affected_tile.tile_index)
				attempts += 1
				if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
				or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
					continue

				else:
					allowed_letters.remove_at(affected_tile.true_letter)
					var warped_letter = allowed_letters[debuff_rng.randi() % allowed_letters.size()]
					affected_tile.visual_letter = warped_letter
					affected_tile.played_letter = warped_letter
					affected_tile_list.append(affected_tile)

func on_turn_start():
	if does_decay:
		duration -= 1
		%NumberLabel.text = str(duration)
		
	if duration == 0:
		on_duration_expiry()

func on_duration_expiry():
	# When the duration hits zero, do all this stuff.
	for i in affected_tile_list.size():
		affected_tile_list[i].visual_letter = affected_tile_list[i].true_letter
	return affected_tile_indices
