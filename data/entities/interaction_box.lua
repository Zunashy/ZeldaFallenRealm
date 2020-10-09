-- Lua script of custom entity interaction_box.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created()
  local target = self:get_property("target")
  target = self:get_map():get_entity(target)
  if not target then
    self:remove()
    return false
  end

  self.target = target
end

function entity:on_interaction()
  if self.target.on_interaction then
    self.target:on_interaction()
    local sprite = self.target:get_sprite()
    if sprite then
      sprite:set_direction(self.target:get_direction4_to(self:get_map():get_hero()))
    end
  end
end
