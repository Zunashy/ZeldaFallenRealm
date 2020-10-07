local vfx = {

}

local multi_events = require("scripts/multi_events")

local function effect_menus_draw(self, dst_surf)
    if self.dst_surf then

        self.surface:draw(self.dst_surf)
    else
        self.surface:draw(dst_surf)
    end
end

function vfx.fade_in(speed, color)
    local menu = {surface = nil}
    menu.surface = sol.surface.create(sol.video.get_quest_size())
    menu.surface:fill_color(color or {0, 0, 0})

    local function end_callback()
        sol.menu.stop(menu)
    end
    
    menu.on_draw = effect_menus_draw
    menu.surface:fade_out(speed, end_callback)
    sol.menu.start(sol.main, menu)
    return menu
end

function vfx.fade_out(speed, color)
    local menu = {surface = nil}
    menu.surface = sol.surface.create(sol.video.get_quest_size())
    menu.surface:fill_color(color or {0, 0, 0})

    local function end_callback()
        sol.menu.stop(menu)
    end
    
    menu.on_draw = effect_menus_draw
    menu.surface:fade_out(speed, end_callback)
    sol.menu.start(sol.main, menu)
    return menu
end

function vfx.flash(speed, color)
    local menu = {surface = nil}
    menu.surface = sol.surface.create(sol.video.get_quest_size())
    menu.surface:fill_color(color or {0, 0, 0})

    local function end_callback()
        sol.menu.stop(menu)
    end
    
    local function mid_callback()
        menu.surface:fade_out(speed / 2, end_callback)
    end

    menu.on_draw = effect_menus_draw
    menu.surface:fade_in(speed / 2, mid_callback)
    sol.menu.start(sol.main, menu)
    return menu
end

local shaders = require("scripts/api/shader")

function vfx.set_shockwave_center(shader, x, y)
    shader:set_uniform("center", {x, y})
end

function vfx.shockwave(surface, x, y, speed, width, amplitude, refraction)
    local shader = shaders.shockwave
    surface:set_shader(shader)

    vfx.set_shockwave_center(shader, x, y)
    shader:set_uniform("width", width)
    shader:set_uniform("amplitude", amplitude)
    shader:set_uniform("refraction", refraction)
    shader.start_date = sol.main.get_elapsed_time()
    shader.speed = speed
end

return vfx