extends Control
class_name Encounter

## EncounterType determines what sorts of procedures should be taken before, during, or after an Encounter.
enum EncounterType {COMBAT_BASIC, COMBAT_NORMAL, COMBAT_EVENT, COMBAT_ELITE, COMBAT_BOSS, \
					RANDOM_EVENT, RANDOM_MINIGAME, }

var type: EncounterType

var reward_gold := 0
var reward_notch_count := 0
var reward_relics := 0

var special_reward = null

func _ready():
	if type == EncounterType.COMBAT_BASIC or type == EncounterType.COMBAT_NORMAL \
	or type == EncounterType.COMBAT_EVENT or type == EncounterType.COMBAT_ELITE \
	or type == EncounterType.COMBAT_BOSS:
		for i in %Combatants.get_child_count():
			%Combatants.get_child(-1).reparent(self.get_parent().find_child("Combatants"))
			
	else:
		pass
