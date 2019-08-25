-- Lua script of enemy slime_green.
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

require("enemies/movement_generic")


-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(10)
  enemy:set_damage(1)
  initialize_state(enemy, 32)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  target_hero(enemy)
end

function enemy:on_movement_changed(movement)
  -- Mise à jour de la direction du sprite en fonction de la direction du mouvement
  local direction4 = movement:get_direction4()
  sprite:set_direction(direction4)
end


