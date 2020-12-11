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
local hammer_sprite
-- local sprite

function item:on_created()
  self:set_savegame_variable("possession_hammer")
  self:set_assignable(true)
end 



-- UTILISATION DE L'ITEM
function item:on_using()

  -- local vars
  local map = game:get_map()  --utile ??
  local hero = game:get_hero()
  local direction = hero:get_direction() --0:droite 1:haut 2:gauche 3:bas
  local x,y = hero:get_position()
  local hammer_sprite = sol.sprite.create("hero/hammer") -- comment récup un sprite dans un objet de type item ?
  

  -- créer l'animation selon la direction de link à +16
  -- self:set_animation("hammer")

  -- debug
  print(hammer_sprite)

  item:set_finished()
end


function item:on_pickable_created(pickable)
end

function item:on_obtained()
  self:set_variant(1)
end