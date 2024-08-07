-- Lua script of map donjons/level_01/2D_Test.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
  self:init_side_view()
  self.dungeon_info = {
    dungeon = require("scripts/menus/dungeon_maps")[1],
    floor = true
  }

sol.audio.set_music_volume(25)
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
