-- Lua script of item heart_quarter.
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
  self:set_amount_savegame_variable("heart_quarters")
  self:set_assignable(false)
  self:set_brandish_when_picked(true)
end

function item:on_obtaining()
  game:get_dialog_box().info = 4 - self:get_amount() - 1
end

function item:on_obtained()
  self:add_amount(1)
  if self:get_amount() > 3 then
    self:set_amount(0)
    game:add_max_life(4)
    game:add_life(4)
  end
end