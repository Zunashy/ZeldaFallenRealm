local map_meta = sol.main.get_metatable("map")

function map_meta:get_entities_property(key, value, p1, p2)
    local t, rev
    local xor = gen.xor
    if type(p1) == "string" then
        t = p1
        rev = p1
    else 
        rev = p1
        t = p2
    end    

    local base_iter = (type(t) == "string") and self:get_entities_by_type(t) or self:get_entities()
    local function iter()
        local entity
        while true do
            entity = base_iter()
            if (not entity) or xor(entity:get_property(key) == value , rev) then
                return entity
            end    
        end    
    end  
    return iter  
end

function map_meta:set_obscurity(level)
    local game = self:get_game()
    local camera = self:get_camera()
    if level > 0 then
        camera:get_surface():set_shader(game.obscurity_shader)
        game.obscurity_shader:set_uniform("obs_level", 1 / level)
    else
        camera:get_surface():set_shader(nil)
    end

end

local function generic_start_callback(map)
    local prop
    local game = map:get_game()
    for e in map:get_entities() do
        prop = e:get_property("min_story_state") 
        if prop and tonumber(prop) > game:get_story_state() then
            e:set_enabled(false)
        end
        prop = e:get_property("max_story_state")
        if prop and tonumber(prop) < game:get_story_state() then
            e:set_enabled(false)
        end
        prop = e:get_property("spawn_savegame_variable")
        if prop and game:get_value(prop) then
            e:set_enabled(true)
        end
    end
    print("volume : "..sol.audio.default_music_volume)
    sol.audio.set_music_volume(sol.audio.default_music_volume)
end

local function call_alt_on_started(map)
    if type(map.on_started_) == "function" then
        map:on_started_()
    end
end



map_meta:register_event("on_started", generic_start_callback)
map_meta:register_event("on_started", call_alt_on_started)