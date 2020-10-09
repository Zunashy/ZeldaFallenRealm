-- Lua script of custom entity npc.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:on_created()
  self:set_modified_ground("wall")
end

function entity:on_interaction()
  local dialog = self:get_property("dialog")
  if dialog then
    game:start_dialog(dialog)
  end
end
