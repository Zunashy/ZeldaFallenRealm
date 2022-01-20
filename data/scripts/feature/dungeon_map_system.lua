local room_w = 240
local room_h = 176

local room_position = require("scripts/feature/positionConverter").pos_to_id_

local function get_room(floor_map, x, y)
    return floor_map.rooms[room_position(x, y, floor_map.cw)]
end

local function check_dungeon_region(map, floor_map)
    local x, y = map:get_hero():get_position()

    x = math.floor(x / room_w)
    y = math.floor((y - 5) / room_h)

    local room = get_room(floor_map, x, y)
    room.discovered = true
end

local map_meta = sol.main.get_metatable("map")
function map_meta:enable_dungeon_map_system(dungeon, floor)
    local dmap = self.dungeon_info
    if not dmap then error("Tried to enable the dungeon map system on a map ("..self:get_id()..") that does not have dungeon info.") end
    if not (dmap.dungeon and dmap.floor) then error("Map \" "..self:get_id().."\"'s dungeon info is incomplete.") end  
    dmap = dmap.dungeon.floors[dmap.floor]
    if not dmap then error("Map \" "..self:get_id().."\"'s dungeon info refers to a floor that does not exist.") end

    for sep in self:get_entities_by_type("separator") do
        sep:register_event("on_activated", function()
            check_dungeon_region(sep:get_map(), dmap)
        end)
    end

    check_dungeon_region(self, dmap)
end