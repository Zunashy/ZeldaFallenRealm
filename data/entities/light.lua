-- Lua script of custom entity light.
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
  if not map.lights then
    map.lights = {self}
  else
    map.lights[#map.lights + 1] = self
  end
  self.power = tonumber(self:get_property("power"))
end