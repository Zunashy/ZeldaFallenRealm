-- Lua script of item hammer.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()
local hero = game:get_hero()
local hammer_sprite = sol.sprite.create("hero/hammer")


function item:on_created()
  self:set_savegame_variable("possession_hammer")
  self:set_assignable(true)
end 

-- FIN DE l'ITEM
local function sprite_end_callback(sprite)
  local hero = game:get_hero()
  hero:remove_sprite(sprite)  
  item:set_finished()
end

-- UTILISATION DE L'ITEM
function item:on_using()

  -- local vars
  local hero = game:get_hero()
  local direction = hero:get_direction() --0:droite 1:haut 2:gauche 3:bas
  local x,y = hero:get_position()
  local sprite = hero:create_sprite("hero/hammer")

  sprite:set_direction(direction)
  sprite.on_animation_finished = sprite_end_callback
end

function item:on_pickable_created(pickable)
end
