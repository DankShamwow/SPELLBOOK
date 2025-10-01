extends Control
class_name GridTile

@onready var tile: LetterTile
@onready var sprite = $Tile_Button/Tile_Sprite

var tiles_in_play 			= GeneralManager.tiles_in_play
var buffered_tiles 			= GeneralManager.buffered_tiles
var available_tiles 		= GeneralManager.available_tiles
var point_values  			= GeneralManager.point_values

var various_rng 			= RandomnessManager.various_rng

var original_z = self.z_index

enum GridTileAction {
	PLAY, VIEW
}

var bag_open = false
var hovering = false

## Feature for the tile grid
var grid_ghost := false
var ghost_pair = null

## Lexical Notch Shenanigans
var paired_tile_1 = null
var paired_tile_2 = null
var paired_tile_3 = null

var glow_tween: Tween
var scale_tween: Tween

func _ready():
	
	##This is the one we use outside of testing, at least when not testing the tile directly.
	$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(tile.type, 0))
	$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(tile.visual_letter, 1))
	$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(tile.type, 6))
	$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(tile.notch1, 3))
	$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(tile.notch2, 4))
	$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(tile.notch3, 5))

	if self.tile.is_ghost:
		var tween = get_tree().create_tween()
		tween.tween_property($Tile_Button/Tile_Sprite, "modulate:a", 0.75, 0.01)
	
	## For testing purposes only
	#var hasOverlay = randi_range(0, 5)
	#$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(hasOverlay, 0))
	#$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(randi_range(0, 25), 1))
	#$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(hasOverlay, 3))
	##$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(tile.notch1, 4))
	##$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(tile.notch2, 5))
	##$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(tile.notch3, 6))

func _process(_delta: float) -> void:
	## If scoring isn't happening, and the tile isn't going through another scaling process
	## and isn't being hovered and isn't at the proper scale, tween it to the proper scale.
	if not GeneralManager.scoring_is_active and not scale_tween and not hovering and not scale == is_at_scale():
		determine_tile_scale()

func update_tile_graphics():
	print("Updating graphics...")
	
	var tween = get_tree().create_tween()
	
	tween.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 1, 0.1)
	tween.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 0, 0.01)
	
	var new_type = tile.type
	var _played_letter = tile.played_letter
	var visual_letter = tile.visual_letter
	var new_notch1 = tile.notch1
	var new_notch2 = tile.notch2
	var new_notch3 = tile.notch3
	
	$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(new_type, 0))
	$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(visual_letter, 1))
	$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(new_type, 6))
	$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(new_notch1, 3))
	$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(new_notch2, 4))
	$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(new_notch3, 5))

func update_notch_graphics(notch: int, is_ghost = false):
	
	var new_notch1 = tile.notch1
	var new_notch2 = tile.notch2
	var new_notch3 = tile.notch3
	
	var tween = get_tree().create_tween()
	tween.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 1, 0.1)
	tween.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 0, 0.01)
	
	if notch == 1:
		$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(new_notch1, 3))
		if is_ghost:
			var tween2 = get_tree().create_tween()
			tween2.tween_property($Tile_Button/Tile_Sprite/Notch_1_Sprite, "modulate:a", 0.5, 0.1)
		else:
			var tween2 = get_tree().create_tween()
			tween2.tween_property($Tile_Button/Tile_Sprite/Notch_1_Sprite, "modulate:a", 1.0, 0.1)
	
	if notch == 2:
		$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(new_notch2, 4))
		if is_ghost:
			var tween2 = get_tree().create_tween()
			tween2.tween_property($Tile_Button/Tile_Sprite/Notch_2_Sprite, "modulate:a", 0.5, 0.1)
		else:
			var tween2 = get_tree().create_tween()
			tween2.tween_property($Tile_Button/Tile_Sprite/Notch_2_Sprite, "modulate:a", 1.0, 0.1)
	
	if notch == 3:
		$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(new_notch3, 5))
		if is_ghost:
			var tween2 = get_tree().create_tween()
			tween2.tween_property($Tile_Button/Tile_Sprite/Notch_3_Sprite, "modulate:a", 0.5, 0.1)
		else:
			var tween2 = get_tree().create_tween()
			tween2.tween_property($Tile_Button/Tile_Sprite/Notch_3_Sprite, "modulate:a", 1.0, 0.1)

	else:
		return

