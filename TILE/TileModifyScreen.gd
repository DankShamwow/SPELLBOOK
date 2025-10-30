extends Control
## TileModifyScreen is a screen where a player can set the letter on a LetterTile, and either
## have a new tile of that letter added to their deck, or adjust the letter on an existing tile.
class_name TileModifyScreen

@warning_ignore_start("int_as_enum_without_cast")

var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

## current_deck is the list of LetterTiles in your deck.
var current_deck = GeneralManager.current_deck

var modified_tile: GridTile

var modified_tile_index: int = -1
var add_tile_to_deck: bool = false

var failure_tween: Tween

const GRID_TILE_SCENE: PackedScene = preload("res://TILE/GRID_TILE/GridTile.tscn")

func _ready():
	GameEventHandler.rewrite_deck_tile.connect(_write_tile)
	
	_manage_covering(true)
	
	#var dummy_tile = LetterTile.new().new_tile(0, 0, 0, 0, 0, -1)
	#modified_tile = GRID_TILE_SCENE.instantiate()
	#modified_tile.tile = dummy_tile
	#self.add_child(modified_tile)
	#modified_tile.position = Vector2(304, 176)

func _manage_covering(state: bool = false) -> void:
	var tween = %ScreenCovering.create_tween()
	
	if not state:
		tween.tween_property(%ScreenCovering, "modulate:a", (0.65 * int(state)), 0.15)
		tween.tween_property(%ScreenCovering, "visible", state, 0.001)
		%ScreenCovering.mouse_filter = MOUSE_FILTER_IGNORE
	
	if state:
		%ScreenCovering.mouse_filter = MOUSE_FILTER_STOP
		tween.tween_property(%ScreenCovering, "visible", state, 0.001)
		tween.tween_property(%ScreenCovering, "modulate:a", (0.65 * int(state)), 0.15)

func _write_tile(input_tile: GridTile):
	modified_tile = input_tile.duplicate()
	modified_tile.tile = input_tile.tile.duplicate()
	modified_tile_index = input_tile.tile.tile_index
	modified_tile.tile.is_blank = false
	self.add_child(modified_tile)
	modified_tile.position = Vector2(304, 176)
	
	if modified_tile_index == -1:
		add_tile_to_deck = true

func _on_letter_input_text_changed(new_text: String) -> void:
	new_text = new_text.to_lower()
	var letter_index = letters.find(new_text)
	# If the input string is an english letter, do the following:
	if not letter_index == -1 and not modified_tile.tile.true_letter == letter_index:
		modified_tile.tile.true_letter = letter_index
		modified_tile.tile.played_letter = letter_index
		modified_tile.tile.visual_letter = letter_index
		modified_tile.update_tile_graphics()

func _on_letter_input_text_submitted(new_text: String) -> void:
	%LetterInput.editable = false
	new_text = new_text.to_lower()
	var letter_index = letters.find(new_text)
	
	# If the input string is an english letter, do the following:
	if not letter_index == -1:
		modified_tile.tile.true_letter = letter_index
		modified_tile.tile.played_letter = letter_index
		modified_tile.tile.visual_letter = letter_index
		modified_tile.update_tile_graphics()
		
		if not add_tile_to_deck:
			current_deck[modified_tile_index].true_letter = letter_index
			current_deck[modified_tile_index].played_letter = letter_index
			current_deck[modified_tile_index].visual_letter = letter_index
			modified_tile.update_tile_graphics()
			
			_cleanup()
	
		if add_tile_to_deck:
			modified_tile.tile.true_letter = letter_index
			modified_tile.tile.played_letter = letter_index
			modified_tile.tile.visual_letter = letter_index
			modified_tile.update_tile_graphics()
			modified_tile.tile.tile_index = current_deck.size()
			current_deck.append(modified_tile.tile)
			
			_cleanup()

	else:
		%LetterInput.editable = true
		
		if failure_tween:
			failure_tween.kill()
			
		failure_tween = get_tree().create_tween()
		failure_tween.tween_property(%FailureLabel, "modulate:a", 1, 0.05)
		failure_tween.tween_interval(1)
		failure_tween.tween_property(%FailureLabel, "modulate:a", 0, 1)

func _cleanup():
	await get_tree().create_timer(0.25).timeout
	
	modified_tile.reparent(%TilesToKill)
	modified_tile.tile.target = Vector2(592.0, 16.0)
	modified_tile.is_rapidly_shrinking()
	await get_tree().create_timer(0.05).timeout
	modified_tile.move_to_position(0.5)
	await get_tree().create_timer(0.05).timeout
	modified_tile.is_being_added_to_deck()
	
	
	await get_tree().create_timer(0.6).timeout
	
	var tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.15)
	tween.tween_property(self, "visible", false, 0.001)
	
	await get_tree().create_timer(0.17).timeout
	self.queue_free()
