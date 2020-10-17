-- Lua script of map overworld/wind_wood/sword_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
	self:init_activate_triggers()
	self:init_reset_separators()
	local sensor = map:get_entity("sensor_octo")
	function sensor:on_activated()
		if game:has_item("sword") then
			map:enable_entity("octo")
		end
	end
end


function map:on_opening_transition_finished()

end
