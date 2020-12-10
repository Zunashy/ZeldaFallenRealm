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
local sprite

function item:on_created()
  self:set_savegame_variable("possession_hammer")
  self:set_assignable(true)
end 



-- UTILISATION DE L'ITEM
function item:on_using()
  local x, y, layer = hero:get_position()
  x, y = gen.shift_direction4(x, y, hero:get_direction(), 16)

  item:set_finished()
end


function item:on_pickable_created(pickable)
end

function item:on_obtained()
  self:set_variant(1)
end