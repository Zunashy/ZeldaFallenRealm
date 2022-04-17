local image_fonts = require("scripts/api/image_fonts")

local sprite = sol.sprite.create("entities/items")
sprite:set_animation("small_key")

local font = image_fonts:new("oracle_red", true)

local keys_builder = {}

function keys_builder:new(game, config)
    local menu = {}
    local small_key = game:get_item("small_key")

    local current_count = small_key:get_amount()

    local counter_surface = sol.surface.create(font:get_char_size())

    function menu:on_draw(dst_surface)
        if current_count > 0 then
            sprite:draw(dst_surface, config.x + 4, config.y + 13)
            counter_surface:draw(dst_surface, config.x + 10, config.y + 4)
        end
    end

    function menu:redraw()
        counter_surface:clear()
        local code = current_count + 48
        font:draw_char(code, counter_surface)
    end

    local function change_count(item, count)
        print("on_amount_changed")
        current_count = count
        menu:redraw()
    end

    
    small_key:register_event("on_amount_changed", change_count)

    menu:redraw()

    return menu
end

return keys_builder