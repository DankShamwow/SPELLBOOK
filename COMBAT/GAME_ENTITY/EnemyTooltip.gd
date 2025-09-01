extends PanelContainer
class_name EnemyTooltip

@export var fade_seconds := 0.2

var tween: Tween
var is_visible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color.TRANSPARENT
	
	var health_text = []
	var full_health_text = ""
		
	var strength_text = []
	var full_strength_text = ""
	
	var defense_text = []
	var full_defense_text = ""
	
	
	var intelligence_text = []
	var full_intelligence_text = ""
	
	%EnemyName.set_text("")
	%HealthText.set_text(full_health_text.join(health_text))
	%StrengthText.set_text(full_strength_text.join(strength_text))
	%DefenseText.set_text(full_defense_text.join(defense_text))
	%IntelligenceText.set_text(full_intelligence_text.join(intelligence_text))
	
	self.size.y = get_minimum_size().y
	
	hide()

func _process(_delta):
	var screensize = get_viewport().get_visible_rect().size
	var current_size = self.size
	var tooltip_pos = get_global_mouse_position()
	self.position.x = clamp(tooltip_pos.x + 8, 0, (screensize.x - current_size.x - 16))
	self.position.y = clamp(tooltip_pos.y + 48, 0, (screensize.y - current_size.y - 16))

func _on_enemy_hovered(which: GameEntity, is_hovering: bool) -> void:
	if is_hovering:
		is_visible = true
		if tween:
			tween.kill()
		
		var attack_bonus = which.query_status_value(12)
		var defend_bonus = which.query_status_value(13)
		var intelligence_bonus = which.query_status_value(14)
		
		%EnemyName.set_text(which.entity_name)
		
		var health_text = []
		var full_health_text = ""
		
		health_text.append("Health: \n")
		health_text.append(str(str(which.health) + " / " + str(which.max_health)))
		
		if which.block > 0:
			health_text.append(str("\n" + str(which.block) + " Block"))
		
		%HealthText.set_text(full_health_text.join(health_text))
		
		var strength_text = []
		var full_strength_text = ""
		
		strength_text.append("Score Bonus: \n")
		strength_text.append(str(str(which.point_bonus) + " bonus points"))
		
		if attack_bonus > 0:
			strength_text.append("\n[color = red](+ " + str(attack_bonus) + ") on attack[/color]")
		if defend_bonus > 0:
			strength_text.append("\n[color = blue](+ "+ str(defend_bonus) + ") on defend[/color]")
		
		%StrengthText.set_text(full_strength_text.join(strength_text))
		
		var defense_text = []
		var full_defense_text = ""
		
		defense_text.append("Damage Reduction: \n")
		defense_text.append(str(str(which.defense) + " damage reduction"))
		
		%DefenseText.set_text(full_defense_text.join(defense_text))
		
		var intelligence_text = []
		var full_intelligence_text = ""
		
		intelligence_text.append("Length Bonus: \n")
		intelligence_text.append(str(str(which.length_bonus) + " extra tiles"))
		
		if intelligence_bonus > 0:
			intelligence_text.append("\n[color = yellow](+ " + str(intelligence_bonus) + ") from buffs[/color]")

		%IntelligenceText.set_text(full_intelligence_text.join(intelligence_text))

		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(show)
		tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)
		
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
