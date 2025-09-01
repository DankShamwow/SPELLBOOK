extends PanelContainer
class_name TileTooltip

var point_values  	= GeneralManager.point_values

@export var fade_seconds := 0.2

@onready var tile_tooltip_header: 				RichTextLabel = %TileTooltipHeader
 
@onready var tile_type_icon: 					TextureRect = %TileTypeSprite
@onready var tile_letters_icon: 				TextureRect = %TileLettersSprite
@onready var notch_1_icon: 						TextureRect = %Notch1Sprite
@onready var notch_2_icon: 						TextureRect = %Notch2Sprite
@onready var notch_3_icon: 						TextureRect = %Notch3Sprite

@onready var tile_type_text: 					RichTextLabel = %TileTypeText
@onready var tile_score_text:					RichTextLabel = %TileScoreText
@onready var tile_letters_text: 				RichTextLabel = %TileLettersText
@onready var notch_1_text: 						RichTextLabel = %Notch1Text
@onready var notch_2_text: 						RichTextLabel = %Notch2Text
@onready var notch_3_text: 						RichTextLabel = %Notch3Text

var TruncatedDescriptions = {
"EMPTY":			"Empty",
"REPEATING":		"+1 Additional Trigger",
"ECHOING":			"+1 Re-rack on Play",
"VAPORIZING":		"Permanently Removed on Play",
"WEIGHTED":			"Skips Buffer on Play",
"INERT":			"Debuff Immunity",
"GILDED":			"+5 Gold at Combat End if Racked",
"PHANTOM":			"+2 Temporary Copies on Score",
"FLAMING":			"Apply 3 Burn on Score",
"REJUVENATING":		"+3 HP on First Play each Combat",
"REINFORCED":		"+5 Block on Score",
"EAGER":			"Priority Draw at Combat Start",
"PATIENT":			"+2 Points per turn Racked",
"QUICK":			"+5 Points on first turn Racked",
"OVERLOADED":		"-1 Energy, Double Current Word Score",
"BALANCED":			"+2 Points per outside Tile pair",
"LOCAL":			"+1 Point for each tile after this one",
"DISTANT":			"+1 Point for each tile before this one",
"PRICKLY":			"Letter Value Bleed when Scored",
"POTENT":			"+3 Points",
"LEXICAL":			"Bonus Letter"
							}

var tween: Tween
var is_visible := false
var is_active  := false
var current_score = 0

func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()

func _process(_delta):
	var screensize = get_viewport().get_visible_rect().size
	var current_size = self.size
	var tooltip_pos = get_global_mouse_position()
	if GeneralManager.is_combat_active:
		if tooltip_pos.y > 288 and tooltip_pos.x < 320:
			self.position.x = clamp(tooltip_pos.x + 8, 0, (248 - current_size.x - 8))
			self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))
			
		elif tooltip_pos.y > 288 and tooltip_pos.x > 320:
			self.position.x = clamp(tooltip_pos.x + 8, 400, (screensize.x - current_size.x - 16))
			self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))
				
		else:
			self.position.x = clamp(tooltip_pos.x + 8, 0, (screensize.x - current_size.x - 16))
			self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))
		
	else:
		self.position.x = clamp(tooltip_pos.x + 8, 0, (screensize.x - current_size.x - 16))
		self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))

func _show_tooltip(which: GridTile) -> void:
	is_visible = true
	is_active  = true
	if tween:
		tween.kill()

	tile_type_icon.texture.region = Rect2(20*which.tile.type, 0, 20, 20)
	tile_letters_icon.texture.region = Rect2(20*which.tile.visual_letter, 0, 20, 20)
	
	if not which.tile.notch1 == LetterTile.NotchTypes.EMPTY:
		notch_1_icon.texture.region = Rect2(((which.tile.notch1 - 1) * 20), 0, 20, 20)
	else:
		notch_1_icon.texture.region = Rect2(400, 0, 20, 20)
		
	if not which.tile.notch2 == LetterTile.NotchTypes.EMPTY:
		notch_2_icon.texture.region = Rect2(((which.tile.notch2 - 1) * 20), 0, 20, 20)
	else:
		notch_2_icon.texture.region = Rect2(400, 0, 20, 20)
		
	if not which.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		notch_3_icon.texture.region = Rect2(((which.tile.notch3 - 1) * 20), 0, 20, 20)
	else:
		notch_3_icon.texture.region = Rect2(400, 0, 20, 20)
	
	tile_tooltip_header.text = "Letter Tile"
	
	var current_letters_text = " "
	
	tile_type_text.text = str(which.tile.TileType.keys()[which.tile.type]).to_pascal_case()
	
	tile_score_text.text = "(Score: " + str(which.score_tile_quiet()) + ")"
	
	if not which.tile.bonus_letter1 == "" or not which.tile.bonus_letter2 == "" or not which.tile.bonus_letter3 == "":
		current_letters_text = str("Plus: ")
		if not which.tile.bonus_letter1 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter1) + '", '
		if not which.tile.bonus_letter2 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter2) + '", '
		if not which.tile.bonus_letter3 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter3) + '"'
	
	tile_letters_text.text = current_letters_text
	
	var notch_1_text_line = []
	var notch_2_text_line = []
	var notch_3_text_line = []
	
	var final_notch_1_text = ""
	var final_notch_2_text = ""
	var final_notch_3_text = ""
	
	notch_1_text_line.append(str(LetterTile.NotchTypes.keys()[which.tile.notch1]).to_pascal_case())
	if not which.tile.notch1 == LetterTile.NotchTypes.EMPTY:
		notch_1_text_line.append(":\n")
		notch_1_text_line.append(TruncatedDescriptions.get(LetterTile.NotchTypes.keys()[which.tile.notch1]))
		
	notch_2_text_line.append(str(LetterTile.NotchTypes.keys()[which.tile.notch2]).to_pascal_case())
	if not which.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		notch_2_text_line.append(":\n")
		notch_2_text_line.append(TruncatedDescriptions.get(LetterTile.NotchTypes.keys()[which.tile.notch2]))
		
	notch_3_text_line.append(str(LetterTile.NotchTypes.keys()[which.tile.notch3]).to_pascal_case())
	if not which.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		notch_3_text_line.append(":\n")
		notch_3_text_line.append(TruncatedDescriptions.get(LetterTile.NotchTypes.keys()[which.tile.notch3]))
	
	notch_1_text.set_text(final_notch_1_text.join(notch_1_text_line))
	notch_2_text.set_text(final_notch_2_text.join(notch_2_text_line))
	notch_3_text.set_text(final_notch_3_text.join(notch_3_text_line))

	size.y = get_minimum_size().y

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)

