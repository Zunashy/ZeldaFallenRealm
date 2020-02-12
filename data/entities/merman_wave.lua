-- Lua script of custom entity merman_wave.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = game:get_hero()

local function hit_hero()
  local m = sol.movement.create("straight")
  m:set_angle(3 * math.pi / 2)
  m:set_speed(240)
  m:set_max_distance(400)
  function m:on_obstacle_reached()
    m:stop()
    hero:unfreeze()
    hero:start_hurt(2)
  end
  hero:set_invincible(true)
  hero:set_blinking(true)
  hero:freeze()
  m:start(hero)
  dash:dEnd()
end



-- Event called when the custom entity is initialized.
function entity:on_created()
  local m = sol.movement.create("straight")
  m:set_angle(3 * math.pi / 2)
  m:set_speed(96)
  function m:on_obstacle_reached()
    m:stop()
    entity:remove()
  end
end

function entity:on_position_changed(x, y, layer)  
  if entity:overlaps(hero) then
    -- TODO : ajouter la gestion du bouclier quand il y en aura un
    hit_hero()
    -- TODO : Jouer un son, rajouter une animation de pierre qui se casse
    entity:remove()
  end    
end