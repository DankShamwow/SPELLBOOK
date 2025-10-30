extends Control
class_name Library

@warning_ignore_start("integer_division")

var currently_borrowed_relics = GeneralManager.currently_borrowed_relics
var currently_owned_books = GeneralManager.currently_owned_books
var borrowed_relics_count = GeneralManager.borrowed_relics_count

var character_path = GeneralManager.character_path


var library_size = GeneralManager.library_size
var library_offerings: Array[Relic] = []

const FOLLOWER_TEXTBOX_SCENE: PackedScene = preload("res://GENERAL/OTHER/FollowerTextbox.tscn")

## Remaining number of actions in this Library.
var actions_left: int = 0

var allow_exchange_purchase: bool = false

func _ready():
	GameEventHandler.relic_clicked.connect(_on_relic_clicked)
	borrowed_relics_count = GeneralManager.borrowed_relics_count
	
	%BorrowButton.disabled = true
	%ExchangeButton.disabled = true
	%PurchaseButton.disabled = true
	
	actions_left = 3
	%ActionsRemaining.set_text("ACTIONS REMAINING: " + str(actions_left))
	
	library_size = 3
	
	for i in library_size:
		var new_book = RelicManager.grab_new_relic("Book")
		new_book.library_relic_index = library_offerings.size()
		library_offerings.append(new_book)
		new_book.purchase_price = EconomyManager.determine_purchase_price(new_book)
	
	print(library_offerings)
	
	## If the player is borrowing less books than their limit, allow them to borrow.
	if borrowed_relics_count < character_path.borrow_limit:
		%BorrowButton.disabled = false
	
	## There shouldn't be any way to enter a Library with a book that
	## has the "just borrowed" status.
	if not currently_owned_books.is_empty() or not library_offerings.is_empty():
		%ExchangeButton.disabled = false
	
	## Same as the above reason.
	if borrowed_relics_count > 0:
		%PurchaseButton.disabled = false

func construct_book_dummy(relic: Relic, _icon: String = "", _gold_value: int = 0):
	var cloned_relic = relic.duplicate()
	if not relic.player_relic_index == null:
		cloned_relic.player_relic_index = relic.player_relic_index
		
	if not relic.library_relic_index == null:
		cloned_relic.library_relic_index = relic.library_relic_index
		print(cloned_relic.library_relic_index)
	
	print("Cloned Relic Price: " + str(cloned_relic.purchase_price))
	print("Relic Price: " + str(relic.purchase_price))
	
	cloned_relic.purchase_price = relic.purchase_price
	
	print("Cloned Relic Price after Setting: " + str(cloned_relic.purchase_price))

	return cloned_relic
	
func _manage_covering(state: bool = false) -> void:
	var tween = %ScreenCovering.create_tween()
	
	if not state:
		tween.tween_property(%ScreenCovering, "modulate:a", (0.65 * int(state)), 0.15)
		tween.tween_property(%ScreenCovering, "visible", state, 0.001)
		%ScreenCovering.mouse_filter = MOUSE_FILTER_IGNORE
	
	if state:
		%ScreenCovering.mouse_filter = MOUSE_FILTER_STOP
		tween.tween_property(%ScreenCovering, "visible", state, 0.001)
		tween.tween_property(%ScreenCovering, "modulate:a", (0.65 * int(state)), 0.15)
		
