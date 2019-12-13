local visualizer = {
    prev_shader = nil,
    box = {},
    active = false
}

function visualizer:start_visualization(map, x, y, w, h)
    self.box = {x, y, w, h}

    local surf = map:get_camera():get_surface()
    self.prev_shader = surf:get_shader()
    self.shader = sol.shader.create("visualizer")
    surf:set_shader(self.shader)
    self.active = true
end

function visualizer:end_visualization(map)
    local surf = map:get_camera():get_surface()
    surf:set_shader(self.prev_shader)
    self.active = false
end

local function draw_cb(game)
    if visualizer.active then
        local camera = game:get_map():get_camera()
        local x, y, cw, ch = camera:get_bounding_box()
        local w, h

        x = (visualizer.box[1] - x) / cw
        y = (visualizer.box[2] - y) / ch
        w = visualizer.box[3] / cw
        h = visualizer.box[4] / ch

        visualizer.shader:set_uniform("visu_box", {x, y, w, h})
    end
end
sol.main.get_metatable("game"):register_event("on_draw", draw_cb)

return visualizer