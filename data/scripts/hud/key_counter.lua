local image_fonts = require("scripts/api/image_fonts")

local sprite = sol.sprite.create("entities/items")
sprite:set_animation("small_key")

local font = image_fonts:new("oracle_red", true)

local keys_builder = {}

function keys_builder:new(game, config)
    local menu = {
        current_count = 0
    }

    function menu:on_draw(dst_surface)
        if self.current_count > 0 then
            sprite:draw(dst_surface, config.x, config.y)
        end
    end

    function menu:redraw()
        surface:clear()
        sprite:draw(surface, 8, 13)
        local code = self.current_count + 48
        font:draw_char(code, surface, 10, 2)
    end

    function menu:on_started()
        self:redraw()
    end

    function menu:change_count(count)
        self.current_count = count
        self:redraw()
    end

    return menu
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_hud_features)

return menu