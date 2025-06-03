extends Control

@onready var continue_button: Button = %ContinueRun

const CHARACTER_SELECT_SCENE := preload("res://GENERAL/GAME_SCENES/MAIN_MENU/CharacterSelect.tscn")

func _ready() -> void:
	get_tree().paused = false

func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_packed(CHARACTER_SELECT_SCENE)
	
func _on_continue_run_pressed() -> void:
	print("Not implemented yet, sorry!")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
