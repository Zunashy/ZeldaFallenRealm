
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
    local octo = self:get_entity("octo")
    octo:register_event("on_dying", function ()
        print("dying")
    end)
    octo:register_event("on_dead", function ()
        print("dead")
    end)
end

function map:on_opening_transition_finished()

end
