-- Lua script of map donjons/level_01/RDC.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  gen.import(map, mpg, 
    "init_enemies_event_triggers", 
    "init_activate_triggers",
    "init_activatables",
    "init_detect_open"
  )
  map:init_enemies_event_triggers()
  map:init_activatables()
  map:init_activate_triggers()
  map:init_detect_open()
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
