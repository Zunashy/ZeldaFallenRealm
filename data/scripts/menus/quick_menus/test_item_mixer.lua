local qmg = require("scripts/menus/quick_menu_manager")
local item_surfaces = require("scripts/feature/item_surfaces")
local item_mixer = require("scripts/feature/item_mixer")

local mixer_menu = qmg() --new qmg()

local all_elements = {}

local game

function mixer_menu:set_list_from_recipes(recipes)
    self:reset_elements()
    for _, item in pairs(recipes) do
        self:add_element(all_elements[item])
    end
    tprint(recipes)
end

function mixer_menu:set_list_from_item(item1)
    print(item1)
    self:set_list_from_recipes(item_mixer.get_recipes(item1))
end

local function game_start(game_)
    for recipe, result in pairs(item_mixer.get_recipes()) do
        local item = game_:get_item(result)
        assert(item, "Mixed items list contain non existent item "..result)
        local element = {
            surface = item_surfaces[result],
            item = item
        }
        qmg.init_element(element)
        all_elements[result] = element
    end

    game = game_
end

function mixer_menu:start(map, item1, x)
    self.x = x or 8
    mixer_menu:set_list_from_item(item1)
    sol.menu.start(map, self)
end

function mixer_menu:start_from_slot(map, slot)
    local item = game:get_item_assigned(slot)
    if not item then return end

    print(item, item:get_name())

    self:start(map, item:get_name(), 8 + (slot - 1) * 26)
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", game_start)

return mixer_menu
