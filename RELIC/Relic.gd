extends Control
class_name Relic

@onready var sprite = $Relic_Button/Relic_Sprite

signal relic_hovered(which: Relic, is_hovering: bool)
signal relic_clicked(which: Relic, action: RelicAction)

var original_z = self.z_index
var total_activations := 0

enum RelicAction {FIDGET, VIEW}
enum RelicRarity {COMMON, UNCOMMON, RARE, BOSS, EVENT, CURSE, UNDEFINED}

var relic_id := 0
var relic_name := ""
var relic_rarity := RelicRarity.UNDEFINED
var relic_description := ""
var relic_flavor_text := ""

func _ready():
	self.pivot_offset = Vector2(16, 16)
	get_relic_sprite(relic_id)

func get_relic_sprite(relic_id):
	$Relic_Button/Relic_Sprite.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)))
	$Relic_Button/Relic_Mask.set_frame_coords(Vector2i((relic_id % 10), floor(relic_id / 10)+1))

## Juicifier for when you hover the relic
func _on_relic_button_mouse_entered():
	#print("I've been entered!")
	original_z = self.z_index
	self.scale = self.scale * 1.1
	self.z_index = 128
	relic_hovered.emit(self, true)

## Juicifier for when you unhover the relic
func _on_relic_button_mouse_exited():
	#print("I've been exited!")
	self.scale = self.scale / 1.1
	self.z_index = original_z
	relic_hovered.emit(self, false)

func _on_relic_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left Clackety!")
			relic_clicked.emit(
				self, RelicAction.FIDGET
			)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right Clackety!")
			relic_clicked.emit(
				self, RelicAction.VIEW
			)

func juice_relic(): 
	var current_size = Vector2(1, 1)
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(sprite, "scale", self.scale * 1.05, 0.005)
	tween2.tween_property($Relic_Button/Relic_Mask, "modulate:a", 1, 0.1)
	tween.tween_property(sprite, "scale", current_size, 0.1)
	tween2.tween_property($Relic_Button/Relic_Mask, "modulate:a", 0, 0.01)

# Everything below here pertains to individual relics.
## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	return null
	
## Function that handles what should happen at the start of each turn.
func on_turn_start():
	return 0

## Function that handles what should happen at the end of each turn.
func on_turn_end():
	return 0

## Function that handles what should happen at the start of each combat.
func on_combat_start():
	return 0

## Function that handles what should happen at the end of each combat.
func on_combat_end():
	return 0

func word_length_bonus_effect(_word):
	return 0

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a multiplier effect.
func word_score_multiplier_effect(_word):
	return 1

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a bonus scoring effect for each letter in the word.
func word_tile_bonus_score_effect(_word):
	return 0

## Function that handles what should happen when a specific letter, kind of letter, etc is played.
func letter_score_effect(_letter, _word):
	return 0
	
## Function that happens every "x" letters played.
func x_letters_played_effect(_scored_letter_count, _letter_score, _word):
	return 0

## Function that handles what should happen if a tile has a certain grid index.
func grid_index_effect(_grid_index, _word):
	return 0

## Function that handles what should happen if a letter needs to be retriggered.
func letter_retrigger_effect(_letter, _word):
	return 0

## Function that handles what should happen if a word needs to be retriggered.
func word_retrigger_effect(_word):
	return 0
