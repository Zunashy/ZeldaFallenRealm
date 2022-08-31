-- Lua script of item griffe.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

function item:on_started()
  self:set_savegame_variable("griffe_possession")
  self:set_assignable(true)
end

local function process_entity(entity, hero)
  local map = entity:get_property("dig_map")
  if map and destination then
    local destination = entity:get_property("dig_destination")
    hero:teleport(map, destination, "fade")
    return
  end

  local treasure = entity:get_property("dig_treasure")
  if treasure then
    local variant = entity:get_property("dig_variant") or 0
    local variable = entity:get_property("dig_variable")
    spawn_treasure(entity, treasure, variant, variable)
  end
end

local function spawn_treasure(entity, treasure, variant, variable)
  local map = entity:get_map()
  local x, y, layer = entity:get_position()
  map:create_pickable({
    x = x,
    y = y,
    layer = layer,
    treasure_name = treasure,
    treasure_variant = variant,
    treasure_savegame_variable 
  })
end

local function process_destructible(entity, hero)
  spawn_treasure(entity, entity:get_treasure())
end

local function detect_ground()
  local hero = game:get_hero()
  local x, y = hero:get_position()
  local map = game:get_map()
  for entity in map:get_entities_in_rectangle(x, y, 1, 1) do
    local type = entity:get_type()

    --if we have a dig property : if its a dynatile we call process_entity, but on a destructible we first call process_destructible then process entity if the former returned false
    if (entity:get_property("dig") and (type == "destructible" and (not process_destructible(entity, hero)) or type == "dynamic_tile")) then
      process_entity(entity, hero)
    end
  end
end

function item:on_using()

  detect_ground()

  item:set_finished()
end

