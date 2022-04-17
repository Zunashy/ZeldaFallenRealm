--Called on each dynamic tile with a nime like poisoned_water_* on map load. 
local function poisoned_water(entity, game, map)
    local count = 0
    local hero = map:get_hero()
    local damage_ticks = 8
    local count = 0

    sol.timer.start(entity, 50, function()
        if entity:overlaps(hero, "origin") then
            hero:get_sprite():set_shader(game.shaders.poison)
            count = count + 1
            if count == damage_ticks then
                count = 0
                game:remove_life(1)
            end
        else
            hero:get_sprite():set_shader(nil)
            count = 0
        end
        return true
    end)
end

return {
    poisoned_water_ = poisoned_water
}