local font = gen.class()

font.name = "Font"

local loaded_fonts = {}

function font:build(name)
    if loaded_fonts[name] then
        return loaded_fonts[name]
    end
end

function font:constructor(name, load)
    if self.loaded then
        return
    end

    self.surface = sol.surface.create("fonts/"..name..".png")
    if not self.surface then
        return true
    end
    local font_w, font_h = self.surface:get_size()
    self.char_w, self.char_h = font_w / 128, font_h / 16

    if load then
        loaded_fonts[name] = self
        self.loaded = true
    end
end

function font:get_char_size()
    return self.char_w, self.char_h
end

function font:get_surface()
    return self.surface
end

function font:get_char_pos(code)
    local char_w, char_h = self:get_char_size()
    return char_w * (code % 128), char_h * math.floor(code / 128), char_w, char_h
end

function font:draw_char(code, dst_surface, x, y)
    local origin_x, origin_y, char_w, char_h = self:get_char_pos(code)
    self.surface:draw_region(origin_x, origin_y, char_w, char_h, dst_surface, x, y)
end

return font