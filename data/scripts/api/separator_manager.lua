-- This script restores entities when there are separators in a map.
-- When taking separators prefixed by "auto_separator", the following entities are restored:
-- - Enemies prefixed by "auto_enemy".
-- - Destructibles prefixed by "auto_destructible".
-- - Blocks prefixed by "auto_block".
-- And the following entities are destroyed:
-- - Bombs.

local separator_manager = {
}
require("scripts/multi_events")

function separator_manager:manage_map(map, default)

  local enemy_places = {}
  local destructible_places = {}
  local entity_places = {}
  local block_places = {}
  local game = map:get_game()
  local destroy_on_activate = {}

  function map:get_stored_enemies()
	  return enemy_places
  end

  function separator_manager:destroy_on_separator(e)
    destroy_on_activate[#destroy_on_activate + 1] = e
  end

  -- Function called when a separator was just taken.
  local function separator_on_activated(separator)

    local hero = map:get_hero()

    -- Enemies.
    for _, enemy_place in ipairs(enemy_places) do
      local enemy = enemy_place.enemy

      -- First remove any enemy.
      if enemy:exists() then
        enemy:remove()
      end

      -- Re-create enemies in the new active region.
      if enemy:is_in_same_region(hero) and not enemy.dead and not (enemy.savegame_variable and game:get_value(enemy.savegame_variable) ) then
        local old_enemy = enemy_place.enemy
        local enemy = map:create_enemy({
          x = enemy_place.x,
          y = enemy_place.y,
          layer = enemy_place.layer,
          breed = enemy_place.breed,
          direction = enemy_place.direction,
          name = enemy_place.name,
          properties = enemy_place.properties
        })
        enemy:set_treasure(unpack(enemy_place.treasure))
        enemy:set_enabled(enemy_place.is_enabled)
        enemy.on_dead = old_enemy.on_dead
        enemy.on_dying = old_enemy.on_dying
        enemy_place.enemy = enemy
      end
    end

    -- Entities.
    local entity, old_entity
    for _, entity_place in ipairs(entity_places) do
      if entity_place.entity:exists() then
        entity_place.entity:remove()
      end

      if entity_place.entity:is_in_same_region(hero)then
        old_entity = entity_place.entity
        entity = map:create_custom_entity(entity_place)
        entity_place.entity = entity
      end
    end

    -- Blocks.
    for block in map:get_entities_property("no_reset", "1", "block", true) do
      -- Reset blocks in regions no longer visible.
      if not block:is_in_same_region(hero) then
        block:reset()
      end
    end

    for _, block_place in ipairs(block_places) do
      if not block_place.block:exists() then
        entity = map:create_block(block_place)
        entity:set_pushable(block_place.pushable)
        print(block_place.pushable)
        if block_place.colored then
          map.colored_block_manager.init(entity)
        end
      end
    end
  end

  -- Function called when a separator is being taken.
  local function separator_on_activating(separator)
    local hero = map:get_hero()
    local destructible

    -- Destructibles.
    for _, destructible_place in ipairs(destructible_places) do
      destructible = destructible_place.destructible

      if not destructible:exists() then
        -- Re-create destructibles in all regions except the active one.
        if not destructible:is_in_same_region(hero) then
          local destructible = map:create_destructible({
            x = destructible_place.x,
            y = destructible_place.y,
            layer = destructible_place.layer,
            name = destructible_place.name,
            sprite = destructible_place.sprite,
            destruction_sound = destructible_place.destruction_sound,
            weight = destructible_place.weight,
            can_be_cut = destructible_place.can_be_cut,
            can_explode = destructible_place.can_explode,
            can_regenerate = destructible_place.can_regenerate,
            damage_on_enemies = destructible_place.damage_on_enemies,
            ground = destructible_place.ground,
          })
          -- We don't recreate the treasure.
          destructible_place.destructible = destructible
        end
      end
    end
		for _, e in ipairs(destroy_on_activate) do
      e:remove()
    end

  end

  for separator in map:get_entities_property("auto_separator", "1", "separator", default) do
    separator:register_event("on_activating", separator_on_activating)
    separator:register_event("on_activated", separator_on_activated)
  end

  local function death_callback(enemy)
    enemy.dead = true
  end   

  -- Store the position and properties of enemies.
  for enemy in map:get_entities_property("no_reset", "1", "enemy", true) do
    if not enemy.no_reset then
      local x, y, layer = enemy:get_position()
      local sprite = enemy:get_sprite()
      enemy_places[#enemy_places + 1] = {
        x = x,
        y = y,
        layer = layer,
        breed = enemy:get_breed(),
        direction = sprite and sprite:get_direction() or 0,
        name = enemy:get_name(),
        treasure = { enemy:get_treasure() },
        enemy = enemy,
        is_enabled = enemy:is_enabled(),
        properties = enemy:get_properties(),
        savegame_variable = enemy.get_property("savegame_variable")
      }

      enemy:register_event("on_dead", death_callback)

      local hero = map:get_hero()
      if not enemy:is_in_same_region(hero) then
        enemy:remove()
      end
    end
  end

  local function get_destructible_sprite_name(destructible)
    local sprite = destructible:get_sprite()
    return sprite ~= nil and sprite:get_animation_set() or ""
  end

  -- Store the position and properties of destructibles.
  for destructible in map:get_entities("auto_destructible") do
    local x, y, layer = destructible:get_position()
    destructible_places[#destructible_places + 1] = {
      x = x,
      y = y,
      layer = layer,
      name = destructible:get_name(),
      treasure = { destructible:get_treasure() },
      sprite = get_destructible_sprite_name(destructible),
      destruction_sound = destructible:get_destruction_sound(),
      weight = destructible:get_weight(),
      can_be_cut = destructible:get_can_be_cut(),
      can_explode = destructible:get_can_explode(),
      can_regenerate = destructible:get_can_regenerate(),
      damage_on_enemies = destructible:get_damage_on_enemies(),
      ground = destructible:get_modified_ground(),
      destructible = destructible,
    }
  end

  for entity in map:get_entities_property("separator_reset", "1") do
    local x, y, layer = entity:get_position()
    local w, h = entity:get_size()
    local sprite = entity:get_sprite()
    entity_places[#entity_places + 1] = {
      x = x,
      y = y,
      layer = layer,
      width = w,
      height = h,
      model = entity:get_model(),
      direction = sprite and sprite:get_direction() or 0,
      name = entity:get_name(),
      sprite = sprite and sprite:get_animation_set() or "",
      entity = entity,
      enabled_at_start = entity:is_enabled(),
      properties = entity:get_properties()
    }
  end

  for block in map:get_entities_property("no_reset", "1", "block", true) do
    local x, y, layer = block:get_position()
    block_places[#block_places + 1] = {
      x = x,
      y = y,
      layer = layer,
      name = block:get_name(),
      block = block,
      pushable = block:is_pushable(),
      pullable = block:is_pullable(),
      max_moves = block:get_max_moves(),
      sprite = block:get_sprite():get_animation_set(),
      enabled_at_start = block:is_enabled(),
      properties = block:get_properties(),
      colored = block.is_colored_block
    }
  end

  map.separator_manager_enabled = true

end

return separator_manager
