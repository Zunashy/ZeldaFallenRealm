-- Lua script of map Donjon1/RDC.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function map:on_started_()
  self.dungeon_info = {
    dungeon = require("scripts/menus/dungeon_maps")[1],
    floor = 0
  }
  self:init_dungeon_features()
  print("MAP CALLBACK")
sol.audio.set_music_volume(25)
end
function map:on_opening_transition_finished()

end

function map:tip_blue_slime()
  game:start_dialog("other.tip_blue_slime")
end
