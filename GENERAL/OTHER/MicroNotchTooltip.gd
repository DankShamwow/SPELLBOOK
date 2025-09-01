extends PanelContainer
class_name MicroNotchTooltip

@export var fade_seconds := 0.2

@onready var notch_type_icon: 					TextureRect = %NotchTypeSprite

@onready var notch_type_text: 					RichTextLabel = %NotchTypeText

var TruncatedDescriptions = {
"REPEATING":		"+1 Additional Trigger",
"ECHOING":			"+1 Re-rack on Play",
"VAPORIZING":		"Permanently removed from Bag on Play",
"WEIGHTED":			"Skips Buffer on Play",
"INERT":			"Debuff Immunity",
"GILDED":			"+5 Gold at Combat End if Racked",
"PHANTOM":			"+2 Temporary Copies on Score",
"FLAMING":			"Apply 3 Burn on Score",
"REVJUVENATING":	"+3 HP on First Play each Combat",
"REINFORCED":		"+5 Block on Score",
"EAGER":			"Priority Draw at Combat Start",
"PATIENT":			"+2 Points per turn Racked",
"QUICK":			"+5 Points on first turn Racked",
"OVERLOADED":		"-1 Energy, Double Current Word Score",
"BALANCED":			"+2 Points per pair of tiles on each side",
"LOCAL":			"+1 Point for each tile after",
"DISTANT":			"+1 Point for each tile before",
"PRICKLY":			"Letter Score Bleed when Scored",
"POTENT":			"+3 Points",
"LEXICAL":			"Bonus Letter"
							}
var tween: Tween
var is_visible := false
var notch_slot: int = 0

func _process(_delta):
	var screensize = get_viewport().get_visible_rect().size
	var current_size = self.size
	var tooltip_pos = get_global_mouse_position()
	self.position.x = clamp(tooltip_pos.x + 132, 0, (screensize.x - current_size.x - 16))
	if notch_slot == 0:
		self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 104))
	if notch_slot == 1:
		self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 64))
	if notch_slot == 2:
		self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 24))

func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()
	
func _show_tooltip(type: Notch.NotchTypes, bonus_letter: String, slot: int):
	var text_line = []
	var final_text = ""
	
	notch_slot = slot
	is_visible = true
	
	if tween:
		tween.kill()
		
	notch_type_icon.texture.region = Rect2(20*type, 0, 20, 20)
	text_line.append(str(Notch.NotchTypes.keys()[type]).to_pascal_case())
	text_line.append(TruncatedDescriptions.get(Notch.NotchTypes.keys()[type]))
	notch_type_text.set_text(final_text.join(text_line))
	
	#notch_type_description.text = TruncatedDescriptions.get(Notch.NotchTypes.keys()[type])
	
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
	else:
		pass