func move_to_position(time:= 0.25):
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", tile.target, time)
	update_tile_score_text(0, true)
	await get_tree().create_timer(time/2).timeout
	return true

func play_tile_sound():
	if not $SoundParent/TileSoundAttempt3.is_playing():
		$SoundParent/TileSoundAttempt3.pitch_scale = various_rng.randf_range(0.965, 1.035)
		$SoundParent/TileSoundAttempt3.play()

func play_scoring_sound(count):
	$SoundParent/ScoringSoundAttempt1.pitch_scale = 1 + (0.025 * count)
	$SoundParent/ScoringSoundAttempt1.play()

func play_tile_destruction_sound():
	if not $SoundParent/DestructionSound.is_playing():
		$SoundParent/DestructionSound.play()

func is_at_scale():
	var scaling_factor: float = 1.0
	
	if self.get_parent().name == "TilesInWord" and not hovering:
		if self.tile.word_length > 6:
			scaling_factor = float(7.0 / (self.tile.word_length + 1.0))
			
		else:
			scaling_factor = 1.0
		
	elif not self.get_parent().name == "TilesInWord" and not hovering:
		scaling_factor = 1.0
	
	#print(scaling_factor)
	#print(self.tile.word_length)
	
	var scalar = Vector2(scaling_factor, scaling_factor)
	
	return scalar

func determine_tile_scale(speed: float = 0.1):
	var scaling_factor: float = 1.0
	
	if self.get_parent().name == "TilesInWord" and not hovering:
		if self.tile.word_length > 6:
			scaling_factor = float(7.0 / (self.tile.word_length + 1.0))
		else:
			scaling_factor = 1.0
	
	elif self.get_parent().name == "TilesInWord" and hovering:
		if self.tile.word_length > 6:
			scaling_factor = float(7.0 / (self.tile.word_length + 1.0)) * 1.1
		else:
			scaling_factor = 1.1
	
	elif not self.get_parent().name == "TilesInWord" and hovering:
		scaling_factor = 1.1
		
	else:
		scaling_factor = 1.0
		
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(scaling_factor, scaling_factor), speed)

func toggle_word_glow(state: bool = false):
	if glow_tween:
			glow_tween.kill()
	
	if state:
		glow_tween = get_tree().create_tween()
		glow_tween.tween_property(%Word_Glow, "modulate:a", 1.0, 0.1)

	else:
		glow_tween = get_tree().create_tween()
		glow_tween.tween_property(%Word_Glow, "modulate:a", 0.0, 0.5)

func fade():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.1)
	
func unfade():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	
func mark_buffer():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0.7, 0.3, 0.3, 0.7), 0.1)
	
func mark_destroyed():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 1), 0.1)
	
func mark_vaporized():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0.2, 0.2, 0.2, 1), 0.1)
	
func error_vision():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 1, 1), 0.1)
	
func _on_tile_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left Clickety!")
			play_tile_sound()
			GameEventHandler.tile_clicked.emit(
				self, GridTileAction.PLAY
			)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right Clickety!")
			play_tile_sound()
			GameEventHandler.tile_clicked.emit(
				self, GridTileAction.VIEW
			)

func _on_tile_button_mouse_entered():
	#print("I've been entered!")
	hovering = true
	if self.grid_ghost == true:
		self.ghost_pair.hovering = true
		self.hovering = true
		original_z = self.ghost_pair.z_index
		self.ghost_pair.determine_tile_scale(0.0075)
		self.determine_tile_scale(0.0075)
		self.ghost_pair.z_index = 128
		GameEventHandler.tile_hovered.emit(self.ghost_pair, true)
		GameEventHandler.tile_tooltip_requested.emit(self.ghost_pair)
	else:
		original_z = self.z_index
		determine_tile_scale()
		self.z_index = 128
		GameEventHandler.tile_hovered.emit(self, true)
		GameEventHandler.tile_tooltip_requested.emit(self)