func _on_relic_clicked(which: Relic, action: Relic.RelicAction):
	var total_cost = 0
	
	if action == Relic.RelicAction.FIDGET:
		
		#region Borrow Menu Section
		if %BorrowParent.visible and which.get_parent() == %BorrowBookParent:
			# If it isn't in the group to be borrowed, and you haven't hit your limit, and you have actions left, allow it to be borrowed.
			if not which.is_in_group("Relics to Borrow") \
			and get_tree().get_nodes_in_group("Relics to Borrow").size() < character_path.borrow_limit \
			and get_tree().get_nodes_in_group("Relics to Borrow").size() < actions_left:
				which.add_to_group("Relics to Borrow")
				print("Enlarging!")
				which.determine_relic_scale()
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Relics to Borrow").size()))
				
			elif which.is_in_group("Relics to Borrow"):
				which.remove_from_group("Relics to Borrow")
				print("Shrinking!")
				which.determine_relic_scale()
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Relics to Borrow").size()))
				
			else:
				which.grumble_relic()
		#endregion
		
		#region Exchange Menu Section
		if %ExchangeParent.visible:
			
			## Selection Logic Section
			
			if which.get_parent() == %ExchangePlayerBookParent \
			and not which.is_in_group("Owned Relics to Exchange") \
			and get_tree().get_nodes_in_group("Owned Relics to Exchange").size() < actions_left:
				# If it's in your section of the screen, and you're not trying to exchange more
				# than you have actions for, and it isn't already selected to be exchanged, set it up for that.
				which.add_to_group("Owned Relics to Exchange")
				print("Enlarging!")
				var tween = which.get_tree().create_tween()
				tween.tween_property(which, "scale", which.scale * 1.15, 0.05)
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Owned Relics to Exchange").size()) + "?")
				
			elif which.is_in_group("Owned Relics to Exchange"):
				which.remove_from_group("Owned Relics to Exchange")
				print("Shrinking!")
				var tween = which.get_tree().create_tween()
				tween.tween_property(which, "scale", Vector2(which.context_scaling, which.context_scaling), 0.1)
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Owned Relics to Exchange").size()) + "?")
				if get_tree().get_nodes_in_group("Owned Relics to Exchange").size() == 0:
					%ActionCost.set_text("ACTION COST: 0")
			
			elif which.get_parent() == %ExchangeLibraryBookParent \
			and not which.is_in_group("Library Relics to Exchange") \
			and get_tree().get_nodes_in_group("Library Relics to Exchange").size() < actions_left:
				which.add_to_group("Library Relics to Exchange")
				print("Enlarging!")
				which.determine_relic_scale()
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Library Relics to Exchange").size()) + "?")
				
			elif which.is_in_group("Library Relics to Exchange"):
				which.remove_from_group("Library Relics to Exchange")
				print("Shrinking!")
				which.determine_relic_scale()
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Library Relics to Exchange").size()) + "?")
				if get_tree().get_nodes_in_group("Library Relics to Exchange").size() == 0:
					%ActionCost.set_text("ACTION COST: 0")
			
			else:
				which.grumble_relic()
				
			## Allow Exchange Section
			
			if get_tree().get_nodes_in_group("Owned Relics to Exchange").size() \
			== get_tree().get_nodes_in_group("Library Relics to Exchange").size() \
			and get_tree().get_nodes_in_group("Owned Relics to Exchange").size() < actions_left \
			and get_tree().get_nodes_in_group("Owned Relics to Exchange").size() > 0:
				%ExchangeConfirmButton.disabled = false
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Owned Relics to Exchange").size()))
				
			else:
				%ExchangeConfirmButton.disabled = true
			
		#endregion
		
		#region Purchase Menu Section
		for i in get_tree().get_nodes_in_group("Relics to Purchase").size():
			total_cost += get_tree().get_nodes_in_group("Relics to Purchase")[i].purchase_price
		
		if %PurchaseParent.visible and which.get_parent() == %PurchaseBookParent:
			if not which.is_in_group("Relics to Purchase") \
			and get_tree().get_nodes_in_group("Relics to Purchase").size() < actions_left \
			and (total_cost + which.purchase_price) <= GeneralManager.gold:
				which.add_to_group("Relics to Purchase")
				print("Enlarging!")
				which.determine_relic_scale()
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Relics to Purchase").size()))
				%GoldLabel.text = str(total_cost + which.purchase_price)
	
				if total_cost + which.purchase_price < 50:
					%GoldIcon.texture.region = Rect2(0, 0, 32, 32)
					
				elif total_cost + which.purchase_price >= 50 and total_cost + which.purchase_price < 100:
					%GoldIcon.texture.region = Rect2(32, 0, 32, 32)
					
				elif total_cost + which.purchase_price >= 100 and total_cost + which.purchase_price < 250:
					%GoldIcon.texture.region = Rect2(64, 0, 32, 32)
					
				else:
					%GoldIcon.texture.region = Rect2(96, 0, 32, 32)
					
				%PurchaseConfirmButton.disabled = false
			
			elif which.is_in_group("Relics to Purchase"):
				which.remove_from_group("Relics to Purchase")
				print("Shrinking!")
				which.determine_relic_scale()
				%ActionCost.set_text("ACTION COST: " + str(get_tree().get_nodes_in_group("Relics to Purchase").size()))
				%GoldLabel.text = str(total_cost - which.purchase_price)
	
				if total_cost - which.purchase_price < 50:
					%GoldIcon.texture.region = Rect2(0, 0, 32, 32)
					
				elif total_cost - which.purchase_price >= 50 and total_cost - which.purchase_price < 100:
					%GoldIcon.texture.region = Rect2(32, 0, 32, 32)
					
				elif total_cost - which.purchase_price >= 100 and total_cost - which.purchase_price < 250:
					%GoldIcon.texture.region = Rect2(64, 0, 32, 32)
					
				else:
					%GoldIcon.texture.region = Rect2(96, 0, 32, 32)
					
				if get_tree().get_nodes_in_group("Relics to Purchase").size() == 0:
					%PurchaseConfirmButton.disabled = true
					
			else:
				which.grumble_relic()
			
		#endregion

