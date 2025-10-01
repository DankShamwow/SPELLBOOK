extends PanelContainer
class_name NotchTooltip

@export var fade_seconds := 0.2

@onready var notch_tooltip_header: 				RichTextLabel = %NotchTooltipHeader
 
@onready var notch_type_icon: 					TextureRect = %NotchTypeSprite

@onready var notch_type_text: 					RichTextLabel = %NotchTypeText

@onready var notch_type_description:			RichTextLabel = %NotchTypeDescription

var tween: Tween
var is_visible := false

func _process(_delta):
	var screensize = get_viewport().get_visible_rect().size
	var current_size = self.size
	var tooltip_pos = get_global_mouse_position()
	self.position.x = clamp(tooltip_pos.x + 8, 0, (screensize.x - current_size.x - 16))
	self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))


func _ready() -> void:
	
	GameEventHandler.notch_tooltip_requested.connect(_show_tooltip)
	GameEventHandler.notch_tooltip_hide_requested.connect(_hide_tooltip)
	
	modulate = Color.TRANSPARENT
	hide()
	
func _show_tooltip(which: NotchObject) -> void:
	is_visible = true
	if tween:
		tween.kill()

	notch_type_icon.texture.region = Rect2(20*which.notch.type, 0, 20, 20)
	
	notch_tooltip_header.text = "Notch"
	
	notch_type_text.set_text(str(which.notch.NotchTypes.keys()[which.notch.type]).to_pascal_case())
	
	notch_type_description.text = which.NotchDescriptions.get(which.notch.NotchTypes.keys()[which.notch.type])
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)
	
	self.size.y = self.get_minimum_size().y

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
	
