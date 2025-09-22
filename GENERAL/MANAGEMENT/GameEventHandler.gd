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
signal health_gained(amount: int, who: GameEntity)
signal health_lost(amount: int, who: GameEntity)

# Enemy Signals
signal perform_attack(attack_to_perform: Array, attack_letter_tiles: Array, pivot_position: Vector2)
signal pass_turn()

# Map Signals
signal selected(room: Room)

# Scene Transition Signals
signal combat_started
signal combat_won
signal combat_exited
signal shop_exited
signal reliquary_exited
signal rest_exited
signal random_event_exited
signal boss_exited
signal map_exited
signal reward_depleted

# Player Related Signals
signal gold_changed(amount: int)
signal relic_collected(which: Relic)
signal relic_hovered(which: Relic, is_hovering: bool)
signal player_death
signal add_relic(relic_id: int)
signal specialty_rewards_popup(reward_notch_count: int, reward_notch_uncommons: int, reward_notch_rares: int, reward_notch_specified: Array, allow_tiles: bool, draw_size: int)
