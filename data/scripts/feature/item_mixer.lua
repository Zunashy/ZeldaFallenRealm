local current_item = ""

local game = nil

local mixer = {}

--method 1
--[[local recipes = {
    sword = {},
    rock_feather = {bomb = "rocket_jump"},
    fire_seed = {},
    bracelet = {},
    bomb = {},
}]]--

--method 2 : we generate nested maps like in method 1 from this list
local recipes_list = {
    [{"rock_feather", "bomb"}] = "mixer_rocket_jump",
    [{"fire_seed", "bomb"}] = "mixer_molotov"
}

do
    local function add_recipe(recipes, ingr_1, ingr_2, res)
        local ingr_1_map = recipes[ingr_1]
        if ingr_1_map then
            ingr_1_map[ingr_2] = res
        else 
            recipes[ingr_1] = {[ingr_2] = res}
        end
    end

    recipes = {}
    for ingrs, res in pairs(recipes_list) do
        local ingr_1, ingr_2 = unpack(ingrs)
        add_recipe(recipes, ingr_1, ingr_2, res)
        add_recipe(recipes, ingr_2, ingr_1, res)
    end
end
tprint(recipes)

function mixer.get_result(item1, item2)
    if not (recipes[item1]) then
        return false
    end

    return recipes[item1][item2]
end

local function get_recipes(item1)
    return recipes[item1] or {}
end
mixer.get_recipes = get_recipes

local function get_recipe_savegame_variable_name(item1, item2)
    return "recipe_"..item1.."_"..item2
end

local function has_recipe(item1, item2)
    return game:get_value(get_recipe_savegame_variable_name(item1, item2))
end

function mixer.obtain_recipe(item1, item2)
    local var_name = get_recipe_savegame_variable_name(item1, item2)
    game:set_value(var_name, true)
end

--maybe return an iterator ?
function mixer.get_obtained_recipes(item1)
    local res = {}
    for item2, res in pairs(get_recipes(item1)) do
        if has_recipe(item1, item2) then
            res[item2] = res
        end
    end
    return res
end

function mixer.fuse(item1, item2)
    local result = self:get_result(item1, item2)

    if not result then
        print("No such recipe : " .. item1 .. " " .. item2)
        return nil
    end

    if has_recipe(item1, item2) then
        game:set_value("item_mixer_result", result)
        local item = game:get_item(result)
        current_item = item
        return item
    else
        return false
    end
end

local function game_start(game_)
    game = game_
    local current_mixer_item_name = game:get_value("item_mixer_result")
    if current_mixer_item_name then
        current_item = game:get_item()
    end
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", game_start)

return mixer