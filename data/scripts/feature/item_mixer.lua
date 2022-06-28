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

--method 2 : written like this, more readable, but we immediately convert it to nested tables like in method 1
local recipes = {
    [{"rock_feather", "bomb"}] = "rocket_jump"    
}

do
    local recipes_ = recipes
    recipes = {}
    for ingrs, res in pairs(recipes_) do
        local ingr_1, ingr_2 = unpack(ingrs)
        if ingr_1 > ingr_2 then
            ingr_1, ingr_2 = ingr_2, ingr_1
        end

        local first_ingr_map = recipes[ingr_1]
        if first_ingr_map then
            first_ingr_map[ingr_2] = res
        else 
            recipes[ingr_1] = {[ingr_2] = res}
        end
    end
end
tprint(recipes)

function mixer.get_result(item1, item2)
    if item1 > item2 then
        item1, item2 = item2, item1
    end 

    if not (recipes[item1]) then
        return false
    end

    return recipes[item1][item2]
end

function get_recipe_savegame_variable_name(item1, item2)
    return "recipe_"..item1.."_"..item2
end

function has_recipe(item1, item2)
    return game:get_value(get_recipe_savegame_variable_name(item1, item2))
end

function mixer.obtain_recipe(item1, item2)
    local var_name = get_recipe_savegame_variable_name(item1, item2)
    game:set_value(var_name, true)
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