## on_action_completed is called inside Libraries every time a Library Action is finished.
func on_action_completed():
	actions_left -= 1
	borrowed_relics_count = GeneralManager.borrowed_relics_count
	
	%ActionsRemaining.set_text("ACTIONS REMAINING: " + str(actions_left))
	%ActionCost.set_text("ACTION COST: 0")
	
	var library_just_exchanged_count = 0
	var player_just_exchanged_count = 0
	
	if actions_left == 0:
		%BorrowButton.disabled = true 
		%ExchangeButton.disabled = true
		%PurchaseButton.disabled = true
		return
	
	for i in library_offerings.size():
		library_offerings[i].library_relic_index = i
		library_offerings[i].player_relic_index = -100000
		if library_offerings[i].just_exchanged:
			library_just_exchanged_count += 1
	
	if borrowed_relics_count >= character_path.borrow_limit:
		%BorrowButton.disabled = true
	else:
		%BorrowButton.disabled = false
		
	for i in currently_borrowed_relics.size():
		if not currently_borrowed_relics[i].just_borrowed:
			%PurchaseButton.disabled = false
			break
	
	for i in currently_owned_books.size():
		if not currently_owned_books[i].just_borrowed:
			if not currently_owned_books[i].just_exchanged:
				%ExchangeButton.disabled = false
				break
		if currently_owned_books[i].just_exchanged:
			player_just_exchanged_count += 1
	
	if currently_owned_books.is_empty() or library_offerings.is_empty() \
	or library_just_exchanged_count == library_offerings.size() \
	or player_just_exchanged_count == currently_owned_books.size():
		%ExchangeButton.disabled = true

func _on_leave_button_pressed() -> void:
	for i in library_offerings.size():
		RelicManager.return_relic_to_pool(library_offerings[i].relic_id)
	
	GameEventHandler.update_relic_states.emit()
	#GameEventHandler.library_exited.emit()

#region Browse Mechanics

func _on_browse_button_pressed() -> void:
	_manage_covering(true)
	
	var tween = %BrowseParent.create_tween()
	tween.tween_property(%BrowseParent, "visible", true, 0.001)
	tween.tween_property(%BrowseParent, "modulate:a", 1, 0.15)
	
	for i in library_offerings.size():
		var browse_relic = construct_book_dummy(library_offerings[i], "", 0)
		%BrowseBookParent.add_child(browse_relic)
		browse_relic.determine_relic_scale()
	
	for i in %BrowseBookParent.get_child_count():
		
		## Customize by tweaking these values
		var total_count = %BrowseBookParent.get_child_count() 
		var iterator_book = %BrowseBookParent.get_child(i)
		var columns = 5
		var x_position = 80 + (112 * (i % columns))
		var y_position = 224 + (72 * (floor(i / columns))) - (18 * floor(total_count / columns) )
		
		## And this code should adjust accordingly.
		iterator_book.position = Vector2(x_position, y_position)
			
		if floor(i / columns) == floor(total_count / columns):
			iterator_book.position.x = 288.0 + (112 * int(i % columns)) - (72 * ((total_count-1) % columns)) + (16 * (total_count % columns))
			
		#print("Book 1: " + str(initial_book.position))
		#print("Book " + str(i+1) + ": " + str(iterator_book.position))

func _on_browse_back_button_pressed() -> void:
	_manage_covering(false)
	
	var tween = %BrowseParent.create_tween()
	tween.tween_property(%BrowseParent, "modulate:a", 0, 0.15)
	tween.tween_property(%BrowseParent, "visible", false, 0.001)
	
	await get_tree().create_timer(0.15).timeout
	
	for i in %BrowseBookParent.get_child_count():
		%BrowseBookParent.get_child(i).queue_free()

#endregion

