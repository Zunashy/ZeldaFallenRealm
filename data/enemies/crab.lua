-- Lua script of enemy crab.
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

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(5)
  enemy:set_damage(2)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.

function enemy:refresh_movement()
 local path = {0,0,0,0,0,0,0,0}
 -- for i,v in ipairs(path) do
 --   path[i] = math.random(4)*2 - 2
 -- end
  
  for i = 1,7,2 do
    local v = (math.random(4) - 1) * 2  
    path[i],path[i+1] = v,v
  end
  movement = sol.movement.create("path")
  movement:set_path(path)
  movement:set_speed(48)
  movement:start(enemy)
  function movement:on_finished()
    enemy:refresh_movement()
  end
end 

function enemy:on_restarted()
  enemy:refresh_movement()
end
