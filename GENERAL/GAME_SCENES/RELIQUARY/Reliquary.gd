extends Control
class_name Reliquary

var depleted: bool = false

func _ready():
	GameEventHandler.reward_depleted.connect(self.is_reward_depleted)
	%CombatRewards._ready_rewards(25, 3, 1)

func _on_reliquary_chest_toggled(toggled_on: bool) -> void:
	if not depleted:
		%CombatRewards._show_rewards(toggled_on)

func is_reward_depleted():
	if not depleted:
		depleted = true
		%ReliquaryChest.disabled = true
		%ReliquaryChest.set_pressed_no_signal(true)
		%SkipButton.text = str("PROCEED")
		

func _on_skip_button_pressed() -> void:
	GameEventHandler.reliquary_exited.emit()
