extends TextureRect
class_name RelicContainer

@export var relic_control = Control 

## current_relics is the list of Relics that the player currently has.
var current_relics = GeneralManager.current_relics

## currently_borrowed_relics is the list of relics that the player is currently borrowing.
var currently_borrowed_relics = GeneralManager.currently_borrowed_relics

## currently_owned_books is the list of books that the player owns.
var currently_owned_books = GeneralManager.currently_owned_books

const RELIC_SCENE := preload("res://RELIC/Relic.tscn")

func _ready() -> void:
	GameEventHandler.add_relic.connect(self.add_relic)
	GameEventHandler.exchange_relic.connect(self.exchange_relic)
	GameEventHandler.update_relic_states.connect(self.update_relic_states)

func add_relics(relics_array: Array[Relic]) -> void:
	for relic: Relic in relics_array:
		add_relic(relic.relic_id)
		
func add_relic(relic_id: int, is_borrowed: bool = false, purchase_price: int = 0) -> void:
	var found_relic = RelicManager.relic_ids.find_key(relic_id)
	var granted_relic = RelicManager.relic_list.get(found_relic)
	
	var relic_node = RELIC_SCENE.instantiate() as Relic
	
	if RelicManager.loaded_relics.get(relic_id):
		relic_node.set_script(RelicManager.loaded_relics.get(relic_id))
	
	else:
		granted_relic = load(granted_relic)
		relic_node.set_script(granted_relic)
	
	print("Adding relic " + str(relic_id) + ".")
	%RelicCollection.add_child(relic_node)
	
	relic_node.on_pickup_effect()
	
	relic_node.player_relic_index = current_relics.size()
	relic_node.borrowed = is_borrowed
	relic_node.purchase_price = purchase_price
	
	current_relics.append(relic_node)
	
	if is_borrowed:
		print("Relic has been borrowed!")
		relic_node.just_borrowed = true
		currently_borrowed_relics.append(relic_node)
		GeneralManager.borrowed_relics_count += 1
		print(str(GeneralManager.borrowed_relics_count))
	
	print("Relic Type: " + str(relic_node.RelicType.keys()[relic_node.relic_type]))
	
	if relic_node.relic_type == Relic.RelicType.BOOK:
		relic_node.owned_book_index = currently_owned_books.size()
		currently_owned_books.append(relic_node)
	
	print(currently_owned_books)

func exchange_relic(relic_id: int, relic_index: int, is_borrowed: bool, purchase_price: int) -> void:
	
	print("Relic exchange received...")
	
	# List of books prior to the exchange
	print(currently_owned_books)
	
	currently_owned_books.clear()
	for i in %RelicCollection.get_child_count():
		# Shorthand it to something more readable.
		var relic_node = %RelicCollection.get_child(i)
		
		# Exchanging for itself typically means just toggling a state.
		if relic_node.relic_id == relic_id and relic_node.player_relic_index == relic_index:
			print("Exact Match Found!")
			relic_node.borrowed = false
			relic_node.purchase_price = purchase_price
			if currently_borrowed_relics.has(relic_node):
				print(currently_borrowed_relics)
				currently_borrowed_relics.erase(relic_node)
				print(str(GeneralManager.borrowed_relics_count))
				GeneralManager.borrowed_relics_count -= 1
				print(str(GeneralManager.borrowed_relics_count))
				print(currently_borrowed_relics)
			
			break
		
		# Do this stuff if it's match.
		elif relic_node.player_relic_index == relic_index:
			print("Relic match found!")
			
			# If the relic is already loaded, which it should be, use this.
			if RelicManager.loaded_relics.get(relic_id):
				print("Swapping player relic " + str(relic_index) + " to relic ID: " + str(relic_id) + " from relic ID: " + str(relic_node.relic_id))
				relic_node.set_script(RelicManager.loaded_relics.get(relic_id))
				relic_node.juice_relic_to_new_sprite()
				relic_node.player_relic_index = relic_index
				
			# Otherwise, load it into memory and set the script of the relic to it.
			else:
				var found_relic = RelicManager.relic_ids.find_key(relic_id)
				var granted_relic = RelicManager.relic_list.get(found_relic)
				granted_relic = load(granted_relic)
				
				print("Swapping player relic " + str(relic_index) + " to relic ID: " + str(relic_id) + " from relic ID: " + str(relic_node.relic_id))
				relic_node.set_script(granted_relic)
				relic_node.juice_relic_to_new_sprite()
				relic_node.player_relic_index = relic_index
			
			# Adjust the current relics array
			current_relics.set(relic_index, relic_node)
			
			# Do on-pickup effects. This is a dangerous thing to allow, I think.
			relic_node.on_pickup_effect()
			
			relic_node.borrowed = is_borrowed
			relic_node.just_exchanged = true
			
			relic_node.purchase_price = purchase_price
			
			# Do all the borrow-y stuff if necessary.
			if relic_node.borrowed:
				print("Relic has been borrowed!")
				relic_node.just_borrowed = true
				currently_borrowed_relics.append(relic_node)
				GeneralManager.borrowed_relics_count += 1
				print(str(GeneralManager.borrowed_relics_count))
			
			# Output log stuff.
			print("Relic Type: " + str(relic_node.RelicType.keys()[relic_node.relic_type]))
			
			break
	
	for i in %RelicCollection.get_child_count():
		# Shorthand it to something more readable.
		var relic_node = %RelicCollection.get_child(i)
		
		# Regardless of whether or not it's a match, we need to update the book index.
		if relic_node.relic_type == Relic.RelicType.BOOK:
			relic_node.owned_book_index = currently_owned_books.size()
			currently_owned_books.append(relic_node)
	
	# Print the list of currently owned books for comparison with it prior to the exchange.
	print(currently_owned_books)
	
func update_relic_states() -> void:
	for i in %RelicCollection.get_child_count():
		var current_relic = %RelicCollection.get_child(i)
		current_relic.just_borrowed = false
		current_relic.just_exchanged = false
		

func remove_relic() -> void:
	pass
