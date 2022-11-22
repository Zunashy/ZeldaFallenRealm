-- Lua script of item griffe.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()
local hero = game:get_hero()

function item:on_started()
  self:set_savegame_variable("griffe_possession")
  self:set_assignable(true)
end

local function play_animation(hero, effect, delay)
  delay = delay or 200
  hero:freeze()
  local sprite = hero:get_sprite()
  sprite:set_animation("dig", function()
    item:set_finished()
    hero:unfreeze()
  end)
  sol.timer.start(delay , function()
    effect()
  end)

  local map = hero:get_map()
  local x, y, layer = hero:get_position()
  local e = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 32,
    height = 32,
    direction = 0,
    sprite = "entities/ground/dig_effect"
  })
  e:get_sprite():register_event("on_animation_finished", function()
    print("anim finished")
  end)

  return true
end

local function spawn_treasure(map, entity, treasure, variant, variable)
  local x, y, layer = entity:get_position()
  local p = map:create_pickable({
    x = x,
    y = y,
    layer = layer,
    treasure_name = treasure,
    treasure_variant = variant,
    treasure_savegame_variable = variable 
  })
end

local function teleport(hero,  map, entity)
  local destination = entity:get_property("dig_destination")
  local variable = entity:get_property("dig_variable")
  if variable then
    game:set_value(variable, true)
  end
  hero:teleport(map, destination, "fade")
end

local function process_dynamic_tile_treasure(map, treasure, entity)
  local variant = entity:get_property("dig_variant") or 0
  local variable = entity:get_property("dig_variable")
  spawn_treasure(map, entity, treasure, variant, variable)
  map:create_hole(entity)
  entity:remove()
end

local function process_destructible(map, entity)
  spawn_treasure(map, entity, entity:get_treasure())
  map:create_hole(entity)
  entity:remove()
end

local function detect_ground()
  local hero = game:get_hero()
  local x, y = hero:get_position()
  local map = game:get_map()
  for entity in map:get_entities_in_rectangle(x, y, 1, 1) do
    local prop = entity:get_property("dig_map")
    if prop then
      return play_animation(hero, function() teleport(hero, prop, entity) end)
    end

    prop = entity:get_property("dig_treasure")
    if prop then
      return play_animation(hero, function() process_dynamic_tile_treasure(map, prop, entity) end, 400)
    end

    local type = entity:get_type()
    if type == "destructible" and entity:get_property("dig") then
      return play_animation(hero, function() process_destructible(map, entity) end, 400)
    end
  end
  return false
end

function item:on_using()
  if not detect_ground() then
    item:set_finished()
  end
end

