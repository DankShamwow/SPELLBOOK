extends Control

## word_list starts as an empty dictionary but is populated at startup with the contents of a wordlist file.
var word_list = GeneralManager.word_list
var random_key = ""
var sorted_words = FileAccess
var balls = FileAccess
var computers = FileAccess
var contractions = FileAccess
var conveyance = FileAccess
var cooking = FileAccess
var death = FileAccess
var elements = FileAccess
var fish = FileAccess
var gemstones = FileAccess
var magic = FileAccess
var names = FileAccess
var new_categories = FileAccess
var not_words = FileAccess
var specificity = FileAccess
var sports = FileAccess
var swears = FileAccess

func _ready():
	
	GeneralManager.prepare_word_dict()
	
	sorted_words 	= FileAccess.open("res://WORDLISTS/Categories/Sorted Words.txt", FileAccess.READ_WRITE)
	sorted_words.seek_end()
	balls 			= FileAccess.open("res://WORDLISTS/Categories/Balls.txt", FileAccess.READ_WRITE)
	balls.seek_end()
	computers 		= FileAccess.open("res://WORDLISTS/Categories/Computers.txt", FileAccess.READ_WRITE)
	computers.seek_end()
	contractions 	= FileAccess.open("res://WORDLISTS/Categories/Contractions.txt", FileAccess.READ_WRITE)
	contractions.seek_end()
	conveyance 		= FileAccess.open("res://WORDLISTS/Categories/Conveyance.txt", FileAccess.READ_WRITE)
	conveyance.seek_end()
	cooking 		= FileAccess.open("res://WORDLISTS/Categories/Cooking.txt", FileAccess.READ_WRITE)
	cooking.seek_end()
	death 			= FileAccess.open("res://WORDLISTS/Categories/Death.txt", FileAccess.READ_WRITE)
	death.seek_end()
	elements 		= FileAccess.open("res://WORDLISTS/Categories/Elements.txt", FileAccess.READ_WRITE)
	elements.seek_end()
	fish 			= FileAccess.open("res://WORDLISTS/Categories/Fish.txt", FileAccess.READ_WRITE)
	fish.seek_end()
	gemstones 		= FileAccess.open("res://WORDLISTS/Categories/Gemstones.txt", FileAccess.READ_WRITE)
	gemstones.seek_end()
	magic 			= FileAccess.open("res://WORDLISTS/Categories/Magic.txt", FileAccess.READ_WRITE)
	magic.seek_end()
	names 			= FileAccess.open("res://WORDLISTS/Categories/Names.txt", FileAccess.READ_WRITE)
	names.seek_end()
	new_categories 	= FileAccess.open("res://WORDLISTS/Categories/New Categories.txt", FileAccess.READ_WRITE)
	new_categories.seek_end()
	not_words 		= FileAccess.open("res://WORDLISTS/Categories/Not Words.txt", FileAccess.READ_WRITE)
	not_words.seek_end()
	specificity 	= FileAccess.open("res://WORDLISTS/Categories/Specificity.txt", FileAccess.READ_WRITE)
	specificity.seek_end()
	sports 			= FileAccess.open("res://WORDLISTS/Categories/Sports.txt", FileAccess.READ_WRITE)
	sports.seek_end()
	swears 			= FileAccess.open("res://WORDLISTS/Categories/Swears.txt", FileAccess.READ_WRITE)
	swears.seek_end()
	
	pick_random_word()
	
func pick_random_word():
	
	random_key = word_list.keys().pick_random()
	
	while sorted_words.get_position() < sorted_words.get_length():
		if not sorted_words.get_line() == random_key:
			pick_random_word()
			return
		else:
			break
	
	%WordToSort.set_text(random_key)

func submit_word():
	print(random_key)
	if %GemButton.button_pressed:
		print("Writing...")
		gemstones.store_line(random_key)
		gemstones.seek_end()
		
		%GemButton.set_pressed(false)

	if %BallsButton.button_pressed:
		print("Writing...")
		balls.store_line(random_key)
		balls.seek_end()
		
		%BallsButton.set_pressed(false)
		
	if %FishButton.button_pressed:
		print("Writing...")
		fish.store_line(random_key)
		fish.seek_end()
		
		%FishButton.set_pressed(false)
		
	if %CookingButton.button_pressed:
		print("Writing...")
		cooking.store_line(random_key)
		cooking.seek_end()
		
		%CookingButton.set_pressed(false)
		
	if %AintButton.button_pressed:
		print("Writing...")
		contractions.store_line(random_key)
		contractions.seek_end()
		
		%AintButton.set_pressed(false)
		
	if %ComputerButton.button_pressed:
		print("Writing...")
		computers.store_line(random_key)
		computers.seek_end()
		
		%ComputerButton.set_pressed(false)
		
	if %MagicButton.button_pressed:
		print("Writing...")
		magic.store_line(random_key)
		magic.seek_end()
		
		%MagicButton.set_pressed(false)
		
	if %SpecificityButton.button_pressed:
		print("Writing...")
		specificity.store_line(random_key)
		specificity.seek_end()
		
		%SpecificityButton.set_pressed(false)
		
	if %DeathButton.button_pressed:
		print("Writing...")
		death.store_line(random_key)
		death.seek_end()
		
		%DeathButton.set_pressed(false)
		
	if %SportsButton.button_pressed:
		print("Writing...")
		sports.store_line(random_key)
		sports.seek_end()
		
		%SportsButton.set_pressed(false)
		
	if %ConveyButton.button_pressed:
		print("Writing...")
		conveyance.store_line(random_key)
		conveyance.seek_end()
		
		%ConveyButton.set_pressed(false)
		
	if %ElementButton.button_pressed:
		print("Writing...")
		elements.store_line(random_key)
		elements.seek_end()
		
		%ElementButton.set_pressed(false)
		
	if %SwearButton.button_pressed:
		print("Writing...")
		swears.store_line(random_key)
		swears.seek_end()
		
		%SwearButton.set_pressed(false)
		
	if %NameButton.button_pressed:
		print("Writing...")
		names.store_line(random_key)
		names.seek_end()
		
		%NameButton.set_pressed(false)
	
	if %NonwordButton.button_pressed:
		print("Writing...")
		not_words.store_line(random_key)
		not_words.seek_end()
		
		%NonwordButton.set_pressed(false)
	
	if not %NewCategory.get_text() == "":
		var new_category = str(random_key + "-- " + %NewCategory.get_text())
		new_categories.store_line(new_category)
		new_categories.seek_end()
		%NewCategory.clear()
	
	print("Writing...")
	sorted_words.store_line(random_key)
	sorted_words.seek_end()
	
	pick_random_word()
	
func custom_category(new_text: String):
	var new_category = str(random_key + "-- " + new_text)
	new_categories.store_line(new_category)
	new_categories.seek_end()
	
	%NewCategory.clear()
	
	submit_word()
