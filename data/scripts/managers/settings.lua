local settings_manager = {} 

local default_settings = {
    window_scale = 2,
    fullscreen = false,
    sound_volume = 100,
    music_volume = 100,
    language = "fr",
    joypad_enabled = true,
    text_speed = 3
}

local dialog_box = require("scripts/menus/dialog_box")

local getters = {
    window_scale = function() return sol.video.get_scale() end,
    fullscreen = function() return sol.video.is_fullscreen() end,
    sound_volume = function() return sol.audio.get_sound_volume() end,
    music_volume = function() return sol.audio.get_music_volume() end,
    language = function() return sol.language.get_language() end,
    joypad_enabled = function() return sol.input.is_joypad_enabled() end,
    text_speed = function() return dialog_box:get_text_speed() end,
    view = function() return sol.video.is_fullscreen() or sol.video.get_scale() end
}

local setters = {
    fullscreen = function(fullscreen) sol.video.set_fullscreen(fullscreen) end,
    window_scale = function(window_scale) 
        if type(window_scale) == "number" then
            sol.video.set_scale(window_scale)
        end
    end,
    sound_volume = function(sound_volume) sol.audio.set_sound_volume(sound_volume) end,
    music_volume = function(music_volume) sol.audio.set_music_volume(music_volume) end,
    language = function(language) 
        if type(settings.language) == "string" then
            sol.language.set_language(language)
        end
    end,
    joypad_enabled =  function(joypad_enabled) sol.input.set_joypad_enabled(joypad_enabled) end,
    text_speed = function(text_speed) dialog_box:set_text_speed(text_speed) end,
    view = function(view)
        if view == true then
            sol.video.set_fullscreen()
        else
            sol.video.set_fullscreen(false)
            sol.video.set_scale(view)
        end
    end
}

function settings_manager:get(setting)
    if not getters[setting] then return false end
    return getters[setting]()
end

function settings_manager:set(setting, val)
    if not setters[setting] then return false end 
    setters[setting](val)
end

function settings_manager:write_integer(val)
    return tostring(val)
end

function settings_manager:write_boolean(val)
    return val and "true" or "false"
end

function settings_manager:write_string(val)
    return '"' .. val .. '"'
end

function settings_manager:get_all()
    local settings = {}
    settings.fullscreen = sol.video.is_fullscreen()
    settings.window_scale = sol.video.get_scale()
    settings.sound_volume = sol.audio.get_sound_volume()
    settings.music_volume = sol.audio.get_music_volume()
    settings.language = sol.language.get_language()
    settings.joypad_enabled = sol.input.is_joypad_enabled()
    settings.text_speed = dialog_box:get_text_speed()
    return settings
end

function settings_manager:apply(settings)
    sol.video.set_fullscreen(settings.fullscreen)
    if not settings.fullscreen and type(settings.window_scale) == "number" then
        sol.video.set_scale(settings.window_scale)
    end
    sol.audio.set_sound_volume(settings.sound_volume)
    sol.audio.set_music_volume(settings.music_volume)
    if type(settings.language) == "string" then
        sol.language.set_language(settings.language)
    end
    sol.input.set_joypad_enabled(settings.joypad_enabled)
    dialog_box:set_text_speed(settings.text_speed)
end    

function settings_manager:load()
    local chunk = sol.main.load_file("settings.dat", "r")
    local key, val
    local settings = {}
    for k, v in pairs(default_settings) do settings[k] = v end
    if chunk then
        --[[for line in file:lines() do
            key, val = line:xfields("=")
            key = key:rtrim()
            key = key:ltrim()
            val = loadstring("return " .. val)()
            settings[key] = val
        end]]
        local env = setmetatable({}, {__newindex = function(self, key, value)
            settings[key] = value
        end})

        setfenv(chunk, env)
        chunk()
    end
    self:apply(settings)
end

function settings_manager:save()
    local file = sol.file.open("settings.dat", "w")
    local settings = self:get_all()
    if not file then
        print(error)
        return false
    end
    for k, v in pairs(settings) do
        if type(v) == "string" then v = self:write_string(v) end
        if type(v) == "boolean" then v = self:write_boolean(v) end
        file:write(k.." = "..v.."\n")
    end
    file:close()
end
return settings_manager