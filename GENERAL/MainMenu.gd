extends Control

@onready var continue_button: Button = %ContinueRun

func _ready() -> void:
	get_tree().paused = false


func _on_new_run_pressed() -> void:
	print("Not implemented yet, sorry!")

func _on_continue_run_pressed() -> void:
	print("Not implemented yet, sorry!")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
