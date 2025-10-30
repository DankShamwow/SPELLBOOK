extends PanelContainer
class_name IntentTooltip

@export var fade_seconds := 0.2

var tween: Tween

@warning_ignore("shadowed_variable_base_class")
var is_visible := false

var point_values  	:= GeneralManager.point_values
var status_dictionary = StatusDictionary.StatusEffectList

var minimum_size = get_minimum_size()
var description_size = Vector2()

const MINI_GRID_TILE_SCENE: PackedScene = preload("res://TILE/GRID_TILE/MiniGridTile.tscn")
const STATUS_EFFECT_SCENE: PackedScene = preload("res://COMBAT/STATUSES/StatusEffect.tscn")

func _ready() -> void:
	description_size = %IntentDescription.size
	modulate = Color.TRANSPARENT
	hide()

func _process(_delta):
	var screensize = get_viewport().get_visible_rect().size
	var current_size = self.size
	var tooltip_pos = get_global_mouse_position()
	self.position.x = clamp(tooltip_pos.x, 0, (screensize.x - current_size.x - 16))
	self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))

func _on_intent_hovered(which: IntentIcon, is_hovering: bool) -> void:
	
	for i in %WordContainer.get_child_count():
			%WordContainer.get_child(-1).free()
	
	if is_hovering:
		var text_desc = []
		var final_desc_text = ""
		
		is_visible = true
		if tween:
			tween.kill()
		
		%IntentTexture.texture.region = Rect2(24*which.type, 0, 24, 24)
		%IntentHeader.set_text(which.IntentNames.get(which.IntentType.keys()[which.type]))
		
		if which.is_intent:
			for i in which.related_enemy.enemy_attack_list[which.related_attack].size():
				var attack = which.related_enemy.enemy_attack_list[which.related_attack]
				var new_tile = MINI_GRID_TILE_SCENE.instantiate()
				new_tile.tile = which.related_enemy.current_enemy_deck[attack[i]]
				%WordContainer.add_child(new_tile)
				
			var attack_score_value = RichTextLabel.new()
			attack_score_value.set_text(str(_calc_enemy_word_score(which.related_enemy, which.related_enemy.enemy_attack_list[which.related_attack], which.type)))
			attack_score_value.set_fit_content(true)
			
			@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
			attack_score_value.set_autowrap_mode(0)
			attack_score_value.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
			%WordContainer.add_child(attack_score_value)
			
			if not which.related_enemy.enemy_status_package_list[which.related_attack].is_empty():
				var status_package = which.related_enemy.enemy_status_package_list[which.related_attack]
				for j in status_package.size():
					var subpackage = status_package[j]
					var new_status = status_dictionary.get(subpackage[0])
					var status_icon = STATUS_EFFECT_SCENE.instantiate()
					status_icon.set_script(new_status)
					status_icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					%WordContainer.add_child(status_icon)
					status_icon.amount = subpackage[1]
					status_icon.does_decay = bool(subpackage[2])
					status_icon.duration = subpackage[3]
					status_icon._update_graphics()
					if j > 0:
						text_desc.append("\n")
					text_desc.append(status_icon.status_name)
					text_desc.append(": ")
					text_desc.append(status_icon.status_description)
			
			%IntentDescription.set_text(final_desc_text.join(text_desc))
			
		self.size = get_minimum_size()
			
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(show)
		tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)
		
	else:
		is_visible = false
		if tween:
			tween.kill()
		
		hide_animation()

func hide_animation() -> void:
	if not is_visible:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
		tween.tween_callback(hide)
	else:
		pass

func _calc_enemy_word_score(enemy: Enemy, word: Array, type: int):
	var tile_score = 0
	var points_score = 0
	var mult_score = 0
	var total_score = 0
	var tile_retriggers = 0
	var context_power = 0
	var bonus_word_length = 0
	var word_index = 0
	
	if type == 1 or type == 6 or type == 7:
		# Query Dexterity
		context_power += enemy.query_status_value(13)
		# Query Intelligence
		bonus_word_length += enemy.query_status_value(14)

	if type == 0 or type == 4 or type == 5:
		# Query Strength
		context_power += enemy.query_status_value(12)
		# Query Intelligence
		bonus_word_length += enemy.query_status_value(14)
	
	for i in word.size():
		
		var word_length = word.size()
		var scored_tile = enemy.current_enemy_deck[word[i]]
		
		if scored_tile.type == LetterTile.TileType.LOCKED:
			continue
		
		scored_tile.word_index = word_index
		scored_tile.word_length = word.size()
		
		word_index += 1
		
		# Query for Repeating notches
		if scored_tile.notch1 == LetterTile.NotchTypes.REPEATING:
			tile_retriggers += 1
		if scored_tile.notch2 == LetterTile.NotchTypes.REPEATING:
			tile_retriggers += 1
		if scored_tile.notch3 == LetterTile.NotchTypes.REPEATING:
			tile_retriggers += 1
		
		for j in tile_retriggers + 1:
			tile_score += _score_tile_quiet(scored_tile)
			tile_score += context_power
			
		points_score += tile_score
		
		tile_score = 0
		tile_retriggers = 0

		mult_score = floor((word_length + bonus_word_length) / 2)
		
	total_score = points_score * mult_score
	
	return total_score

