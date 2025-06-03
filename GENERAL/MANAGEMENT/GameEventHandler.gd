extends Node


# Combat Signals
signal update_bag_tiles()
signal update_buffered_tiles()
signal disable_tile_bag(state)
signal enemy_attack_finished()
signal tile_tooltip_requested(which)
signal tile_tooltip_hide_requested()

# Game Entity Signals
signal update_tile_graphics()
signal update_tooltip_tile_graphics()

# Enemy Signals
signal perform_attack(attack_to_perform: Array, attack_letter_tiles: Array, pivot_position: Vector2)
signal pass_turn()

# Map Signals
signal selected(room: Room)

# Scene Transition Signals
signal combat_won
signal combat_exited
signal shop_exited
signal reliquary_exited
signal rest_exited
signal random_event_exited
signal boss_exited
signal map_exited
