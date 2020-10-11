-- Lua script of enemy tektite_red.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local idle_time = 800
local movement_speed = 60
local movement_distance = 64

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  self:create_sprite("enemies/tektite_shadow")
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_life(2)
  self:set_damage(3)

end

function enemy:set_h(h)
  self.display_h = h
  sprite:set_xy(0, -h)
end

local function parabola(x)
  return -(1/86) * ((x - 32) ^ 2) + 12
end

local function movement_end_callback()
  enemy:restart()
end

local function movement_obstacle_callback(m)
  m:stop()
end

local function get_traveled_dist(m)
  return (sol.main.get_elapsed_time() - m.start_time) * movement_speed / 1000
end

local function update_pos_timer()
  local dist = get_traveled_dist(movement)
  if dist > movement_distance then
    enemy:restart()
    return nil
  end
  enemy:set_h(parabola(dist))
  if enemy.display_h > 6 and enemy.display_h < 7 then
    enemy:set_attack_consequence("sword", "ignored")
  elseif enemy.display_h < 6 and enemy.display_h > 5 then
    enemy:set_attack_consequence("sword", 1)
  end
  return true
end

local function idle_timer_callback()
  sprite:set_animation("jumping")
  movement = sol.movement.create("straight")
  movement:set_angle(enemy:get_angle(hero))
  movement:set_max_distance(movement_distance)
  movement:set_speed(movement_speed)
  movement:set_smooth(false)
  movement.on_finished = movement_end_callback
  movement.on_obstacle_reached = movement_obstacle_callback
  sol.timer.start(enemy, 16, update_pos_timer)
  movement:start(enemy)
  movement.start_time = sol.main.get_elapsed_time()
end

function enemy:on_restarted()
  sprite:set_animation("walking")
  sol.timer.start(self, idle_time, idle_timer_callback)
  enemy:set_attack_consequence("sword", 1)
  self:set_h(0)
end


enemy:register_event("on_hurt", function (self)
  self:set_h(0)
  sprite:set_animation("hurt")
end)
