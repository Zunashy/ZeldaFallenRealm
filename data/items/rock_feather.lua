-- Lua script of item rock_feather.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()
local hero = game:get_hero()


function item:on_created()
  self:set_savegame_variable("possession_rockfeather")
  self:set_assignable(true)
end 
-- Event called when the hero is using this item.
function item:on_using()
  local hero = item:get_map():get_entity("hero")

  local x, y, dir = 0, 0, 0
  if game:is_command_pressed("right") then x = 1 end
  if game:is_command_pressed("up") then y = 1 end
  if game:is_command_pressed("left") then x = -1 end
  if game:is_command_pressed("down") then y = -1 end

  dir = gen.vector8_direction(x, y) or (hero:get_sprite():get_direction() * 2)
  hero:start_jumping_oow(dir,32)
  item:set_finished()
end

function item:on_obtained()
  self:set_variant(1)
end