func _show_mini_tooltip(which: MiniGridTile) -> void:
	is_visible = true
	is_active  = true
	if tween:
		tween.kill()

	tile_type_icon.texture.region = Rect2(20*which.tile.type, 0, 20, 20)
	tile_letters_icon.texture.region = Rect2(20*which.tile.visual_letter, 0, 20, 20)
	
	if not which.tile.notch1 == LetterTile.NotchTypes.EMPTY:
		notch_1_icon.texture.region = Rect2(((which.tile.notch1 - 1) * 20), 0, 20, 20)
	else:
		notch_1_icon.texture.region = Rect2(400, 0, 20, 20)
		
	if not which.tile.notch2 == LetterTile.NotchTypes.EMPTY:
		notch_2_icon.texture.region = Rect2(((which.tile.notch2 - 1) * 20), 0, 20, 20)
	else:
		notch_2_icon.texture.region = Rect2(400, 0, 20, 20)
		
	if not which.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		notch_3_icon.texture.region = Rect2(((which.tile.notch3 - 1) * 20), 0, 20, 20)
	else:
		notch_3_icon.texture.region = Rect2(400, 0, 20, 20)
	
	tile_tooltip_header.text = "Letter Tile"
	
	var current_letters_text = " "
	
	tile_type_text.text = str(which.tile.TileType.keys()[which.tile.type]).to_pascal_case()
	
	tile_score_text.text = "(Score: " + str(which.score_tile_quiet()) + ")"
	
	if not which.tile.bonus_letter1 == "" or not which.tile.bonus_letter2 == "" or not which.tile.bonus_letter3 == "":
		current_letters_text = str("Plus: ")
		if not which.tile.bonus_letter1 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter1) + '", '
		if not which.tile.bonus_letter2 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter2) + '", '
		if not which.tile.bonus_letter3 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter3) + '"'
	
	tile_letters_text.text = current_letters_text
	
	var notch_1_text_line = []
	var notch_2_text_line = []
	var notch_3_text_line = []
	
	var final_notch_1_text = ""
	var final_notch_2_text = ""
	var final_notch_3_text = ""
	
	notch_1_text_line.append(str(LetterTile.NotchTypes.keys()[which.tile.notch1]).to_pascal_case())
	if not which.tile.notch1 == LetterTile.NotchTypes.EMPTY:
		notch_1_text_line.append(":\n")
		notch_1_text_line.append(TruncatedDescriptions.get(LetterTile.NotchTypes.keys()[which.tile.notch1]))
		
	notch_2_text_line.append(str(LetterTile.NotchTypes.keys()[which.tile.notch2]).to_pascal_case())
	if not which.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		notch_2_text_line.append(":\n")
		notch_2_text_line.append(TruncatedDescriptions.get(LetterTile.NotchTypes.keys()[which.tile.notch2]))
		
	notch_3_text_line.append(str(LetterTile.NotchTypes.keys()[which.tile.notch3]).to_pascal_case())
	if not which.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		notch_3_text_line.append(":\n")
		notch_3_text_line.append(TruncatedDescriptions.get(LetterTile.NotchTypes.keys()[which.tile.notch3]))
	
	notch_1_text.set_text(final_notch_1_text.join(notch_1_text_line))
	notch_2_text.set_text(final_notch_2_text.join(notch_2_text_line))
	notch_3_text.set_text(final_notch_3_text.join(notch_3_text_line))
	
	size.y = get_minimum_size().y

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)

func _hide_tooltip() -> void:
	is_visible = false
	if tween:
		tween.kill()
		
	get_tree().create_timer(fade_seconds, false).timeout.connect(hide_animation)
	
func hide_animation() -> void:
	if not is_visible:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
		tween.tween_callback(hide)
		is_active = false
	else:
		pass
