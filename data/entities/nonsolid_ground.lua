-- Lua script of custom entity nonsolid_ground.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local hero = game:get_hero()

-- Event called when the custom entity is initialized.
function entity:on_created()
  if self:get_property("find_solid_ground") then
    self.find_solid_ground = true
  end

  self:add_collision_test("overlapping", function(_, e)
    if e == game:get_hero() then
      e.is_on_nonsolid_ground = true
    end
  end)
end
