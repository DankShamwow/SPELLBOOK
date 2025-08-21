extends Control
class_name MiniGridTile

@onready var tile: LetterTile
@onready var sprite = $Tile_Button/Tile_Sprite

var tiles_in_play = GeneralManager.tiles_in_play
var buffered_tiles = GeneralManager.buffered_tiles
var available_tiles = GeneralManager.available_tiles
var point_values  	= GeneralManager.point_values

var original_z = self.z_index

enum MiniGridTileAction {
	PLAY, VIEW
}

var bag_open = false

signal tile_hovered(which: MiniGridTile, is_hovering: bool)
signal tile_clicked(which: MiniGridTile, action: MiniGridTileAction)

func _ready():
	##This is the one we use outside of testing, at least when not testing the tile directly.
	$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(tile.type, 0))
	$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(tile.visual_letter, 1))
	$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(tile.type, 3))
	#$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(tile.notch1, 3))
	#$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(tile.notch2, 4))
	#$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(tile.notch3, 5))

	## For testing purposes only
	#var hasOverlay = randi_range(0, 5)
	#$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(hasOverlay, 0))
	#$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(randi_range(0, 25), 1))
	#$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(hasOverlay, 3))
	##$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(tile.notch1, 4))
	##$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(tile.notch2, 5))
	##$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(tile.notch3, 6))

func update_tile_graphics():
	print("Updating graphics...")
	
	var tween = get_tree().create_tween()
	tween.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 1, 0.1)
	tween.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 0, 0.01)
	
	var new_type = tile.type
	var played_letter = tile.played_letter
	var visual_letter = tile.visual_letter
	var new_notch1 = tile.notch1
	var new_notch2 = tile.notch2
	var new_notch3 = tile.notch3
	
	$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(new_type, 0))
	$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(visual_letter, 1))
	$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(new_type, 3))
	#$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(new_notch1, 3))
	#$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(new_notch2, 4))
	#$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(new_notch3, 5))

func move_to_position(time:= 0.25):
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", tile.target, time)
	await get_tree().create_timer(time/2).timeout
	return true

func play_tile_sound():
	if not $TileSoundAttempt3.is_playing():
		$TileSoundAttempt3.play()

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
			tile_clicked.emit(
				self, MiniGridTileAction.PLAY
			)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right Clickety!")
			play_tile_sound()
			tile_clicked.emit(
				self, MiniGridTileAction.VIEW
			)

func _on_tile_button_mouse_entered():
	#print("I've been entered!")
	original_z = self.z_index
	self.scale = self.scale * 1.1
	self.z_index = 1024
	tile_hovered.emit(self, true)

func _on_tile_button_mouse_exited():
	#print("I've been exited!")
	self.scale = self.scale / 1.1
	self.z_index = original_z
	tile_hovered.emit(self, false)

func spawned_in():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.000001)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)

func spawned_from_bag():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.000001)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.05)
	tween2.tween_property(sprite, "scale", Vector2(0, 0), 0.000001)
	tween2.tween_property(sprite, "scale", Vector2(1, 1), 0.05)

func is_dying():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 0), 0.1)
	tween2.tween_property(sprite, "scale", Vector2(0, 0), 0.1)
	
func is_being_bagged():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.25)
	tween2.tween_property(sprite, "scale", Vector2(0, 0), 0.05)
	
	await get_tree().create_timer(0.25).timeout
	self.queue_free()
	
func scale_to_word_size(scaling_factor):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(scaling_factor, scaling_factor), 0.1)
	
func scale_back_to_grid():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.01)

## Function that handles the scoring of a tile.
func score_tile():
	var letter_score = 0
	if self.tile.type == LetterTile.TileType.BASIC or self.tile.type == LetterTile.TileType.LOCKED:
		letter_score += point_values[self.tile.letter]
		await juice_score()

	elif self.tile.type == LetterTile.TileType.STONED:
		letter_score += 0
		await juice_score()
		
	elif self.tile.type == LetterTile.TileType.BURNING:
		letter_score += point_values[self.tile.letter]
		await juice_score()
		
	elif self.tile.type == LetterTile.TileType.PLAGUED:
		letter_score += point_values[self.tile.letter] - 1
		if letter_score == 0:
			letter_score += 1
		await juice_score()

	elif self.tile.type == LetterTile.TileType.CRUMBLING:
		letter_score += point_values[self.tile.letter]
		await juice_score()

	return letter_score

func score_tile_quiet():
	var letter_score = 0
	if self.tile.type == 0 or self.tile.type == 2:
		letter_score += point_values[self.tile.letter]

	elif self.tile.type == 1:
		letter_score += 0
		
	elif self.tile.type == 3:
		letter_score += point_values[self.tile.letter]
		
	elif self.tile.type == 4:
		letter_score += point_values[self.tile.letter] - 1
		if letter_score == 0:
			letter_score += 1

	return letter_score

func juice_score():
	var current_size = self.scale
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(self, "scale", self.scale * 1.35, 0.1)
	tween2.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 1, 0.1)
	tween.tween_property(self, "scale", current_size, 0.01)
	tween2.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 0, 0.01)
	return true
#set_tooltip_text("Letter Tile!\n 
				  #Type: self.type\n 
				  #Letter: self.letter\n 
				  #Notch 1: self.notch1\n
				  #Notch 2: self.notch2\n
				  #Notch 3: self.notch3\n
				  #Tile Index: self.tile_index")
