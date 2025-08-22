extends PanelContainer
class_name StatusEffectTooltip

@export var fade_seconds := 0.2

@onready var status_tooltip_header:				RichTextLabel = %StatusName
@onready var status_tooltip_icon:				TextureRect = %StatusIcon
@onready var status_tooltip_description:		RichTextLabel = %StatusDescription

var tween: Tween
var is_visible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color.TRANSPARENT
	hide()

func _on_status_hovered(which: StatusEffect, is_hovering: bool) -> void:
	
	if is_hovering:
		is_visible = true
		if tween:
			tween.kill()
			
		status_tooltip_icon.texture.region = Rect2((which.id % 10) * 24, (floor(which.id/10)) * 24, 24.0, 24.0)
		status_tooltip_header.set_text(which.status_name)
		status_tooltip_description.set_text(which.status_description)

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
