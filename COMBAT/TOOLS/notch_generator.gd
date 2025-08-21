extends Control
class_name NotchGenerator

const NOTCH_OBJECT_SCENE = preload("res://TILE/NOTCHES/NotchObject.tscn")
@export var generator_notch_type: NotchObject.NotchTypes

func _ready():
	_spawn_new_child_notch()

func _spawn_new_child_notch():
	var notch_child = NOTCH_OBJECT_SCENE.instantiate()
	notch_child.notch_type = generator_notch_type
	notch_child.has_paired.connect(self._spawn_new_child_notch)
	notch_child.send_back_home.connect(self._notch_removed_cleanup)
	notch_child.position = self.position
	%NotchesParent.add_child(notch_child)

func _notch_removed_cleanup(which: NotchObject):
	which.queue_free()
	_spawn_new_child_notch()
	
