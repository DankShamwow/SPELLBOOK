extends Control
class_name Encounter

## EncounterType determines what sorts of procedures should be taken before, during, or after an Encounter.
enum EncounterType {COMBAT_BASIC, COMBAT_NORMAL, COMBAT_EVENT, COMBAT_ELITE, COMBAT_BOSS, \
					RANDOM_EVENT, RANDOM_MINIGAME, }

var reward_gold := 0
var reward_notch_count := 0
var reward_relics := 0

var special_reward = null
