-- Lua script of enemy miniboss/mr_pers.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local sword_sprite
local m
local dash

function enemy:on_created()
  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/mini_boss/1/mr_pers")
  sword_sprite = enemy:create_sprite("enemies/mini_boss/1/sword")

  m = sol.movement.create("straight")
  dash = sol.movement.create("target")

  function m:on_obstacle_reached()
    enemy:start_attack()
  end

  enemy:set_life(5)
  enemy:set_damage(2)  

  m.on_finished = self.movement_cycle
  dash.on_finished = self.sword
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.

function enemy:start_movement_cycle()
  self.attack_timer = sol.timer.start(enemy, 2000, function()
    enemy:start_attack()
  end)
  self:movement_cycle()
end

function enemy:movement_cycle()
  local dir = mg.dir_from_angle(hero:get_angle(enemy))
  m:set_speed(64)
  m:set_max_distance(16)
  m:set_angle(dir * math.pi / 2)
  m:start(enemy)

  sprite:set_direction((dir + 2) % 4)
end 

function enemy:start_attack() 
  m:stop()
  self.attack_timer:stop()  
  
  local side = mg.dir_from_angle(hero:get_angle(self))
  local x, y = hero:get_position()
  x, y = gen.shift_direction4(x, y, side, 20)

  sprite:set_direction((side + 2) % 4)
  sprite:set_animation("jump", function() self:dash(x, y) end)
  self.is_attacking = true
end

function enemy:dash(x, y)
  dash:set_target(x, y)
  dash:set_speed(128)
  sprite:set_animation("dashing")
  dash:start(self)
end

function enemy:sword()
  sprite:set_animation("sword", "sword_end")
  sol.audio.play_sound("enemies/mr_pers/sword")
  sword_sprite:set_animation("sword", function() 
    sword_sprite:set_animation("idle")
    sol.timer.start(enemy, 1000, function()
      enemy:restart()
    end)  
  end)
  sword_sprite:set_direction(sprite:get_direction())
end

function enemy:on_restarted()
  self:start_movement_cycle()
end

function enemy:on_started()
  self:start_movement_cycle()
end