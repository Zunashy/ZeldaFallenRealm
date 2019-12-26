-- Lua script of item rupee.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_started()

  item:set_sound_when_picked("heart")
  item:set_brandish_when_picked(false)
end

function item:on_obtained(variant, savegame_variable)
  local amounts = {1, 5, 20, 50, 100, 200}
  local amount = amounts[variant]
  if amount == nil then
    error("invalid variant '" .. variant .. "' for item 'rupee'")
  end
  self:get_game():add_money(amount)
end
