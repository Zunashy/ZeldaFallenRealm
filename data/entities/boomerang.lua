local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local travel_distance = 80
local travel_speed = 150

function init_traversable()
    -- Comme le caillou vole, il passe au dessus des murets et sols spéciaux
    entity:set_can_traverse_ground("low_wall", true)
    entity:set_can_traverse_ground("deep_water", true)
    entity:set_can_traverse_ground("shallow_water", true)
    entity:set_can_traverse_ground("grass", true)
    entity:set_can_traverse_ground("hole", true)
    entity:set_can_traverse_ground("prickles", true)
    entity:set_can_traverse_ground("lava", true)
end

local function coll_test(boom, other)
    if (other:get_type() == "enemy") then
        if not other:is_immobilized() then
            other:immobilize() 
        end
        entity:come_back() 
    end
end

function entity:destroy()
    if self.item then
        self.item.boomerang_out = false
    end
    self:remove()
end

-- Event called when the custom entity is initialized.
function entity:on_created()
    init_traversable()
    self:create_sprite("entities/projectile/boomerang")
    entity:add_collision_test("overlapping", coll_test)
    self:start_movement()
end

function entity:come_back()
    local hero = game:get_hero()
    local movement = sol.movement.create("target")
    movement:set_target(hero)
    movement:set_speed(travel_speed)
    movement:start(entity)
    entity:add_collision_test("overlapping", function(e, other) 
        if other:get_type() == "hero" then entity:destroy() end
    end) 
    entity.coming_back = true
end

function entity:start_movement(direction)
    local movement = sol.movement.create("straight")
    movement:set_speed(travel_speed)
    movement:set_smooth(false)
    -- Angle en radian à partir de la direction (0-3)
    movement:set_angle(math.pi / 2 * entity:get_direction())
    movement:set_max_distance(travel_distance)
    movement:start(entity)

    function movement:on_finished()
        entity:come_back()
    end
end

function entity:on_obstacle_reached(movement)
      --animation de la flèche qui tourne avant de depop
    if entity.coming_back then
        entity:destroy()
    else
        entity:come_back()
    end
end