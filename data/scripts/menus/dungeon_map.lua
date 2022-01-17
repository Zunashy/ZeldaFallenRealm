local id_to_x, id_to_y
do 
    local posConv = require("scripts/feature/positionConverter")
    id_to_x = posConv.id_to_x
    id_to_y = posConv.id_to_y
end

local menu = {
    game = false
}

local current_dungeon = nil
local current_map = {}
local current_floor = 0
local need_redraw = true

local function full_rebuild_map()
    local floor, x, y
    for i, floor_map in pairs(current_map) do
        floor = current_dungeon.floors[i]
        for id, room in pairs(floor.rooms) do
            x = room.x or (id_to_x(id, floor.cw) * 8)
            y = room.y or (id_to_y(id, floor.cw) * 8)
            print(x, y, room.type, floor_map:get_size())
            if room.type then

                room.type:draw(floor_map, x, y)
            end
        end
    end
end

local function change_dungeon(new_dungeon)
    --OPTIMISATION : garder les surfaces au lieu de tout supprimer et refaire
    current_map = {} 
    for i, floor in pairs(new_dungeon.floors) do
        current_map[i] = sol.surface.create(GAME_W, GAME_H)
    end
    full_rebuild_map()
end

local function check_dungeon(dungeon)

    if current_dungeon == dungeon then
        --même donjon
    else
        current_dungeon = dungeon
        change_dungeon(dungeon)
    end

end

--====== CALLBACKS =========--

function menu:on_started()
    self.game:set_suspended(true)
    if not self.game then error("Attempt to start dungeon map menu while the game has not been initialized yet") end

    local map = self.game:get_map()
    local dungeon_info = map.dungeon_info

    if not dungeon_info then 
        print("The current map is not a dungeon, cannot start dungeon map menu")
        sol.menu.stop(self)
    end

    check_dungeon(dungeon_info.dungeon)
end

function menu:on_finished()
    self.game:set_suspended(false)
end

function menu:on_draw(dst_surf)
    --current_dungeon.floors[0].rooms[45].type:draw(dst_surf) FONCTIONNE
    dst_surf:clear()
    current_map[current_floor]:draw(dst_surf)
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