#region Borrow Mechanics

func _on_borrow_button_mouse_entered() -> void:
	%BorrowButton.tooltip_text = 	"You may borrow Books up to your limit.
									You have borrowed " + str(borrowed_relics_count) + "/" + str(character_path.borrow_limit) + " Books."

func _on_borrow_button_pressed() -> void:
	_manage_covering(true)
	
	var tween = %BorrowParent.create_tween()
	tween.tween_property(%BorrowParent, "visible", true, 0.001)
	tween.tween_property(%BorrowParent, "modulate:a", 1, 0.15)
	
	for i in library_offerings.size():
		var borrow_relic = construct_book_dummy(library_offerings[i], "", 0)
		%BorrowBookParent.add_child(borrow_relic)
		borrow_relic.determine_relic_scale()
	
	for i in %BorrowBookParent.get_child_count():
		## Customize by tweaking these values
		var total_count = %BorrowBookParent.get_child_count() 
		var iterator_book = %BorrowBookParent.get_child(i)
		var columns = 5
		var x_position = 80 + (112 * (i % columns))
		var y_position = 224 + (72 * (floor(i / columns))) - (18 * floor(total_count / columns) )
		
		## And this code should adjust accordingly.
		iterator_book.position = Vector2(x_position, y_position)
		
		if floor(i / columns) == floor(total_count / columns):
			iterator_book.position.x = 288.0 + (112 * int(i % columns)) - (72 * ((total_count-1) % columns)) + (16 * (total_count % columns))
			
		#print("Book 1: " + str(initial_book.position))
		#print("Book " + str(i+1) + ": " + str(iterator_book.position))
	
func _on_borrow_back_button_pressed() -> void:
	_manage_covering(false)
	
	var tween = %BorrowParent.create_tween()
	tween.tween_property(%BorrowParent, "modulate:a", 0, 0.15)
	tween.tween_property(%BorrowParent, "visible", false, 0.001)
	
	await get_tree().create_timer(0.15).timeout
	
	for i in %BorrowBookParent.get_child_count():
		%BorrowBookParent.get_child(i).remove_from_group("Relics to Borrow")
		%BorrowBookParent.get_child(i).queue_free()

func _on_borrow_confirm_button_pressed() -> void:
	for i in get_tree().get_nodes_in_group("Relics to Borrow").size():
		var borrowed_relic = get_tree().get_nodes_in_group("Relics to Borrow")[i]
		for j in library_offerings.size():
			if borrowed_relic.relic_id == library_offerings[j].relic_id and actions_left > 0:
				library_offerings.remove_at(j)
				GameEventHandler.add_relic.emit(borrowed_relic.relic_id, true, borrowed_relic.purchase_price)
				on_action_completed()
				break
	
	await get_tree().create_timer(0.10).timeout
	_on_borrow_back_button_pressed()

#endregion

#region Exchange Mechanics

func _on_exchange_button_pressed() -> void:
	_manage_covering(true)
	%ExchangeConfirmButton.disabled = true
	
	var tween = %ExchangeParent.create_tween()
	tween.tween_property(%ExchangeParent, "visible", true, 0.001)
	tween.tween_property(%ExchangeParent, "modulate:a", 1, 0.15)

	for i in library_offerings.size():
		if not library_offerings[i].just_exchanged:
			var exchange_library_relic = construct_book_dummy(library_offerings[i], "", 0)
			%ExchangeLibraryBookParent.add_child(exchange_library_relic)
	
	for i in %ExchangeLibraryBookParent.get_child_count():
		
		## Customize by tweaking these values
		var total_count = %ExchangeLibraryBookParent.get_child_count() 
		var iterator_book = %ExchangeLibraryBookParent.get_child(i)
		var initial_book = %ExchangeLibraryBookParent.get_child(0)
		var columns = 5
		var x_position = 368 + (48 * (i % columns))
		var y_position = 224 + (48 * (floor(i / columns))) - (16 * floor((total_count-1) / columns))
		
		## And this code should adjust accordingly.
		iterator_book.position = Vector2(x_position, y_position)
			
		if floor(i / columns) == floor(total_count / columns):
			iterator_book.position.x = 448.0 + (48 * int(i % columns)) - (40 * ((total_count-1) % columns)) + (16 * (total_count % columns))
			
		print("Book 1: " + str(initial_book.position))
		print("Book " + str(i+1) + ": " + str(iterator_book.position))
		
	for i in currently_owned_books.size():
		if not currently_owned_books[i].just_borrowed:
			if not currently_owned_books[i].just_exchanged:
				var exchange_player_relic = construct_book_dummy(currently_owned_books[i], "", 0)
				%ExchangePlayerBookParent.add_child(exchange_player_relic)
		
	for i in %ExchangePlayerBookParent.get_child_count():
		
		## Customize by tweaking these values
		var total_count = %ExchangePlayerBookParent.get_child_count() 
		var iterator_book = %ExchangePlayerBookParent.get_child(i)
		var initial_book = %ExchangePlayerBookParent.get_child(0)
		var columns = 5
		var x_position = 48 + (48 * (i % columns))
		var y_position = 224 + (48 * (floor(i / columns))) - (16 * floor((total_count-1) / columns))
		
		## And this code should adjust accordingly.
		iterator_book.position = Vector2(x_position, y_position)
			
		if floor(i / columns) == floor(total_count / columns):
			iterator_book.position.x = 128.0 + (48 * int(i % columns)) - (40 * ((total_count-1) % columns)) + (16 * (total_count % columns))
			
		print("Book 1: " + str(initial_book.position))
		print("Book " + str(i+1) + ": " + str(iterator_book.position))

