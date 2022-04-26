local key_icon = sol.surface.create("hud/small_key_icon.png")
local boss_key_icon = sol.surface.create("hud/boss_key_icon.png")

local keys_builder = {}

function keys_builder:new(game, config)
    local menu = {}
    local small_key = game:get_item("small_key")
    local boss_key = game:get_item("great_key")

    local current_count = small_key:get_amount()
    local has_boss_key --initialized later by a call to update_boss_key

    local counter_surface = sol.text_surface.create({
        font = "8_bit OOS",
        horizontal_alignment = "left",
        vertical_alignment = "top",
    })

    function menu:on_draw(dst_surface)
        if current_count > -1 then
            key_icon:draw(dst_surface, config.x, config.y)
            counter_surface:draw(dst_surface, config.x + 10, config.y)
        end
        if has_boss_key then
            boss_key_icon:draw(dst_surface, config.x, config.y + 8)
        end
    end

    function menu:redraw()
        counter_surface:set_text(tostring(current_count))
    end

    local function change_count(item, count)
        current_count = count
        menu:redraw()
    end

    
    small_key:register_event("on_amount_changed", change_count)

    local function update_boss_key()
        has_boss_key = boss_key:get_variant() ~= 0
    end

    boss_key:register_event("on_variant_changed", update_boss_key)

    update_boss_key()

    menu:redraw()

    return menu
end

return keys_builder