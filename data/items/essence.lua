-- Lua script of item essence.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_started()
  self:set_savegame_variable("essence")
  item:set_brandish_when_picked()
end

function item:on_obtained(variant)
  self:set_variant(variant)
end