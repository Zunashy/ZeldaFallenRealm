local map = ...
local game = map:get_game()
local camera = map:get_camera()

local qm_test = require("scripts/menus/quick_menus/test")
local mixer_menu = require("scripts/menus/quick_menus/test_item_mixer")
function map:on_started_()
    self:init_dungeon_features()
    --self:enable_colored_blocks()

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
    --sol.timer.start(500, function() sol.menu.start(self, qm_test) end)
    --sol.timer.start(500, function() mixer_menu:start_from_slot(self, 1) end)
end

function map:on_opening_transition_finished()
    --print(game.shaders.obscurity)
    --camera:get_surface():set_shader(game.shaders.obscurity)
    --game.shaders.obscurity:set_uniform("obs_level", 1.3)
    --game.shaders.obscurity:set_uniform("n_lights", 1)
    --game.shaders.obscurity:set_uniform("light1", {72, 80, 40, 10})
    --print(require("scripts/feature/item_mixer").get_result("rock_feather", "bomb"))
end