func _on_exchange_back_button_pressed() -> void:
	_manage_covering(false)
	
	var tween = %ExchangeParent.create_tween()
	tween.tween_property(%ExchangeParent, "modulate:a", 0, 0.15)
	tween.tween_property(%ExchangeParent, "visible", false, 0.001)
	
	await get_tree().create_timer(0.15).timeout
	
	for i in %ExchangeLibraryBookParent.get_child_count():
		%ExchangeLibraryBookParent.get_child(i).remove_from_group("Library Relics to Exchange")
		%ExchangeLibraryBookParent.get_child(i).queue_free()
		
	for i in %ExchangePlayerBookParent.get_child_count():
		%ExchangePlayerBookParent.get_child(i).remove_from_group("Owned Relics to Exchange")
		%ExchangePlayerBookParent.get_child(i).queue_free()
		
	%ExchangeBackButton.disabled = false
	%ExchangeConfirmButton.disabled = false

func _on_exchange_confirm_button_pressed() -> void:
	%ExchangeBackButton.disabled = true
	%ExchangeConfirmButton.disabled = true
	
	if get_tree().get_nodes_in_group("Owned Relics to Exchange").size() \
		== get_tree().get_nodes_in_group("Library Relics to Exchange").size() \
		and get_tree().get_nodes_in_group("Owned Relics to Exchange").size() < actions_left:
		
		var timer_length = get_tree().get_nodes_in_group("Owned Relics to Exchange").size()
		
		for i in get_tree().get_nodes_in_group("Owned Relics to Exchange").size():
			
			# Get the pair of books that will be swapped
			var player_book = get_tree().get_nodes_in_group("Owned Relics to Exchange")[i]
			var library_book = get_tree().get_nodes_in_group("Library Relics to Exchange")[i]
			
			# Get their initial positions
			var initial_player_book_position = player_book.position
			var initial_library_book_position = library_book.position
			
			# Create tweens to swap their positions
			var player_book_tween = get_tree().create_tween()
			var library_book_tween = get_tree().create_tween()
			
			# Set the easing and transition type of the two tweens.
			player_book_tween.set_ease(Tween.EASE_IN_OUT)
			player_book_tween.set_trans(Tween.TRANS_QUAD)
			library_book_tween.set_ease(Tween.EASE_IN_OUT)
			library_book_tween.set_trans(Tween.TRANS_QUAD)
			
			# Swap their positions, visually
			player_book_tween.tween_property(player_book, "position", initial_library_book_position, 1)
			library_book_tween.tween_property(library_book, "position", initial_player_book_position, 1)
			
			# Remove the relic from the library, swap it for the player's relic, then add the player's relic to the library.
			var dummy_player_book = player_book.duplicate()
			dummy_player_book.remove_from_group("Owned Relics to Exchange")
			dummy_player_book.scale = Vector2(1, 1)
			dummy_player_book.player_relic_index = -1000000
			dummy_player_book.just_exchanged = true
			if dummy_player_book.purchase_price == 0:
				dummy_player_book.purchase_price = EconomyManager.determine_purchase_price(dummy_player_book)
			
			library_offerings.set(library_book.library_relic_index, dummy_player_book)
			
			print("Library Relic Index: " + str(library_book.library_relic_index))
			print("Library Swapped Index: " + str(library_offerings[library_book.library_relic_index].library_relic_index))
			
			print("Player Relic Index to Swap: " + str(player_book.player_relic_index))
			print("Emitting relic exchange...")
			GameEventHandler.exchange_relic.emit(library_book.relic_id, player_book.player_relic_index, player_book.borrowed, library_book.purchase_price)
			
			# Pause between swaps so they're syncopated.
			await get_tree().create_timer(0.1).timeout
			on_action_completed()
		
		for i in %ExchangeLibraryBookParent.get_child_count():
			%ExchangeLibraryBookParent.get_child(i).remove_from_group("Library Relics to Exchange")
		
		for i in %ExchangePlayerBookParent.get_child_count():
			%ExchangePlayerBookParent.get_child(i).remove_from_group("Owned Relics to Exchange")
	
		await get_tree().create_timer(1.1 + float(timer_length * 0.1)).timeout
		_on_exchange_back_button_pressed()
	
	else:
		print("Something went wrong with the exchange!")
		%ExchangeBackButton.disabled = false
		%ExchangeConfirmButton.disabled = false
		_on_exchange_back_button_pressed()
		return
