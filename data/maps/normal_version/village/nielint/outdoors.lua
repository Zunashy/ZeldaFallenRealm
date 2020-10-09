-- Lua script of map normal_version/village/nielint/outdoors.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  local story = game:get_story_state()
  local zuna = self:get_entity("zuna")
  if story < 5 then
    zuna:set_enabled(false)
  elseif 
    
  end
end

