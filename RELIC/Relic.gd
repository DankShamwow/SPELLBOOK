extends Control
class_name Relic

signal relic_clicked(which: Relic, action: RelicAction)

var original_z = self.z_index
var total_activations: int

enum RelicAction {FIDGET, VIEW}
enum RelicRarity {COMMON, COMMON_BOOK, UNCOMMON, UNCOMMON_BOOK, RARE, RARE_BOOK, BOSS, BOSS_BOOK, EVENT, EVENT_BOOK, CURSE, CURSE_BOOK, UNDEFINED}

@export var relic_id := 0
var relic_name := ""
var relic_rarity := RelicRarity.UNDEFINED
var relic_description := ""
var relic_flavor_text := ""

func _ready():
	self.pivot_offset = Vector2(16, 16)
	get_relic_sprite(relic_id)
	%Relic_Label.set_text("")
	total_activations = 0

func get_relic_sprite(relic_id):
	%Relic_Sprite.set_frame_coords(Vector2i(relic_id % 10, floor(relic_id / 10.0)))
	%Relic_Mask.set_frame_coords(Vector2i(relic_id % 10, floor(relic_id / 10.0)))

## Juicifier for when you hover the relic
func _on_relic_button_mouse_entered():
	#print("I've been entered!")
	original_z = self.z_index
	self.scale = self.scale * 1.1
	self.z_index = 128
	GameEventHandler.relic_hovered.emit(self, true)

## Juicifier for when you unhover the relic
func _on_relic_button_mouse_exited():
	#print("I've been exited!")
	self.scale = self.scale / 1.1
	self.z_index = original_z
	GameEventHandler.relic_hovered.emit(self, false)

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
	tween.tween_property(%Relic_Sprite, "scale", self.scale * 1.05, 0.005)
	tween2.tween_property(%Relic_Mask, "modulate:a", 1, 0.1)
	tween.tween_property(%Relic_Sprite, "scale", current_size, 0.1)
	tween2.tween_property(%Relic_Mask, "modulate:a", 0, 0.01)

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

## Function that handles whether or not a word should receive a length bonus.
func word_length_bonus_effect(word):
	return 0

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a multiplier effect.
func word_score_multiplier_effect(word, target = null):
	return 1

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a bonus scoring effect for each letter in the word.
func word_tile_bonus_score_effect(word):
	return 0

## Function that handles what should happen when a specific letter, kind of letter, etc is played.
func letter_score_effect(letter, word, target, tile_score):
	return 0

## Function that handles what should happen if a word triggers a non-scoring effect for a relic.
func word_played_effect(word, target = null):
	return 0
	
## Function that happens every "x" letters played.
func x_letters_played_effect(scored_letter_count: int, letter_score: int, word: String):
	return 0

## Function that handles what should happen if a tile has a certain grid index.
func grid_index_effect(grid_index, word):
	return 0

## Function that handles what should happen if a letter needs to be retriggered.
func letter_retrigger_effect(letter, word):
	return 0

## Function that handles what should happen if a word needs to be retriggered.
func word_retrigger_effect(word):
	return 0

## Function that checks to see if a word has been mangled in any way, such as for any added prefixes and suffixes.
func mangle_check(word: String, prefix_1: String = "", prefix_2: String = "", prefix_3: String = "", suffix_1: String = "", suffix_2: String = "", suffix_3: String = ""):
	return null

## Function for the Sentence Mixer relic.
func mixer_check(word: String, prefix_1: String = "", prefix_2: String = "", prefix_3: String = "", suffix_1: String = "", suffix_2: String = "", suffix_3: String = ""):
	return null

## Function to check if a debuff's amount or duration needs to be boosted.
func debuff_boost(debuff: String):
	return 0
