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

end

function detect_ground()
  local hero = game:get_hero()
  local x, y = hero:get_position()
  for entity in map:get_entities_in_rectangle(x, y, 1, 1) do
    local type = entity:get_type()
    if ((type == "destructible" or type == "dynamic_tile") and entity:get_property("dig")) then
      process_entity(entity)
    end
  end
end

function process_entity(entity)
  local item, variant, savegame_var = entity:get_treasure()
  --make it spawn
end

function item:on_using()

  self:detect_ground()

  item:set_finished()
end

