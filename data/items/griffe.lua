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

local function detect_ground()
  local hero = game:get_hero()
  local x, y = hero:get_position()
  for entity in map:get_entities_in_rectangle(x, y, 1, 1) do
    local type = entity:get_type()

    if (entity:get_property("dig") and (type == "destructible" and (not process_destructible(entity)) or type == "dynamic_tile")) then
      process_entity(entity)
    end
  end
end

local function process_entity(entity)
  local item, variant, savegame_var = entity:get_treasure()
  --make it spawn
end

local function process_destructible(entity)
  return false
end

function item:on_using()

  detect_ground()

  item:set_finished()
end

