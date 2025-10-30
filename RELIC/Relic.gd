extends Control
## Relic is the class for the items collected by the player.
class_name Relic

var original_z = self.z_index
var total_activations: int

var various_rng = RandomnessManager.various_rng

## RelicAction is responsible for handling left/right clicks.
enum RelicAction {FIDGET, VIEW}
## RelicRarity is responsible for classifying a relic's rarity.
enum RelicRarity {COMMON, COMMON_BOOK, UNCOMMON, UNCOMMON_BOOK, RARE, RARE_BOOK, BOSS, BOSS_BOOK, EVENT, EVENT_BOOK, CURSE, CURSE_BOOK, SHOP, SHOP_BOOK, UNDEFINED}
## RelicType determines a relic's type.
enum RelicType   {RELIC, BOOK, UNDEFINED}

@export var relic_id := 0
var relic_name := ""
var relic_rarity: RelicRarity
var relic_type: RelicType
var relic_description := ""
var relic_flavor_text := ""

## Player Related variables
var player_relic_index: int
var owned_book_index: int

## Library Related Variables
var library_relic_index: int
var borrowed: bool = false
var just_exchanged: bool = false
var just_borrowed: bool = false

## Functional Variables
var grumble_tween: Tween
var scale_tween: Tween
var hovering: bool = false
var purchase_price: int = 0

func _ready():
	self.pivot_offset = Vector2(16, 16)
	get_relic_sprite(relic_id)
	%Relic_Label.set_text("")
	total_activations = 0

func _process(_delta: float) -> void:
	if get_viewport().has_focus():
		if not GeneralManager.scoring_is_active and not scale_tween and not hovering and not scale == is_at_scale() and not self.get_parent().name == "ShopKillParent":
			determine_relic_scale()
		
		if not scale_tween == null:
			if not GeneralManager.scoring_is_active and not scale_tween.is_valid() and not scale_tween.is_running() and not hovering and not scale == is_at_scale() and not self.get_parent().name == "ShopKillParent":
				determine_relic_scale()

@warning_ignore("shadowed_variable")
func get_relic_sprite(relic_id):
	%Relic_Sprite.set_frame_coords(Vector2i(relic_id % 10, floor(relic_id / 10.0)))
	%Relic_Mask.set_frame_coords(Vector2i(relic_id % 10, floor(relic_id / 10.0)))

func is_at_scale():
	var scaling_factor: float = 1.0
	if self.is_in_group("Owned Relics to Exchange") or self.is_in_group("Library Relics to Exchange"):
		if hovering:
			scaling_factor = 1.15 * 1.1
		else:
			scaling_factor = 1.15
	
	elif self.is_in_group("Relics to Borrow") or self.is_in_group("Relics to Purchase"):
		if hovering:
			scaling_factor = 2.3 * 1.1
		else:
			scaling_factor = 2.3
	
	elif self.get_parent().name == "BorrowBookParent" or self.get_parent().name == "BrowseBookParent":
		if hovering:
			scaling_factor = 2.2
		else:
			scaling_factor = 2.0
	
	else:
		if hovering:
			scaling_factor = 1.1
		else:
			scaling_factor = 1.0
			
	var scalar = Vector2(scaling_factor, scaling_factor)
	
	return scalar

func determine_relic_scale(speed: float = 0.1):
	var scaling_factor: float = 1.0
	if self.is_in_group("Owned Relics to Exchange") or self.is_in_group("Library Relics to Exchange"):
		if hovering:
			scaling_factor = 1.15 * 1.1
		else:
			scaling_factor = 1.15
	
	elif self.is_in_group("Relics to Borrow") or self.is_in_group("Relics to Purchase"):
		if hovering:
			scaling_factor = 2.3 * 1.1
		else:
			scaling_factor = 2.3
	
	elif self.get_parent().name == "BorrowBookParent" or self.get_parent().name == "BrowseBookParent":
		if hovering:
			scaling_factor = 2.2
		else:
			scaling_factor = 2.0
	
	else:
		if hovering:
			scaling_factor = 1.1
		else:
			scaling_factor = 1.0
	
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(scaling_factor, scaling_factor), speed)

## Juicifier for when you hover the relic
func _on_relic_button_mouse_entered():
	hovering = true
	#print("I've been entered!")
	original_z = self.z_index
	self.z_index = 128
	determine_relic_scale(0.025)
	GameEventHandler.relic_hovered.emit(self, true)