func _on_tile_button_mouse_exited():
	#print("I've been exited!")
	hovering = false
	if self.grid_ghost == true:
		self.ghost_pair.hovering = false
		self.hovering = false
		self.ghost_pair.determine_tile_scale()
		self.determine_tile_scale()
		self.ghost_pair.z_index = original_z
		GameEventHandler.tile_hovered.emit(self.ghost_pair, false)
		GameEventHandler.tile_tooltip_hide_requested.emit()
	else:
		determine_tile_scale()
		self.z_index = original_z
		GameEventHandler.tile_hovered.emit(self, false)
		GameEventHandler.tile_tooltip_hide_requested.emit()

func spawned_in():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.000001)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)

func spawned_from_bag():
	var tween = get_tree().create_tween()
	scale_tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.000001)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.05)
	scale_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.000001)
	scale_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.05)

func is_dying():
	update_tile_score_text(0, true)
	var tween = get_tree().create_tween()
	scale_tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 0), 0.1)
	scale_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.1)
	
func is_destroyed():
	var tween = get_tree().create_tween()
	scale_tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 0), 0.1)
	scale_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.1)
	play_tile_destruction_sound()
	
func is_being_bagged():
	var tween = get_tree().create_tween()
	scale_tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.25)
	scale_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.05)
	
	await get_tree().create_timer(0.25).timeout
	self.queue_free()
	
func is_vanishing():
	var tween = get_tree().create_tween()
	scale_tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.15)
	scale_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.15)

func is_being_added_to_deck():
	var tween = get_tree().create_tween()
	scale_tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.5)
	scale_tween.tween_property(sprite, "scale", Vector2(0, 0), 0.5)

## Function that handles the scoring of a tile.
func score_tile(count):
	var letter_score = 0
	if self.tile.type == LetterTile.TileType.BASIC or self.tile.type == LetterTile.TileType.LOCKED:
		letter_score += point_values[self.tile.played_letter]

	elif self.tile.type == LetterTile.TileType.STONED:
		letter_score += 0
		
	elif self.tile.type == LetterTile.TileType.BURNING:
		letter_score += point_values[self.tile.played_letter]
		
	elif self.tile.type == LetterTile.TileType.PLAGUED:
		letter_score += point_values[self.tile.played_letter] - 1
		if letter_score == 0:
			letter_score += 1

	elif self.tile.type == LetterTile.TileType.CRUMBLING:
		letter_score += point_values[self.tile.played_letter]

	if self.tile.notch1 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if self.tile.notch2 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if self.tile.notch3 == LetterTile.NotchTypes.POTENT:
		letter_score += 3

	if self.tile.notch1 == LetterTile.NotchTypes.PATIENT:
		letter_score += self.tile.current_age * 2
	if self.tile.notch2 == LetterTile.NotchTypes.PATIENT:
		letter_score += self.tile.current_age * 2
	if self.tile.notch3 == LetterTile.NotchTypes.PATIENT:
		letter_score += self.tile.current_age * 2

	if self.tile.notch1 == LetterTile.NotchTypes.QUICK and self.tile.current_age == 0:
		letter_score += 5
	if self.tile.notch2 == LetterTile.NotchTypes.QUICK and self.tile.current_age == 0:
		letter_score += 5
	if self.tile.notch3 == LetterTile.NotchTypes.QUICK and self.tile.current_age == 0:
		letter_score += 5

	if self.tile.notch1 == LetterTile.NotchTypes.DISTANT:
		letter_score += self.tile.word_index
	if self.tile.notch2 == LetterTile.NotchTypes.DISTANT:
		letter_score += self.tile.word_index
	if self.tile.notch3 == LetterTile.NotchTypes.DISTANT:
		letter_score += self.tile.word_index
		
	if self.tile.notch1 == LetterTile.NotchTypes.LOCAL:
		letter_score += (self.tile.word_length - self.tile.word_index)
	if self.tile.notch2 == LetterTile.NotchTypes.LOCAL:
		letter_score += (self.tile.word_length - self.tile.word_index)
	if self.tile.notch3 == LetterTile.NotchTypes.LOCAL:
		letter_score += (self.tile.word_length - self.tile.word_index)

	if self.tile.notch1 == LetterTile.NotchTypes.BALANCED:
		if self.tile.word_length == self.tile.word_index:
			letter_score += 0
		elif floor(self.tile.word_length / 2.0) - self.tile.word_index == 0:
			if self.tile.word_length % 2 == 1:
				letter_score += 2 * self.tile.word_index
			else:
				letter_score += (2 * (self.tile.word_index - 1))
		elif self.tile.word_index < floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_index)
		elif self.tile.word_index >= floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_length - self.tile.word_index - 1)
			
	if self.tile.notch2 == LetterTile.NotchTypes.BALANCED:
		if self.tile.word_length == self.tile.word_index:
			letter_score += 0
		elif floor(self.tile.word_length / 2.0) - self.tile.word_index == 0:
			if self.tile.word_length % 2 == 1:
				letter_score += 2 * self.tile.word_index
			else:
				letter_score += (2 * (self.tile.word_index - 1))
		elif self.tile.word_index < floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_index)
		elif self.tile.word_index >= floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_length - self.tile.word_index - 1)

	if self.tile.notch3 == LetterTile.NotchTypes.BALANCED:
		if self.tile.word_length == self.tile.word_index:
			letter_score += 0
		elif floor(self.tile.word_length / 2.0) - self.tile.word_index == 0:
			if self.tile.word_length % 2 == 1:
				letter_score += 2 * self.tile.word_index
			else:
				letter_score += (2 * (self.tile.word_index - 1))
		elif self.tile.word_index < floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_index)
		elif self.tile.word_index >= floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_length - self.tile.word_index - 1)
	
	play_scoring_sound(count)
	await juice_score()

	return letter_score

