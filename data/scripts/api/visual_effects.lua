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

local shaders = require("scripts/api/shader")
function vfx.shockwave(surface, x, y, speed, width, amplitude, refraction)
    local shader = shaders.shockwave
    surface:set_shader(shader)

    print(x, y, width)

    shader:set_uniform("center", {x, y})
    shader:set_uniform("width", width)
    shader:set_uniform("amplitude", amplitude)
    shader:set_uniform("refraction", refraction)
    shader.start_date = sol.main.get_elapsed_time()
    shader.speed = speed
end

return vfx