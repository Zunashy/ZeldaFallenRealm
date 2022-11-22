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

local function play_animation(hero, effect)
  hero:freeze()
  local sprite = hero:get_sprite()
  sprite:set_animation("dig")
  sol.timer.start(200 , function()
    effect()
    item:set_finished() 
  end)

  local map = hero:get_map()
  local x, y, layer = hero:get_position()
  map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 32,
    height = 32,
    direction = 0,
    sprite = "entities/ground/dig_effect"
  })
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

local function process_dynamic_tile_treasure(treasure, entity)
  local variant = entity:get_property("dig_variant") or 0
  local variable = entity:get_property("dig_variable")
  spawn_treasure(entity, treasure, variant, variable)
end

local function process_destructible(entity)
  spawn_treasure(entity, entity:get_treasure())
end

local function detect_ground()
  local hero = game:get_hero()
  local x, y = hero:get_position()
  local map = game:get_map()
  for entity in map:get_entities_in_rectangle(x, y, 1, 1) do
    local prop = entity:get_property("dig_map")
    if prop then
      play_animation(hero, function() teleport(hero, prop, entity) end)
      return
    end

    prop = entity:get_property("dig_treasure")
    if prop then
      play_animation(hero, function() process_dynamic_tile_treasure(prop, entity) end)
      return
    end

    local type = entity:get_type()
    if type == "destructible" and entity:get_property("dig") then
      play_animation(hero, function() process_destructible(entity) end)
      return 
    end
    
  end
end

function item:on_using()

  detect_ground()

  item:set_finished()
end

