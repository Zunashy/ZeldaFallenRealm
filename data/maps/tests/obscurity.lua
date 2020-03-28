-- Lua script of map TestWorld.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map.obscurity = 0.8

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started_()
    eg.add_light_entity(game:get_hero(), 30)
end
-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
