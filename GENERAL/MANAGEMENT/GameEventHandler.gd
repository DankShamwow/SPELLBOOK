extends Node

# Yes, Godot. I know that these signals are going unused. That's the entire point of this file.
@warning_ignore_start("unused_signal")

# Combat Signals
signal update_bag_tiles()
signal update_buffered_tiles()
signal disable_tile_bag(state)

# Show/Hide tooltips
signal tile_tooltip_requested(which)
signal tile_mini_tooltip_requested(which)
signal tile_tooltip_hide_requested()
signal notch_tooltip_requested(which: NotchObject)
signal notch_tooltip_hide_requested()

# Tile Signals
enum GridTileAction {PLAY, VIEW}
signal tile_hovered(which: GridTile, is_hovering: bool)
signal mini_tile_hovered(which: MiniGridTile, is_hovering: bool)
signal tile_clicked(which: GridTile, action: GridTileAction)
signal update_tooltip(which: GridTile)

# Notch Object Signals
signal notch_hovered(which: NotchObject, is_hovering: bool)
signal send_back_home(which: NotchObject)

# Status Effect signals
signal status_hovered(which: StatusEffect, is_hovering: bool)

# Game Entity Signals
# These two signals update tile graphics, one on tooltips and the other on the tile itself.
signal update_tile_graphics()
signal update_tile_tooltip_graphics(which: Enemy, affected_tile_indices: Array)

# These signals handle what happens when you click or hover an entity.
enum GameEntityAction {TARGET, VIEW}
signal entity_clicked(which: GameEntity, action: GameEntityAction)
signal entity_hovered(which: GameEntity, is_hovering: bool)

signal struck_by_word(word: String, owner: GameEntity, victim: GameEntity)

signal health_gained(amount: int, who: GameEntity, reason: String)
signal health_lost(amount: int, who: GameEntity, reason: String)
signal entity_has_died(which: GameEntity, cause: String)

signal block_gained(amount: int, who: GameEntity)
signal blocK_lost(amount: int, who: GameEntity)

# Enemy Signals
signal perform_attack(attack_to_perform: Array, attack_letter_tiles: Array, pivot_position: Vector2)
signal pass_turn()
signal enemy_attack_finished()

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
