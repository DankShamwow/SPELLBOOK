extends Control

func _on_button_pressed() -> void:
	GameEventHandler.shop_exited.emit()
