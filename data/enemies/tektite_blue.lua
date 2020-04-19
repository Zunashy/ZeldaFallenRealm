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
local display_h = 0

local idle_time = 600
local movement_speed = 75
local movement_distance = 64

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = sol.sprite.create("enemies/" .. enemy:get_breed())
  self:create_sprite("enemies/tektite_shadow")
  self:set_size(16, 16)
  self:set_life(2)
  self:set_damage(3)
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
  display_h = parabola(dist)
  if display_h > 6 and display_h < 7 then
    enemy:set_attack_consequence("sword", "ignored")
  elseif display_h < 6 and display_h > 5 then
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
  display_h = 0
end

function enemy:on_hurt()
  display_h = 0
  sprite:set_animation("hurt")
end

function enemy:on_post_draw()
  if not sprite then return end
  local x, y = self:get_position()
  map:draw_visual(sprite, x, y - display_h)
end

function enemy:on_dying()
  sprite = nil
  self:create_sprite("enemies/" .. enemy:get_breed())
end