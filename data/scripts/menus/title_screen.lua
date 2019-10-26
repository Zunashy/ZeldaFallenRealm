local title_screen = {
    background_surf = nil,
    surface = nil,
}

local vfx = require("scripts/feature/visual_effects")

title_screen.background_surf = sol.surface.create("menus/title_screen.png")
title_screen.surface = sol.surface.create(sol.video.get_quest_size())


function title_screen:on_started()
    vfx.fade_in(self.surface, 5, {255, 255, 255})
end

function title_screen:on_draw(dst_surf)
    self.background_surf:draw(self.surface)
    self.surface:draw(dst_surf)
end

return title_screen