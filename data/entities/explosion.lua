local explosion = ...
local game = explosion:get_game()
local map = explosion:get_map()

local explosion_effects = {
  enemy = true,
  destructible = true,
  hero = true,
  custom_entity = true
}

local sprite

function explosion:detect_collision()
  print(explosion_effects["hero"])
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

function explosion:on_created()
  sprite = sol.sprite.create("things/explosion")
  self:detect_collision()

  function sprite:on_animation_finished()
    print('ebjhb')
  end
end

function explosion:hit_enemy(enemy)
  enemy:hurt(damage)
  local kb = sol.movement.create("straight")
  kb:set_speed(160)
  kb:set_max_distance(16)
  kb:set_angle(self:get_angle(enemy))
  kb:start(enemy)
end
explosion_effects.enemy = explosion.hit_enemy

function explosion:hit_destructible(destructible)
  destructible:on_exploded()
  destructible:remove()
end
explosion_effects.destructible = explosion.hit_destructible

function explosion:hit_custom_entity(entity)
  if entity.on_explosion then
      entity:on_explosion(self)
  end
end
explosion_effects.custom_entity = explosion.hit_custom_entity

function explosion:hit_hero(hero)
  hero:start_hurt(self, 2)
end
explosion_effects.hero = explosion.hit_hero