vfx = {}

local multi_events = require("scripts/multi_events")
function vfx.fade_in(target, speed, color)
    local surface = sol.surface.create(sol.video.get_quest_size())
    surface:fill_color(color or {0, 0, 0})

    local function draw_surf(target, dst_surf)
        return ended or surface:draw(dst_surf)
    end

    local ended = false
    local function end_callback()
        ended = true
    end
    
    surface:fade_out(speed, end_callback)
    if not target.register_event then multi_events:enable(target) end 
    target:register_event("on_draw", draw_surf)
end

return vfx