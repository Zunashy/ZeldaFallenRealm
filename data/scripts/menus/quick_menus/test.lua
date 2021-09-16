local qmg = require("scripts/menus/quick_menu_manager")
local testmenu = qmg:new(8)

local items = {
    "rock_feather",
    "fire_seed",
    "bracelet"
}

local function game_start(game)
    local sprite = sol.sprite.create("entities/items")
    local element
    for _, item in ipairs(items) do
        sprite:set_animation(item)
        sprite:set_direction(game:get_item(item):get_variant() - 1)
        element = testmenu:add_element(true)
        element.item = item
        sprite:draw(element.surface, 8, 13)
        --print(item, element.surface)
    end
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", game_start)

return testmenu