local map_meta = sol.main.get_metatable("map")

function map_meta:is_ladder(x,y, layer)
    layer = layer or 0
    return self:get_ground(x, y, layer) == "ladder"
end

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

function map_meta:update_active_lights()
    local game = self:get_game()
    local hero = game:get_hero()
    local i = 0
    self.active_lights = {}
    for _, light in pairs(self.lights) do
        if light:is_in_same_region(hero) and not light.light_disabled then
            i = i + 1
            self.active_lights[i] = light
        end
    end
    game.obscurity_shader:set_uniform("n_lights", i)
end

function map_meta:add_active_light(light)
    local game = self:get_game()
    local hero = game:get_hero()
    if light:is_in_same_region(hero) and not light.light_disabled then
        local i = (#self.active_lights) + 1
        self.active_lights[i] = light
        game.obscurity_shader:set_uniform("n_lights", i)
    end
end

function map_meta:init_hero_state_callbacks()
    self.hero_state_callbacks = {}
end

function map_meta:add_hero_state_callback(callback, state, leaving, data) 
    if not self.hero_state_callbacks then
        self:init_hero_state_callbacks()
    end
    self.hero_state_callbacks[#self.hero_state_callbacks + 1] = { 
        callback = callback,
        state = state,
        leaving = leaving,
        data = data
    }
end

function map_meta:call_hero_state_callback(old, new)
    if self.hero_state_callbacks then
        for _, event in ipairs(self.hero_state_callbacks) do
            if (event.state == old and event.leaving) or (event.state == new and not event.leaving) then
                event.callback(event.data, self)
            end
        end
    end
end

function map_meta:get_entities_at_pos(x, y)
    print("Sword tapping")
    return self:get_entities_in_rectangle(x, y, 1, 1)
end

function map_meta:create_hole(entity)
    local x, y, layer = entity:get_position()
    local w, h = entity:get_size()
    local ce = entity:get_map():create_custom_entity({
        x = x,
        y = y,
        layer = layer,
        width = w,
        height = h,
        sprite = "entities/ground/dug_ground",
        direction = 0
    })
    ce:bring_to_back()
end

local function call_on_canceled(entity)
    if entity.on_cancelled then
        entity:on_cancelled()
    end
end

local function generic_start_callback(map)
    local special_tiles = require("scripts/feature/special_tiles")
    local game = map:get_game()

    for k, v in pairs(special_tiles) do
        for e in map:get_entities(k) do
            v(e, game, map)
        end
    end

    local prop
    for e in map:get_entities() do
        prop = e:get_property("min_story_state") 
        if prop and tonumber(prop) > game:get_story_state() then
            e:set_enabled(false)
        end
        prop = e:get_property("max_story_state")
        if prop and tonumber(prop) < game:get_story_state() then
            e:set_enabled(false)
        end
        prop = e:get_property("is_story_state")
        if prop and tonumber(prop) ~= game:get_story_state() then
            e:set_enabled(false)
        end
        prop = e:get_property("spawn_savegame_variable")
        if prop and game:get_value(prop) then
            e:set_enabled(true)
        end 
        prop = e:get_property("y_order")
        if prop then
            print("y order")
            e:set_drawn_in_y_order(true)
        end
    end

    sol.audio.set_music_volume(sol.audio.default_music_volume)
    if map.obscurity then map:update_active_lights() end
end

local function call_alt_on_started(map)
    if map.on_started_ then
        map:on_started_()
    end
end

map_meta:register_event("on_started", generic_start_callback)
map_meta:register_event("on_started", call_alt_on_started)