extends Button
class_name RewardsRelicButton

@onready var assoc_relic: Relic

signal rewards_relic_button_pressed(which: RewardsRelicButton)

func update_button_data():
	print(assoc_relic.relic_id)
	print(assoc_relic.relic_name)
	self.icon.region = Rect2((assoc_relic.relic_id % 10) * 32, floor(assoc_relic.relic_id / 10) * 32, 32, 32)
	self.text = assoc_relic.relic_name

func _on_pressed() -> void:
	GameEventHandler.add_relic.emit(assoc_relic.relic_id)
	rewards_relic_button_pressed.emit(self)
	

func _on_mouse_entered() -> void:
	GameEventHandler.relic_hovered.emit(assoc_relic, true)

func _on_mouse_exited() -> void:
	GameEventHandler.relic_hovered.emit(assoc_relic, false)
