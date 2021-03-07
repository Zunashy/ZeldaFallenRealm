local bomb = ...
local game = bomb:get_game()
local map = bomb:get_map()

local sprite

local explosion_delay
local explosion_soon

local damage = 2

local explosion_effects = {
    enemy = true,
    destructible = true,
    hero = true,
    custom_entity = true
}

do 
    local item = game:get_item("bomb")
    explosion_delay = item.explosion_delay
    explosion_soon = item.explosion_soon
end

function bomb:on_created()
    self.height = 0
    sprite = self:create_sprite("entities/projectile/bomb")
    self.fall_speed = 0

    sol.timer.start(self, 40, function()
        bomb:update()
        return true
    end)
end

function bomb:init(time, h)
    bomb:set_height(h)

    if time > explosion_soon then
        sprite:set_animation("explosion_soon")
    else
        sol.timer.start(self, explosion_soon - time, function()
            sprite:set_animation("explosion_soon")
        end)
    end
    sol.timer.start(self, explosion_delay - time, function()
        bomb:BOOM()
    end)
end

function bomb:set_height(h)
    self.height = h
    sprite:set_xy(0, -h)
end

function bomb:update()
    if self.exploding then return end
    local new_h = self.height - self.fall_speed
    if new_h > 0 then
        self:set_height(new_h)
        self.fall_speed = self.fall_speed + 1
    else 
        self:set_height(0)
        self.fall_speed = -self.fall_speed * 0.5
        local movement = self:get_movement()
        if movement then
            movement:set_speed(movement:get_speed() * 0.5)
        end
    end
end

function bomb:detect_collision()
    local effect
    for entity in map:get_entities() do
        if entity:overlaps(self) then
            effect = explosion_effects[entity:get_type()]
            if effect then
                effect(self, entity)
            end
        end
    end
end

function bomb:BOOM()
    self.exploding = true

    self:stop_movement()

    self:set_drawn_in_y_order(false)
    self:bring_to_front()

    sprite:set_animation("explosion")
    self:set_origin(sprite:get_origin())
    self:set_size(sprite:get_size())

    self:detect_collision()
end

function bomb:hit_enemy(enemy)
    enemy:hurt(damage)
    local kb = sol.movement.create("straight")
    kb:set_speed(160)
    kb:set_max_distance(16)
    kb:set_angle(self:get_angle(enemy))
    kb:start(enemy)
end
explosion_effects.enemy = bomb.hit_enemy

function bomb:hit_destructible(destructible)
    destructible:on_exploded()
    destructible:remove()
end
explosion_effects.destructible = bomb.hit_destructible

function bomb:hit_custom_entity(entity)
    if entity.on_explosion then
        entity:on_explosion(self)
    end
end
explosion_effects.custom_entity = bomb.hit_custom_entity

function bomb:hit_hero(hero)

end
explosion_effects.hero = bomb.hit_hero