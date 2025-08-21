extends PanelContainer
class_name StickyTileTooltip

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

var tween: Tween
var is_visible := false
var current_score = 0

func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()
	
func _show_tooltip(which: GridTile) -> void:
	is_visible = true
	if tween:
		tween.kill()

	tile_type_icon.texture.region = Rect2(20*which.tile.type, 0, 20, 20)
	tile_letters_icon.texture.region = Rect2(20*which.tile.visual_letter, 0, 20, 20)
	notch_1_icon.texture.region = Rect2(120, 0, 20, 20)
	notch_2_icon.texture.region = Rect2(140, 0, 20, 20)
	notch_3_icon.texture.region = Rect2(160, 0, 20, 20)
	
	tile_tooltip_header.text = "Letter Tile"
	
	var current_letters_text = " "
	
	tile_type_text.text = str(which.tile.TileType.keys()[which.tile.type]).to_pascal_case()
	
	if which.tile.type == LetterTile.TileType.BASIC or which.tile.type == LetterTile.TileType.LOCKED \
	or which.tile.type == LetterTile.TileType.BURNING or which.tile.type == LetterTile.TileType.CRUMBLING:
		current_score = point_values[which.tile.visual_letter]
	
	elif which.tile.type == LetterTile.TileType.STONED:
		current_score = 0
		
	elif which.tile.type == LetterTile.TileType.PLAGUED:
		current_score = point_values[which.tile.visual_letter] - 1
		if current_score == 0:
			current_score += 1
	
	tile_score_text.text = "(Score: " + str(current_score) + ")"
	
	if not (which.tile.bonus_letter1 == "" or which.tile.bonus_letter2 == "" or which.tile.bonus_letter3 == ""):
		current_letters_text = str("Plus: ")
		if not which.tile.bonus_letter1 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter1) + '", '
		if not which.tile.bonus_letter2 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter2) + '", '
		if not which.tile.bonus_letter3 == "":
			current_letters_text = current_letters_text + '"' + str(which.tile.bonus_letter3) + '"'
	
	tile_letters_text.text = current_letters_text

	notch_1_text.text = str(which.tile.NotchTypes.keys()[which.tile.notch1]).to_pascal_case()
	notch_2_text.text = str(which.tile.NotchTypes.keys()[which.tile.notch2]).to_pascal_case()
	notch_3_text.text = str(which.tile.NotchTypes.keys()[which.tile.notch3]).to_pascal_case()

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)

func _show_mini_tooltip(which: MiniGridTile) -> void:
	is_visible = true
	if tween:
		tween.kill()

	tile_type_icon.texture.region = Rect2(20*which.tile.type, 0, 20, 20)
	tile_letters_icon.texture.region = Rect2(20*which.tile.visual_letter, 0, 20, 20)
	notch_1_icon.texture.region = Rect2(120, 0, 20, 20)
	notch_2_icon.texture.region = Rect2(140, 0, 20, 20)
	notch_3_icon.texture.region = Rect2(160, 0, 20, 20)
	
	tile_tooltip_header.text = "Letter Tile"
	
	tile_type_text.text = str("Type: " + str(which.tile.TileType.keys()[which.tile.type]).to_pascal_case())

	var current_letters_text = str('Letter: "' + str(which.tile.TileLetter.keys()[which.tile.visual_letter]).to_pascal_case()) + '"'
	if not which.tile.bonus_letter1 == "":
		current_letters_text = current_letters_text + ", " + '"' + str(which.tile.bonus_letter1) + '"'
	if not which.tile.bonus_letter2 == "":
		current_letters_text = current_letters_text + ", " + '"' + str(which.tile.bonus_letter2) + '"'
	if not which.tile.bonus_letter3 == "":
		current_letters_text = current_letters_text + ", " + '"' + str(which.tile.bonus_letter3) + '"'
	
	tile_letters_text.text = current_letters_text
	


	notch_1_text.text = str("Notch 1: " + str(which.tile.NotchTypes.keys()[which.tile.notch1]).to_pascal_case())
	notch_2_text.text = str("Notch 2: " + str(which.tile.NotchTypes.keys()[which.tile.notch2]).to_pascal_case())
	notch_3_text.text = str("Notch 3: " + str(which.tile.NotchTypes.keys()[which.tile.notch3]).to_pascal_case())

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)

func _hide_tooltip() -> void:
	is_visible = false
	if tween:
		tween.kill()
		
	#get_tree().create_timer(fade_seconds, false).timeout.connect(hide_animation)
	
func hide_animation() -> void:
	if not is_visible:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
		tween.tween_callback(hide)
	else:
		pass
