-- Lua script of map overworld/deku_tree.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
  local deku = self:get_entity("deku_tree")
  function deku:on_interaction()
    local story = game:get_story_state()
    if story < 3 then
      game:start_dialog("pnj.overworld.north_beach.deku_tree.part1.1", function() game:set_story_state(3) end) 
    elseif story < 4 then
      game:start_dialog("pnj.overworld.north_beach.deku_tree.part1.2")
    elseif story < 6 then
      game:start_dialog("pnj.overworld.north_beach.deku_tree.part2.1", function() 
        game:start_dialog("pnj.overworld.north_beach.deku_tree.part2.2", function()
          game:set_story_state(6) 
        end)
      end)
    else
      game:start_dialog("pnj.overworld.north_beach.deku_tree.part2.3")
    end
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
