extends Control

func _on_button_pressed() -> void:
	GameEventHandler.reliquary_exited.emit()
