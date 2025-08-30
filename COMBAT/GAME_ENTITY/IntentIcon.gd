extends Control
class_name IntentIcon

enum IntentType {ATTACK, DEFEND, BUFF, DEBUFF, ATTACK_BUFF, ATTACK_DEBUFF, DEFEND_BUFF, DEFEND_DEBUFF, OTHER}

signal intent_hovered(which: IntentIcon, is_hovering: bool)

var type: IntentType

var IntentDescriptions = {
	"ATTACK": 			"This Enemy intends to Attack with this word.",
	"DEFEND": 			"This Enemy intends to Defend with this word.",
	"BUFF":				"This Enemy intends to give themself a positive Status Effect with this word.",
	"DEBUFF":			"This Enemy intends to give you a negative Status Effect with this word.",
	"ATTACK_BUFF":		"This Enemy intends to Attack and give themself a positive Status Effect with this word.",
	"ATTACK_DEBUFF":	"This Enemy intends to Attack and give you a negative Status Effect with this word.",
	"DEFEND_BUFF":		"This Enemy intends to Defend and give themself a positive Status Effect with this word.",
	"DEFEND_DEBUFF":	"This Enemy intends to Defend and give you a negative Status Effect with this word.",
	"OTHER":			"This Enemy intends to do something strange with this word."
}

func _ready():
	%Icon.set_frame_coords(Vector2i(type, 0))
	
func update_intent_info():
	%Icon.set_frame_coords(Vector2i(type, 0))

func juice_attack_perform():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(%Icon, "scale", Vector2(1.25, 1.25), 0.5)
	tween2.tween_property(%Icon, "modulate:a", 0.0, 0.65)

	await get_tree().create_timer(0.67).timeout
	return

func _on_intent_icon_mouse_entered():
	intent_hovered.emit(self, true)
	
func _on_intent_icon_mouse_exited():
	intent_hovered.emit(self, false)
