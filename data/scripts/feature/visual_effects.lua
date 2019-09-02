vfx = {}


function vfx.fade_in(target, speed, color)
    local surface = sol.surface.create(sol.video.get_quest_size())
    surface:fill_color(color or {0, 0, 0})

    local function draw_surf(target, dst_surf)
        surface:draw(dst_surf)
    end

    surface:fade_out(speed)
    target:register_event("on_draw", draw_surf)
end

return vfx