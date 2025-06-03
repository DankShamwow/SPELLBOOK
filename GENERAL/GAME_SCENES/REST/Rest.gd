extends Control

func _on_button_pressed() -> void:
	GameEventHandler.rest_exited.emit()
