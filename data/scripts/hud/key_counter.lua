local image_fonts = require("scripts/api/image_fonts")

local menu = {
    current_count = 0
}

local sprite = sol.sprite.create("entities/items")
sprite:set_animation("small_key")

local surface = sol.surface.create(20, 16)

local font = image_fonts:new("oracle_red", true)

local pos = {
    x = 1,
    y = 33
}

function menu:on_draw(dst_surface)
    if self.current_count > 0 then
        surface:draw(dst_surface, pos.x, pos.y)
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

local function on_game_started(game)
    sol.menu.start(menu)
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_hud_features)

return menu