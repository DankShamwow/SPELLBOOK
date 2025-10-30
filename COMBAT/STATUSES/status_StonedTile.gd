extends StatusEffect

## Information grabbed for Tile Related Debuffs:

var tiles_in_play 	= GeneralManager.tiles_in_play
var debuff_rng		= RandomnessManager.debuff_rng

## List of LetterTiles that were successfully debuffed.
var affected_tile_list: 					Array[LetterTile] = []
## List of LetterTiles that were selected to be debuffed. This is trimmed to be equal to that of
## affected_tile_list's tile indices once application concludes.
var affected_tile_indices: 					Array[int] = []

var previous_debuff_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_id = 0
	status_name = "Stoned"
	status_description = "Stoned Tiles gain no points from their Letter."
	stack_type = StackType.TIMED_EXPIRY
	tick_type = TickType.TURN_END
	status_type = StatusType.DEBUFF
	super()
	
func _update_graphics():
	status_name = "Stoned"
	status_description = "Stoned Tiles gain no points from their Letter."
	super()
	
func on_application(_status_amount: int, _status_duration: int = 0):
	var potential_tiles = []
	amount = _status_amount
	duration = _status_duration
	#region Affects Character
	if inflicted_entity is Character:
		# Find all tiles that can be inflicted with the debuff.
		for i in tiles_in_play.size():
			var current_tile = tiles_in_play[i] as LetterTile
			if not current_tile.type == LetterTile.TileType.STONED and not current_tile.is_debuff_immune:
				potential_tiles.append(current_tile)
		
		if potential_tiles.size() == 0:
			return 
		
		# Typically, the status amount will be smaller, but if it's greater than the number of tiles that can be inflicted,
		# we just inflict all of the potential tiles with the debuff.
		for i in min(potential_tiles.size(), _status_amount):
			var affected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()] as LetterTile
			
			if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
			or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
			or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
				affected_tile_indices.append(affected_tile.tile_index)
				potential_tiles.erase(affected_tile)
				continue
				
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				affected_tile_list.append(affected_tile)
				potential_tiles.erase(affected_tile)
				affected_tile.type = LetterTile.TileType.STONED
		
		GameEventHandler.update_tile_graphics.emit(inflicted_entity, affected_tile_indices)
	#endregion
	
	#region Affects Enemy
	if inflicted_entity is Enemy:
		for i in inflicted_entity.enemy_deck.size():
			var current_tile = inflicted_entity.enemy_deck[i] as LetterTile
			if not current_tile.type == LetterTile.TileType.STONED and not current_tile.is_debuff_immune:
				potential_tiles.append(current_tile)
		
		if potential_tiles.size() == 0:
			return 
		
		# Typically, the status amount will be smaller, but if it's greater than the number of tiles that can be inflicted,
		# we just inflict all of the potential tiles with the debuff.
		for i in min(potential_tiles.size(), _status_amount):
			var affected_tile = potential_tiles[debuff_rng.randi() % potential_tiles.size()] as LetterTile
			
			if affected_tile.notch1 == LetterTile.NotchTypes.INERT \
			or affected_tile.notch2 == LetterTile.NotchTypes.INERT \
			or affected_tile.notch3 == LetterTile.NotchTypes.INERT:
				affected_tile_indices.append(affected_tile.tile_index)
				potential_tiles.erase(affected_tile)
				continue
				
			else:
				affected_tile_indices.append(affected_tile.tile_index)
				affected_tile_list.append(affected_tile)
				potential_tiles.erase(affected_tile)
				affected_tile.type = LetterTile.TileType.STONED
		
		GameEventHandler.update_tile_tooltip_graphics.emit(inflicted_entity, affected_tile_indices)
	#endregion

	affected_tile_indices.clear()
	for tile: LetterTile in affected_tile_list:
		affected_tile_indices.append(tile.tile_index)
		
	_update_graphics()

func on_turn_end(which: GameEntity, _count: int):
	if which == inflicted_entity:
		if tick_type == TickType.TURN_END or tick_type == TickType.TURN_START_END:
			duration -= 1
			
			_update_graphics()
			
			if duration <= 0:
				on_duration_expiry()
			
func on_duration_expiry():
	affected_tile_indices.clear()
	for i in affected_tile_list.size():
		if affected_tile_list[i].type == LetterTile.TileType.STONED:
			affected_tile_indices.append(affected_tile_list[i].tile_index)
			affected_tile_list[i].type = affected_tile_list[i].original_type
			
	if inflicted_entity is Character:
		GameEventHandler.update_tile_graphics.emit(inflicted_entity, affected_tile_indices)
		
	if inflicted_entity is Enemy:
		GameEventHandler.update_tile_tooltip_graphics.emit(inflicted_entity, affected_tile_indices)
		
	self.queue_free()