## Juicifier for when you unhover the relic
func _on_relic_button_mouse_exited():
	hovering = false
	#print("I've been exited!")
	self.z_index = original_z
	determine_relic_scale()
	GameEventHandler.relic_hovered.emit(self, false)

func _on_relic_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Left Clackety!")
			GameEventHandler.relic_clicked.emit(
				self, RelicAction.FIDGET
			)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			#print("Right Clackety!")
			GameEventHandler.relic_clicked.emit(
				self, RelicAction.VIEW
			)

func juice_relic(): 
	var current_size = Vector2(1, 1)
	scale_tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	scale_tween.tween_property(%Relic_Sprite, "scale", self.scale * 1.05, 0.005)
	tween2.tween_property(%Relic_Mask, "modulate:a", 1, 0.1)
	scale_tween.tween_property(%Relic_Sprite, "scale", current_size, 0.1)
	tween2.tween_property(%Relic_Mask, "modulate:a", 0, 0.01)

func juice_relic_to_new_sprite():
	var current_size = Vector2(1, 1)
	scale_tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	scale_tween.tween_property(%Relic_Sprite, "scale", self.scale * 1.05, 0.005)
	tween2.tween_property(%Relic_Mask, "modulate:a", 1, 0.1)
	scale_tween.tween_property(%Relic_Sprite, "scale", current_size, 0.1)
	tween2.tween_property(%Relic_Mask, "modulate:a", 0, 0.01)
	_ready()

func grumble_relic():
	if not grumble_tween:
		var current_position = self.position
		grumble_tween = get_tree().create_tween()
		scale_tween = get_tree().create_tween()
		var tween = get_tree().create_tween()
		
		tween.tween_property(self, "modulate", Color(0.35, 0.0, 0.0, 1.0), 0.01)
		tween.tween_interval(0.13)
		scale_tween.tween_property(self, "scale", self.scale * 0.75, 0.03)
		scale_tween.tween_callback(determine_relic_scale.bind(0.03)).set_delay(0.08)
		var grumble_order = various_rng.randi_range(0, 1)
		
		if grumble_order == 0:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
		
		if grumble_order == 1:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
		
		grumble_tween.tween_property(self, "position", current_position, 0.05)
		
		
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.01)
		
	if not grumble_tween.is_valid():
		var current_position = self.position
		grumble_tween = get_tree().create_tween()
		scale_tween = get_tree().create_tween()
		var tween = get_tree().create_tween()
		
		tween.tween_property(self, "modulate", Color(0.75, 0.0, 0.0, 1.0), 0.01)
		tween.tween_interval(0.13)
		scale_tween.tween_property(self, "scale", self.scale * 0.75, 0.03)
		scale_tween.tween_callback(determine_relic_scale.bind(0.03)).set_delay(0.08)
		
		var grumble_order = various_rng.randi_range(0, 1)
		
		if grumble_order == 0:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
		
		if grumble_order == 1:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
		
		grumble_tween.tween_property(self, "position", current_position, 0.05)
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.01)

# Everything below here pertains to individual relics.
## Function that handles what should happen when you pick up a relic
func on_pickup_effect():
	return null
	
## Function that handles what should happen at the start of each turn.
func on_turn_start(_turn: int = 0):
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
func word_length_bonus_effect(_word):
	return 0

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a multiplier effect.
func word_score_multiplier_effect(_word, _target = null):
	return 1

## Function that handles what should happen when a specific word, word stem, or kind of word is played and has a bonus scoring effect for each letter in the word.
func word_tile_bonus_score_effect(_word):
	return 0

## Function that handles what should happen when a specific letter, kind of letter, etc is played.
func letter_score_effect(_letter, _word, _target, _tile_score):
	return 0

## Function that handles what should happen if a word triggers a non-scoring effect for a relic.
func word_played_effect(_word, _target = null):
	return 0
	
## Function that happens every "x" letters played.
func x_letters_played_effect(_letter_score: int, _word: String):
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

## Function that determines if a tile should echo for any special reason.
func tile_echo_effect(_tile: LetterTile):
	return null

## Function for the Sentence Mixer relic.
func mixer_check(_word: String):
	return null

## Function to check if a debuff's amount or duration needs to be boosted.
func debuff_boost(_debuff: String):
	return 0
