-- Lua script of map overworld/wind_wood/sword_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  local sensor1 = self:get_entity("message_1")
  local sensor2 = self:get_entity("message_2")

  function sensor1:on_activated()
    game:start_dialog("pnj.tree.message.1")
    sensor2:set_enabled(true)
  end

  function sensor2:on_activated()
    game:start_dialog("pnj.tree.message.2")
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
