--Require me to get a table containing a surface for every item sprite, with the item name as the key.

local items_names = {
    "bomb",
    "bracelet",
    "fire_seed",
    "hammer",
    "horn",
    "ice_seed",
    "rock_feather",
    "sword",
    "mixer_molotov",
    "mixer_rocket_jump"
}

local surfaces = {}

local item_sprite = sol.sprite.create("entities/items") --global
for _, item_name in ipairs(items_names) do
    local surface = sol.surface.create(16, 16)
    item_sprite:set_animation(item_name)
    item_sprite:set_direction(0)
    item_sprite:draw(surface, 8, 13)

    surfaces[item_name] = surface
end

sol.item_sprite = item_sprite

return surfaces