func score_tile_quiet():
	var letter_score = 0
	if self.tile.type == LetterTile.TileType.BASIC or self.tile.type == LetterTile.TileType.LOCKED:
		letter_score += point_values[self.tile.played_letter]

	elif self.tile.type == LetterTile.TileType.STONED:
		letter_score += 0
		
	elif self.tile.type == LetterTile.TileType.BURNING:
		letter_score += point_values[self.tile.played_letter]
		
	elif self.tile.type == LetterTile.TileType.PLAGUED:
		letter_score += point_values[self.tile.played_letter] - 1
		if letter_score == 0:
			letter_score += 1

	elif self.tile.type == LetterTile.TileType.CRUMBLING:
		letter_score += point_values[self.tile.played_letter]

	if self.tile.notch1 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if self.tile.notch2 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if self.tile.notch3 == LetterTile.NotchTypes.POTENT:
		letter_score += 3

	if self.tile.notch1 == LetterTile.NotchTypes.PATIENT:
		letter_score += self.tile.current_age * 2
	if self.tile.notch2 == LetterTile.NotchTypes.PATIENT:
		letter_score += self.tile.current_age * 2
	if self.tile.notch3 == LetterTile.NotchTypes.PATIENT:
		letter_score += self.tile.current_age * 2

	if self.tile.notch1 == LetterTile.NotchTypes.QUICK and self.tile.current_age == 0:
		letter_score += 5
	if self.tile.notch2 == LetterTile.NotchTypes.QUICK and self.tile.current_age == 0:
		letter_score += 5
	if self.tile.notch3 == LetterTile.NotchTypes.QUICK and self.tile.current_age == 0:
		letter_score += 5

	if self.tile.notch1 == LetterTile.NotchTypes.DISTANT:
		letter_score += self.tile.word_index
	if self.tile.notch2 == LetterTile.NotchTypes.DISTANT:
		letter_score += self.tile.word_index
	if self.tile.notch3 == LetterTile.NotchTypes.DISTANT:
		letter_score += self.tile.word_index
		
	if self.tile.notch1 == LetterTile.NotchTypes.LOCAL:
		letter_score += (self.tile.word_length - self.tile.word_index - 1)
	if self.tile.notch2 == LetterTile.NotchTypes.LOCAL:
		letter_score += (self.tile.word_length - self.tile.word_index - 1)
	if self.tile.notch3 == LetterTile.NotchTypes.LOCAL:
		letter_score += (self.tile.word_length - self.tile.word_index - 1)

	if self.tile.notch1 == LetterTile.NotchTypes.BALANCED:
		if self.tile.word_length == self.tile.word_index:
			letter_score += 0
		elif floor(self.tile.word_length / 2.0) - self.tile.word_index == 0:
			if self.tile.word_length % 2 == 1:
				letter_score += 2 * self.tile.word_index
			else:
				letter_score += (2 * (self.tile.word_index - 1))
		elif self.tile.word_index < floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_index)
		elif self.tile.word_index >= floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_length - self.tile.word_index - 1)
			
	if self.tile.notch2 == LetterTile.NotchTypes.BALANCED:
		if self.tile.word_length == self.tile.word_index:
			letter_score += 0
		elif floor(self.tile.word_length / 2.0) - self.tile.word_index == 0:
			if self.tile.word_length % 2 == 1:
				letter_score += 2 * self.tile.word_index
			else:
				letter_score += (2 * (self.tile.word_index - 1))
		elif self.tile.word_index < floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_index)
		elif self.tile.word_index >= floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_length - self.tile.word_index - 1)

	if self.tile.notch3 == LetterTile.NotchTypes.BALANCED:
		if self.tile.word_length == self.tile.word_index:
			letter_score += 0
		elif floor(self.tile.word_length / 2.0) - self.tile.word_index == 0:
			if self.tile.word_length % 2 == 1:
				letter_score += 2 * self.tile.word_index
			else:
				letter_score += (2 * (self.tile.word_index - 1))
		elif self.tile.word_index < floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_index)
		elif self.tile.word_index >= floor(self.tile.word_length / 2.0):
			letter_score += 2 * (self.tile.word_length - self.tile.word_index - 1)

	return letter_score

