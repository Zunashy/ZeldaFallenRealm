local title_screen = {
    name = "Title Screen",
    background_surf = nil,
    surface = nil,
    start_surface = nil,

    view_start = false,
}

local vfx = require("scripts/api/visual_effects")

title_screen.background_surf = sol.surface.create("menus/title_screen.png")
title_screen.start_surface = sol.surface.create("menus/title_screen_start.png")
title_screen.surface = sol.surface.create(sol.video.get_quest_size())

start_surface_pos = {
    x = 36,
    y = 116
}

function title_screen:on_started()
    vfx.fade_in(self, 20, {255, 255, 255})
    sol.timer.start(self, 800, function()
        title_screen.view_cursor = not title_screen.view_cursor
        return true
    end)
end

function title_screen:on_draw(dst_surf)
    self.background_surf:draw(self.surface)
    if self.view_cursor then
        self.start_surface:draw(self.surface, start_surface_pos.x, start_surface_pos.y)
    end
    self.surface:draw(dst_surf)
end

function title_screen:on_key_pressed(key)
    sol.menu.stop(self)
end

return title_screen