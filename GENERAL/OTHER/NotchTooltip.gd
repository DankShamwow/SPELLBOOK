extends PanelContainer
class_name NotchTooltip

@export var fade_seconds := 0.2

@onready var notch_tooltip_header: 				RichTextLabel = %NotchTooltipHeader
 
@onready var notch_type_icon: 					TextureRect = %NotchTypeSprite

@onready var notch_type_text: 					RichTextLabel = %NotchTypeText

@onready var notch_type_description:			RichTextLabel = %NotchTypeDescription

var tween: Tween
var is_visible := false

func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()
	
func _show_tooltip(which: NotchObject) -> void:
	is_visible = true
	if tween:
		tween.kill()

	notch_type_icon.texture.region = Rect2(20*which.notch_type, 0, 20, 20)
	print(20*which.notch_type)
	
	notch_tooltip_header.text = "Notch"
	
	notch_type_text.text = str(which.NotchTypes.keys()[which.notch_type]).to_pascal_case()
	
	notch_type_description.text = which.NotchDescriptions.get(which.NotchTypes.keys()[which.notch_type])
	
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
	
