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
  self.turn = (not self:get_property("no_turn")) and self:get_sprite() ~= nil
end

function entity:on_interaction()
  local dialog = self:get_property("dialog")
  if dialog then
    game:start_dialog(dialog)
  end
  if self.turn and self:get_sprite():get_num_directions() > 3 then
    self:get_sprite():set_direction(self:get_direction4_to(map:get_hero()))
  end
end
