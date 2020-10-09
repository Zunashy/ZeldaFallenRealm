-- Lua script of map normal_version/village/nielint/outdoors.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local story = game:get_story_state()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  local npc = sef:get_entity("octo_guard")
  if story < 4 then
    local x, y = octo_guard:get_position()
    octo_guard:set_position(x - 16, y)
  end
end

function map:on_opening_transition_finished(destination)
  local zuna = self:get_entity("zuna")
  if story == 6 then
    if destination:get_name() == "" then
      mg.move_straight(zuna, 2, distance, speed, callback, config)
    end
  else
    zuna:set_enabled(false)
  elseif 
end