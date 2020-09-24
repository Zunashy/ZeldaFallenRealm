-- Lua script of enemy hitbox.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local function hurt_cb()
  print(self.entity)
end

-- Event called when the enemy is initialized.
function enemy:on_created()
  local prop = self:get_property("entity") or ""
  self.entity = map:get_entity(prop)
  if not self.entity then
    self:remove()
    return
  end

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  self:set_attacks_consequence(hurt_cb)
  
end


function enemy:on_restarted()

end

function enemy:on_attacking_hero()

end