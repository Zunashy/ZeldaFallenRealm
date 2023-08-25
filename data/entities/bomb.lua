local bomb = ...
local game = bomb:get_game()
local map = bomb:get_map()

local sprite
local shadow_sprite

local explosion_delay
local explosion_soon

local damage = 2

local function noeffect() end

local function hit_enemy(enemy, b)
    if not enemy.explosion_immune then
        local cons = enemy:get_attack_consequence("explosion")
        if type(cons) == "function" then
          cons(enemy)
        elseif type(cons) == "number" then
            enemy:hurt(cons)
          local kb = sol.movement.create("straight")
          kb:set_speed(160)
          kb:set_max_distance(16)
          kb:set_angle(b:get_angle(enemy))
          kb:start(enemy)
        end
    end


end

local function hit_destructible(destructible)
    destructible:hit_with_explosion()
end

local function hit_custom_entity(entity, b)
    if entity.on_explosion then
        entity:on_explosion(b)
    end
end

local function hit_hero(hero)
    hero:start_hurt(bomb, 2)
end

local explosion_effects = {
    enemy = hit_enemy,
    destructible = hit_destructible,
    hero = hit_hero,
    custom_entity = hit_custom_entity
}

do 
    local item = game:get_item("bomb")
    explosion_delay = item.explosion_delay
    explosion_soon = item.explosion_soon
end

function bomb:on_created()
    self.height = 0
    shadow_sprite = self:create_sprite("entities/shadow")
    sprite = self:create_sprite("entities/projectile/bomb")
    
    shadow_sprite:set_animation("big")
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
                effect(entity, self)
            end
        end
    end
end

function bomb:BOOM()
    self.exploding = true

    self:stop_movement()

    self:set_drawn_in_y_order(false)
    self:bring_to_front()

    sprite:set_animation("explosion", function()
        bomb:remove()
    end)
    self:set_origin(sprite:get_origin())
    self:set_size(sprite:get_size())

    self:detect_collision()
end

