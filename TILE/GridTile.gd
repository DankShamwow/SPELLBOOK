extends Control
class_name GridTile

@onready var tile: LetterTile
@onready var sprite = $Tile_Button/Tile_Sprite

var original_z = self.z_index

enum GridTileAction {
	PLAY, VIEW
}

var point_values  	= [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

signal tile_hovered(which: GridTile, is_hovering: bool)
signal tile_clicked(which: GridTile, action: GridTileAction)

func _make_custom_tooltip(_for_text: String) -> Object:
	var tooltip_scene: PackedScene = load("res://TILE/TileTooltip.tscn")
	var tile_tooltip: VBoxContainer = tooltip_scene.instantiate()
	tile_tooltip.id_box.get_child(0).text = "Letter Tile"
	tile_tooltip.type_box.get_child(1).text = str(tile.TileType.keys()[tile.type]).to_pascal_case()
	tile_tooltip.letter_box.get_child(1).text = str(tile.TileLetter.keys()[tile.letter]).to_pascal_case()
	tile_tooltip.notch1_box.get_child(1).text = str(tile.NotchTypes.keys()[tile.notch1]).to_pascal_case()
	tile_tooltip.notch2_box.get_child(1).text = str(tile.NotchTypes.keys()[tile.notch2]).to_pascal_case()
	tile_tooltip.notch3_box.get_child(1).text = str(tile.NotchTypes.keys()[tile.notch3]).to_pascal_case()
	tile_tooltip.tile_index_box.get_child(1).text = str(tile.tile_index)
	return tile_tooltip

func _ready():
	## For testing purposes only
	#var hasOverlay = randi_range(0, 5)
	#$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(hasOverlay, 0))
	#$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(randi_range(0, 25), 1))
	#$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(hasOverlay, 3))
	##$Tile_Button/Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(tile.notch1, 4))
	##$Tile_Button/Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(tile.notch2, 5))
	##$Tile_Button/Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(tile.notch3, 6))

	##This is the one we use outside of testing, at least when not testing the tile directly.
	$Tile_Button/Tile_Sprite/Tile_Type.set_frame_coords(Vector2i(tile.type, 0))
	$Tile_Button/Tile_Sprite/Tile_Letter.set_frame_coords(Vector2i(tile.letter, 1))
	$Tile_Button/Tile_Sprite/Tile_Overlay_Sprite.set_frame_coords(Vector2i(tile.type, 3))
	#$Tile_Sprite/Notch_1_Sprite.set_frame_coords(Vector2i(self.notch1, 4))
	#$Tile_Sprite/Notch_2_Sprite.set_frame_coords(Vector2i(self.notch2, 5))
	#$Tile_Sprite/Notch_3_Sprite.set_frame_coords(Vector2i(self.notch3, 6))

func fade():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.1)
	
func unfade():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	
func mark_buffer():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0.7, 0.3, 0.3, 0.7), 0.1)
	
func _on_tile_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left Clickety!")
			tile_clicked.emit(
				self, GridTileAction.PLAY
			)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right Clickety!")
			tile_clicked.emit(
				self, GridTileAction.PLAY
			)

func _on_tile_button_mouse_entered():
	#print("I've been entered!")
	self.scale = Vector2(1.1, 1.1)
	self.z_index = 128
	tile_hovered.emit(self, true)

func _on_tile_button_mouse_exited():
	#print("I've been exited!")
	self.scale = Vector2(1, 1)
	self.z_index = original_z
	tile_hovered.emit(self, false)

func is_dying():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 0), 0.5)
	tween2.tween_property(sprite, "scale", Vector2(0, 0), 0.5)
	
func scale_to_word_size(scaling_factor):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(scaling_factor, scaling_factor), 0.1)
	
func scale_back_to_grid():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.01)

## Function that handles the scoring of a tile.
func score_tile():
	var letter_score = 0
	if self.tile.type == 0 or self.tile.type == 2:
		letter_score += point_values[self.tile.letter]
		juice_score()
		return letter_score

		
	elif self.tile.type == 1:
		letter_score += 0
		juice_score()
		return letter_score


	elif self.tile.type == 3:
		letter_score += point_values[self.tile.letter]
		juice_score()
		return letter_score

	
	elif self.tile.type == 4:
		letter_score += point_values[self.tile.letter] - 1
		if letter_score == 0:
			letter_score += 1
		juice_score()
		return letter_score

	return letter_score

func juice_score():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(self.scale.x*1.2, self.scale.y*1.2), 0.1)
	tween2.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 1, 0.1)
	tween.tween_property(sprite, "scale", Vector2(self.scale.x/1.2, self.scale.y/1.2), 0.01)
	tween2.tween_property($Tile_Button/Tile_Sprite/Tile_Mask, "modulate:a", 0, 0.01)

#set_tooltip_text("Letter Tile!\n 
				  #Type: self.type\n 
				  #Letter: self.letter\n 
				  #Notch 1: self.notch1\n
				  #Notch 2: self.notch2\n
				  #Notch 3: self.notch3\n
				  #Tile Index: self.tile_index")
