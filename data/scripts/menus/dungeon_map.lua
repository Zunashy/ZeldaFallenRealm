local id_to_x, id_to_y
local room_position
do 
    local posConv = require("scripts/feature/positionConverter")
    id_to_x = posConv.id_to_x
    id_to_y = posConv.id_to_y
    room_position = posConv.pos_to_id_
end

local menu = {
    game = false
}

local current_dungeon = nil
local current_map = {}
local current_floor = 0

local room_w = 240
local room_h = 176

local function get_room(floor_map, x, y)
    return floor_map.rooms[room_position(x, y, floor_map.cw)]
end

local function full_rebuild_map()
    local floor, x, y
    for i, floor_map in pairs(current_map) do
        floor = current_dungeon.floors[i]
        for id, room in pairs(floor.rooms) do
            x = room.x or (id_to_x(id, floor.cw) * 8)
            y = room.y or (id_to_y(id, floor.cw) * 8)
            if room.type and room.discovered    then
                room.type:draw(floor_map, x, y)
            end
        end
    end
end

local function init_dungeon(new_dungeon)
    --OPTIMISATION : garder les surfaces au lieu de tout supprimer et refaire
    current_map = {} 
    for i, floor in pairs(new_dungeon.floors) do
        current_map[i] = sol.surface.create(GAME_W, GAME_H)
    end
    full_rebuild_map()
end

local function check_dungeon_region(map, floor_map, dungeon_id)
    local x, y = map:get_hero():get_position()

    x = math.floor(x / room_w)
    y = math.floor((y - 5) / room_h)

    local room = get_room(floor_map, x, y)

    if not room.discovered then
        x = room.x or x * 8
        y = room.y or y * 8
        room.type:draw(current_map[current_floor], x, y)
        room.discovered = true

        local game 

    end
end

local function enable_map_discovery(map, floor_map)
    for sep in map:get_entities_by_type("separator") do
        sep:register_event("on_activated", function()
            check_dungeon_region(sep:get_map(), floor_map)
        end)
    end
end

local function build_savegame_value(floors)
    local res = ""
    for floor_id, floor_map in pairs(floors) do
        res = res .. tostring(floor_id) .. ":"
        for room_id, room in pairs(floor_map.rooms) do
            if room.discovered then
                res = res .. tostring(room_id) .. ";"
            end
        end
        res = res .. "|"
    end
    return res
end

--====== METATABLE METHODS =======--

local game_meta = sol.main.get_metatable("game")
function game_meta:save_dungeon_discovery(dungeon) 
    self:set_value("map_discovery_dungeon_" .. dungeon.id, build_savegame_value(dungeon.floors))
end

function game_meta:save_current_dungeon_discovery()
    self:save_dungeon_discovery(current_dungeon)
end

game_meta:register_event("on_map_changed", function(game, map)
    local dungeon_info = map.dungeon_info
    if dungeon_info then
        if not (dungeon_info.dungeon and dungeon_info.floor) then 
            print("WARNING : Map \" "..map:get_id().."\"'s dungeon info is incomplete.")
            return nil
        end  
        local dungeon = dungeon_info.dungeon
        local floor_map = dungeon.floors[dungeon_info.floor]
        if not floor_map then 
            error("Map \" "..map:get_id().."\"'s dungeon info refers to a floor that does not exist.") 
            return nil
        end
        if not floor_map then return end

        current_floor = dungeon_info.floor

        if current_dungeon ~= dungeon then
            if current_dungeon then
                game:save_dungeon_discovery(current_dungeon)
            end
            current_dungeon = dungeon
            init_dungeon(dungeon)
        end
        
        enable_map_discovery(map, floor_map)
        check_dungeon_region(map, floor_map)
    else
        current_floor = false
    end
end)

--====== CALLBACKS =========--

function menu:on_started()
    if not (current_map and current_map[current_floor] and current_floor) then 
        sol.menu.stop(self)
        print("WARNING : Tried to start dungeon map menu on a map that is no a dungeon")
        return
    end
    self.game:set_suspended(true)
end

function menu:on_finished()
    self.game:set_suspended(false)
end

function menu:on_draw(dst_surf)
    dst_surf:clear()
    current_map[current_floor]:draw(dst_surf)
end

function menu:on_command_pressed(command)
    if command == "select" then
        sol.menu.stop(self) 
    end
end
--====== BINDING THE MENU TO THE GAME ======

local function start_menu(game)
    sol.menu.start(game, menu)
end

local function start_callback(game)
    menu.game = game 
end

--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", start_callback)

return start_menu