func juice_score():
	var current_size = self.scale
	scale_tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", self.scale * 1.35, 0.1)
	tween2.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 1, 0.1)
	scale_tween.tween_property(self, "scale", self.scale / 1.35, 0.01)
	tween2.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 0, 0.01)
	scale_tween.tween_property(self, "scale", current_size, 0.001)
	return true

func update_tile_score_text(tile_score: int, hide_text: bool = false):
	if hide_text:
		var tween = get_tree().create_tween()
		tween.tween_property(%TileScoreText, "modulate:a", 0, 0.05)
		%TileScoreText.visible = false
	
	if not %TileScoreText.visible and not hide_text:
		var tween = get_tree().create_tween()
		tween.tween_property(%TileScoreText, "modulate:a", 1, 0.1)
		%TileScoreText.visible = true
	
	if not hide_text:
		%TileScoreText.set_text("+" + str(tile_score))

func toggle_monitorable() -> void:

	%Notch1Area.monitorable = false
	%Notch2Area.monitorable = false
	%Notch3Area.monitorable = false
	%Notch1AreaPoly.disabled = false
	%Notch2AreaPoly.disabled = false
	%Notch3AreaPoly.disabled = false

	if self.tile.notch1 == LetterTile.NotchTypes.EMPTY:
		%Notch1Area.monitorable = true
	
	if self.tile.notch2 == LetterTile.NotchTypes.EMPTY:
		%Notch2Area.monitorable = true

	if self.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		%Notch3Area.monitorable = true

#set_tooltip_text("Letter Tile!\n 
				  #Type: self.type\n 
				  #Letter: self.letter\n 
				  #Notch 1: self.notch1\n
				  #Notch 2: self.notch2\n
				  #Notch 3: self.notch3\n
				  #Tile Index: self.tile_index")
