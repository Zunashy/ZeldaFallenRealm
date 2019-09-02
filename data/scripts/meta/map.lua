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

local function parse_entities_properties(map)
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
    end
end
map_meta:register_event("on_started", parse_entities_properties)
