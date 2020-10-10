
local map = ...
local game = map:get_game()


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
        self:exclamation(function()
            print("oui")
        end)
    end

end

function map:on_opening_transition_finished()
    mg.move_straight(map:get_entity("snas"), 3, nil , 64, function()
        print("oui")
    end, {stop_on_obstacle = true})
end
