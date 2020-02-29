local language_manager = {}

language_manager.get_language = sol.language.get_language

function language_manager:file_path(path, ext)
    return path .. "_" .. self.get_language() .. (ext or "")
end

function language_manager:get_file_path(path)
    path = self:file_path(path)
    return sol.file.exists(path) and path 
end

function language_manager:load_image(path)
    local path = self:file_path(path, ".png")
    local img = sol.surface.create(path)
    if not img then error("Can't find image "..path) end
    return img
end

return language_manager