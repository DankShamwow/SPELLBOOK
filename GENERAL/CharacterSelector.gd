extends Control

const CHARACTER_DATA := preload("res://COMBAT/CHARACTERS/TestCharacter.tscn")

## current_character is the player's character; this should NEVER be unloaded once instantiated.
var current_character = GeneralManager.current_character

func _ready() -> void:
	set_current_character(CHARACTER_DATA)

func set_current_character(new_character: PackedScene) -> void:
	current_character = new_character
	%CharacterName.text = current_character.entity_name
	%CharacterDescription.text = current_character.entity_description


func _on_start_button_pressed() -> void:
	pass # Replace with function body.


func _on_book_keeper_pressed() -> void:
	pass # Replace with function body.


func _on_scriptwriter_pressed() -> void:
	pass # Replace with function body.


func _on_archivist_pressed() -> void:
	pass # Replace with function body.


func _on_translator_pressed() -> void:
	pass # Replace with function body.


func _on_inquisitor_pressed() -> void:
	pass # Replace with function body.


func _on_simian_typewriter_pressed() -> void:
	pass # Replace with function body.
