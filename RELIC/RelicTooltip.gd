extends PanelContainer
class_name RelicTooltip

@export var fade_seconds := 0.2

var tween: Tween
var is_visible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GameEventHandler.relic_hovered.connect(self._on_relic_hovered)
	
	modulate = Color.TRANSPARENT
	
	%RelicName.set_text("")
	%RelicDescription.set_text("")
	%ActivationsText.set_text("")
	
	self.size.x = get_minimum_size().x
	self.size.y = get_minimum_size().y
	
	hide()

func _process(_delta):
	var screensize = get_viewport().get_visible_rect().size
	var current_size = self.size
	var tooltip_pos = get_global_mouse_position()
	self.position.x = clamp(tooltip_pos.x + 8, 0, (screensize.x - current_size.x - 16))
	self.position.y = clamp(tooltip_pos.y + 8, 0, (screensize.y - current_size.y - 16))

func _on_relic_hovered(which: Relic, is_hovering: bool) -> void:
	if is_hovering:
		is_visible = true
		if tween:
			tween.kill()
		
		%RelicIcon.texture.region = Rect2((which.relic_id % 10) * 32, (floor(which.relic_id/10)) * 32, 32, 32)
		%RelicName.set_text(which.relic_name)
		%RelicDescription.set_text(which.relic_description)
		%ActivationsText.set_text("")
		
		if not which.total_activations == 0:
			%ActivationsText.set_text(str("Activations: " + str(which.total_activations)))
		
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(show)
		tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)
		
		self.size.x = get_minimum_size().x
		self.size.y = get_minimum_size().y

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
