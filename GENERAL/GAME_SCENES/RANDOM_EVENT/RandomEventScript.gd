extends Control

func _on_button_pressed() -> void:
	GameEventHandler.random_event_exited.emit()
