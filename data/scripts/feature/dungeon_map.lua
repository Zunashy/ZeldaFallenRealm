local room_w = 160
local room_h = 128

local dungeon = gen.class()

function dungeon:constructor()
    
end

local function check_dungeon_region(separator)
    local x, y = separator:get_map():get_hero():get_position()

    x = x / room_w
    y = y / room_h

    print(x, y)
end

local map_meta = sol.main.get_metatable("map")
function map:enable_dungeon_map_system(dungeon, floor)
    for sep in map:get_entities_by_type("separator") do
        sep:register_event("on_activated", check_dungeon_region)
    end
end