#endregion

#region Purchase Mechanics

func _on_purchase_button_pressed() -> void:
	_manage_covering(true)
	%PurchaseConfirmButton.disabled = true
	
	var tween = %PurchaseParent.create_tween()
	tween.tween_property(%PurchaseParent, "visible", true, 0.001)
	tween.tween_property(%PurchaseParent, "modulate:a", 1, 0.15)
	
	for i in currently_borrowed_relics.size():
		if currently_borrowed_relics[i].just_borrowed == false:
			var purchase_relic = construct_book_dummy(currently_borrowed_relics[i], "", 0)
			%PurchaseBookParent.add_child(purchase_relic)
			purchase_relic.determine_relic_scale()
	
	for i in %PurchaseBookParent.get_child_count():
		
		## Customize by tweaking these values
		var total_count = %PurchaseBookParent.get_child_count() 
		var iterator_book = %PurchaseBookParent.get_child(i)
		var follower_text = FOLLOWER_TEXTBOX_SCENE.instantiate()
		
		follower_text.paired_node = iterator_book
		
		var columns = 5
		var x_position = 80 + (112 * (i % columns))
		var y_position = 224 + (72 * (floor(i / columns))) - (18 * floor(total_count / columns) )
		
		## And this code should adjust accordingly.
		iterator_book.position = Vector2(x_position, y_position)
			
		if floor(i / columns) == floor(total_count / columns):
			iterator_book.position.x = 288.0 + (112 * int(i % columns)) - (72 * ((total_count-1) % columns)) + (16 * (total_count % columns))
			
func _on_purchase_back_button_pressed() -> void:
	_manage_covering(false)
	%PurchaseBackButton.disabled = false
	
	var tween = %PurchaseParent.create_tween()
	tween.tween_property(%PurchaseParent, "modulate:a", 0, 0.15)
	tween.tween_property(%PurchaseParent, "visible", false, 0.001)
	
	await get_tree().create_timer(0.15).timeout
	
	for i in %FollowerTextParent.get_child_count():
		%FollowerTextParent.get_child(i).queue_free()
	
	for i in %PurchaseBookParent.get_child_count():
			%PurchaseBookParent.get_child(i).remove_from_group("Relics to Purchase")
			%PurchaseBookParent.get_child(i).queue_free()

func _on_purchase_confirm_button_pressed() -> void:
	%PurchaseBackButton.disabled = true
		
	for i in get_tree().get_nodes_in_group("Relics to Purchase").size():
		var purchased_relic = get_tree().get_nodes_in_group("Relics to Purchase")[i]
		GameEventHandler.exchange_relic.emit(purchased_relic.relic_id, purchased_relic.player_relic_index, false, 0)
		GameEventHandler.gold_changed.emit((-1 * purchased_relic.purchase_price))
		await get_tree().create_timer(0.1).timeout
		on_action_completed()
	
	for i in get_tree().get_nodes_in_group("Relics to Purchase").size():
		var purchased_relic = get_tree().get_nodes_in_group("Relics to Purchase")[-1]
		purchased_relic.remove_from_group("Relics to Purchase")
	
	_on_purchase_back_button_pressed()
	
#endregion
	