# This is here for dumb reasons.
func _score_tile_quiet(scored_tile):
	var letter_score = 0
	if scored_tile.type == LetterTile.TileType.BASIC or scored_tile.type == LetterTile.TileType.LOCKED:
		letter_score += point_values[scored_tile.played_letter]

	elif scored_tile.type == LetterTile.TileType.STONED:
		letter_score += 0
		
	elif scored_tile.type == LetterTile.TileType.BURNING:
		letter_score += point_values[scored_tile.played_letter]
		
	elif scored_tile.type == LetterTile.TileType.PLAGUED:
		letter_score += point_values[scored_tile.played_letter] - 1
		if letter_score == 0:
			letter_score += 1

	elif scored_tile.type == LetterTile.TileType.CRUMBLING:
		letter_score += point_values[scored_tile.played_letter]

	if scored_tile.notch1 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if scored_tile.notch2 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if scored_tile.notch3 == LetterTile.NotchTypes.POTENT:
		letter_score += 3

	if scored_tile.notch1 == LetterTile.NotchTypes.PATIENT:
		letter_score += scored_tile.current_age * 2
	if scored_tile.notch2 == LetterTile.NotchTypes.PATIENT:
		letter_score += scored_tile.current_age * 2
	if scored_tile.notch3 == LetterTile.NotchTypes.PATIENT:
		letter_score += scored_tile.current_age * 2

	if scored_tile.notch1 == LetterTile.NotchTypes.QUICK and scored_tile.current_age == 0:
		letter_score += 5
	if scored_tile.notch2 == LetterTile.NotchTypes.QUICK and scored_tile.current_age == 0:
		letter_score += 5
	if scored_tile.notch3 == LetterTile.NotchTypes.QUICK and scored_tile.current_age == 0:
		letter_score += 5

	if scored_tile.notch1 == LetterTile.NotchTypes.DISTANT:
		letter_score += scored_tile.word_index
	if scored_tile.notch2 == LetterTile.NotchTypes.DISTANT:
		letter_score += scored_tile.word_index
	if scored_tile.notch3 == LetterTile.NotchTypes.DISTANT:
		letter_score += scored_tile.word_index
		
	if scored_tile.notch1 == LetterTile.NotchTypes.LOCAL:
		letter_score += (scored_tile.word_length - scored_tile.word_index - 1)
	if scored_tile.notch2 == LetterTile.NotchTypes.LOCAL:
		letter_score += (scored_tile.word_length - scored_tile.word_index - 1)
	if scored_tile.notch3 == LetterTile.NotchTypes.LOCAL:
		letter_score += (scored_tile.word_length - scored_tile.word_index - 1)

	if scored_tile.notch1 == LetterTile.NotchTypes.BALANCED:
		if scored_tile.word_length == scored_tile.word_index:
			letter_score += 0
		elif floor(scored_tile.word_length / 2.0) - scored_tile.word_index == 0:
			if scored_tile.word_length % 2 == 1:
				letter_score += 2 * scored_tile.word_index
			else:
				letter_score += (2 * (scored_tile.word_index - 1))
		elif scored_tile.word_index < floor(scored_tile.word_length / 2.0):
			letter_score += 2 * (scored_tile.word_index)
		elif scored_tile.word_index >= floor(scored_tile.word_length / 2.0):
			letter_score += 2 * (scored_tile.word_length - scored_tile.word_index - 1)
			
	if scored_tile.notch2 == LetterTile.NotchTypes.BALANCED:
		if scored_tile.word_length == scored_tile.word_index:
			letter_score += 0
		elif floor(scored_tile.word_length / 2.0) - scored_tile.word_index == 0:
			if scored_tile.word_length % 2 == 1:
				letter_score += 2 * scored_tile.word_index
			else:
				letter_score += (2 * (scored_tile.word_index - 1))
		elif scored_tile.word_index < floor(scored_tile.word_length / 2.0):
			letter_score += 2 * (scored_tile.word_index)
		elif scored_tile.word_index >= floor(scored_tile.word_length / 2.0):
			letter_score += 2 * (scored_tile.word_length - scored_tile.word_index - 1)

	if scored_tile.notch3 == LetterTile.NotchTypes.BALANCED:
		if scored_tile.word_length == scored_tile.word_index:
			letter_score += 0
		elif floor(scored_tile.word_length / 2.0) - scored_tile.word_index == 0:
			if scored_tile.word_length % 2 == 1:
				letter_score += 2 * scored_tile.word_index
			else:
				letter_score += (2 * (scored_tile.word_index - 1))
		elif scored_tile.word_index < floor(scored_tile.word_length / 2.0):
			letter_score += 2 * (scored_tile.word_index)
		elif scored_tile.word_index >= floor(scored_tile.word_length / 2.0):
			letter_score += 2 * (scored_tile.word_length - scored_tile.word_index - 1)

	return letter_score
