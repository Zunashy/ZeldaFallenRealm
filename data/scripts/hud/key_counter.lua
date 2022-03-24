local image_fonts = require("scripts/api/image_fonts")

local sprite = sol.sprite.create("entities/items")
sprite:set_animation("small_key")

local font = image_fonts:new("oracle_red", true)

local keys_builder = {}

function keys_builder:new(game, config)
    local menu = {
        current_count = 9
    }

    local counter_surface = sol.surface.create(font:get_char_size())
    counter_surface:fill_color({255, 255, 255})

    function menu:on_draw(dst_surface)
        if self.current_count > 0 then
            sprite:draw(dst_surface, config.x + 4, config.y + 13)
            counter_surface:draw(dst_surface, config.x + 10, config.y + 4)
        end
    end

    function menu:redraw()
        local code = self.current_count + 48
        font:draw_char(code, counter_surface)
    end

    function menu:change_count(count)
        self.current_count = count
        self:redraw()
    end

    menu:redraw()

    return menu
end

return keys_builder