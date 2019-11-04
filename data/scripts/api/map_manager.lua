local manager = {}

manager.map = {}
for i = 1, 15 do 
    manager.map[i] = {}
    for j = 1, 15 do 
        manager.map[i][j] = 0
    end
end

--external modules
local bit = require("scripts/api/bit")

function manager:load_discovered(game)
    local mapstring = game:get_value("map_discovery")

    if mapstring then
        local i = 1
        local bitlist
        for n in mapstring:fields(";") do
            n = n + 0
            bitlist = bit.number_to_bitlist(n)
            for j = 1, 15 do
                self.map[i][j] = (bitlist[j] == 1) and 1 or 0
            end
            i = i + 1
        end
    end

end

function manager:save_discovered(game)
    local mapstring = ""
    local n

    for i = 1, 15 do
        n = bit.bitlist_to_number(self.map[i])
        mapstring = mapstring..n..";"
    end

    game:set_value("map_discovery", mapstring)
end

local function start_callback(game)
    manager:load_discovered(game)
end

local function finish_callback(game)
    manager:save_discovered(game)
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", start_callback)
game_meta:register_event("on_finished", finish_callback)

return manager