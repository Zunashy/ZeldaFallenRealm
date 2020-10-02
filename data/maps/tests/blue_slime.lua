-- Lua script of map TestWorld.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started_()
    self:init_dungeon_features()
    self:enable_colored_blocks()

    local lever = self:get_entity("lever_test")
    local door = self:get_entity("test_door")
    function lever:on_released()
        door:open()
    end
    function lever:on_reset()
        door:close()
    end

    self:get_entity("snas").on_interaction = function(self)
        game:start_dialog("test.sans", nil, function(res)
            print(res.dialog, res.answer)
        end)
    end

end
-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
