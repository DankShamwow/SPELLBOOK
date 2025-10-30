extends Control

const RUN_SCENE = preload("res://GENERAL/RUN/Run.tscn")

const TEST_CHARACTER_DATA = preload("res://COMBAT/CHARACTERS/TestCharacterData.tres")
const BOOK_KEEPER_DATA = preload("res://COMBAT/CHARACTERS/BookKeeper.tres")
const SCRIPTWRITER_DATA = preload("res://COMBAT/CHARACTERS/Scriptwriter.tres")
const ARCHIVIST_DATA = preload("res://COMBAT/CHARACTERS/Archivist.tres")
const TRANSLATOR_DATA = preload("res://COMBAT/CHARACTERS/Translator.tres")
const INQUISITOR_DATA = preload("res://COMBAT/CHARACTERS/Inquisitor.tres")
const GORILLA_DATA = preload("res://COMBAT/CHARACTERS/SimianTypewriter.tres")

## current_character is the player's character; this should NEVER be unloaded once instantiated.
var current_character = GeneralManager.current_character

func _ready() -> void:
	set_current_character(TEST_CHARACTER_DATA)

func set_current_character(new_character: CharacterData) -> void:
	current_character = new_character
	%CharacterName.text = current_character.character_name
	%CharacterDescription.text = current_character.character_description
	%StartingMaxHealth.text = "Starting Max Health: \n" + str(current_character.starting_max_health)
	%StartingRelic.text = "Starting Relic: \n" + current_character.starting_relic
	%StartingGold.text = "Starting Gold: \n" + str(current_character.starting_gold)
	%StartingDeck.text = "Starting Deck: \n" + current_character.starting_deck
	%WordListType.text = "Word List Type: \n" + current_character.word_list_type

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)

func _on_book_keeper_pressed() -> void:
	set_current_character(BOOK_KEEPER_DATA)

func _on_scriptwriter_pressed() -> void:
	set_current_character(SCRIPTWRITER_DATA)

func _on_archivist_pressed() -> void:
	set_current_character(ARCHIVIST_DATA)

func _on_translator_pressed() -> void:
	set_current_character(TRANSLATOR_DATA)

func _on_inquisitor_pressed() -> void:
	set_current_character(INQUISITOR_DATA)

func _on_simian_typewriter_pressed() -> void:
	set_current_character(GORILLA_DATA)
