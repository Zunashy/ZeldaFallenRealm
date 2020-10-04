local visualizer = {
    prev_shader = nil,
    box = {},
    active = false
}

function visualizer:set_position(x, y, w, h)
    self.box = {x, y, w, h}
end

local function on_draw(shader, game)
    local camera = game:get_map():get_camera()
    local x, y, cw, ch = camera:get_bounding_box()
    local w, h

    x = (visualizer.box[1] - x) / cw
    y = (visualizer.box[2] - y) / ch
    w = visualizer.box[3] / cw
    h = visualizer.box[4] / ch

    shader:set_uniform("visu_box", {x, y, w, h})
end

function visualizer:start_visualization(map, x, y, w, h)
    self:set_position(x, y, w, h)

    local surf = map:get_camera():get_surface()
    self.prev_shader = surf:get_shader()
    self.shader = sol.shader.create("visualizer")
    self.shader.on_draw = on_draw
    surf:set_shader(self.shader)
    self.active = true
end

function visualizer:end_visualization(map)
    local surf = map:get_camera():get_surface()
    surf:set_shader(self.prev_shader)
    self.active = false
end


return visualizer