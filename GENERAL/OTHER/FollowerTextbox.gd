extends Control
class_name FollowerTextbox

var paired_node: Node

func _process(_delta: float) -> void:
	self.position = (paired_node.position) + Vector2(-7.0, 24.0)

func _set_follower_text(follower_text: String):
	%Textbox.set_text(follower_text)
	
	var gold = int(follower_text)
	
	if gold < 50:
		%Icon.texture.region = Rect2(0, 0, 32, 32)
		
	elif gold >= 50 and gold < 100:
		%Icon.texture.region = Rect2(32, 0, 32, 32)
		
	elif gold >= 100 and gold < 250:
		%Icon.texture.region = Rect2(64, 0, 32, 32)
		
	else:
		%Icon.texture.region = Rect2(96, 0, 32, 32)

func _set_follower_icon():
	pass
