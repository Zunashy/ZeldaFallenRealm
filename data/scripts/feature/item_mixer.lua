local mixer = {
    game = nil,
    current_item = nil,
}

local recipes = {
    sword = {},
    rock_feather = {bomb = "rocket_jump"},
    fire_seed = {},
    bracelet = {},
    bomb = {},
}

function mixer:get_result(item1, item2)
    if not (recipes[item1] and recipes[item2]) then
        return false
    end

    local result = recipes[item1][item2]
    if not result then
        result = recipes[item2][item1]
        if not result then
            return false
        end
    end
    return result
end

function mixer:fuse(item1, item2)
    local result = self:get_result(item1, item2)
    self.game:set_value("item_mixer_result", result)
    local item = self.game:get_item(result)
    self.current_item = item
    return item
end

local function game_start(game)
    mixer.game = game
    mixer.current_item = game:get_item(game:get_value("item_mixer_result"))
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", game_start)

return mixer