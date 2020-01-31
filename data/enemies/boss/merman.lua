-- Lua script of enemy boss/merman.
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
local sprite, trident_sprite
local movement

local mov_speed = 64
local wave_amp, wave_period = 16, 32

local base_y, travel, last_x, m_direction = 0, 0, 0

local function base_movement_obstacle_cb(mov)
  mov:stop()
  local x = enemy:get_position()
  travel = travel + (math.abs(last_x - x))
  last_x = x
  enemy:start_movement(1 - m_direction, true)
end

local function wave()
  local x, y = enemy:get_position()
  travel = travel + (math.abs(last_x - x))
  y = math.sin(travel / wave_period) * wave_amp
  enemy:set_position(x, base_y + y)
  last_x = x
end

function enemy:start_movement(direction, bounce)
  --note : direction is 0 (right) or 1 (left)
  local m = sol.movement.create("straight")
  m:set_speed(mov_speed)
  m:set_angle(math.pi * direction)
  m_direction = direction
  m.on_obstacle_reached = base_movement_obstacle_cb
  m.on_position_changed = wave
  if not bounce then
    local _, y = self:get_position()
    base_y = y
    travel = 0
  end
  m:start(self)
end

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  trident_sprite = enemy:create_sprite("enemies/boss/merman_trident")
  enemy:set_life(1)
  enemy:set_damage(1)
  wave_period = wave_period / math.pi
end

function enemy:swing()
  local m = self:get_movement()
  if m then
    m:stop()
  end
  sprite:set_animation("swing_load", function()
    sprite:set_animation("swing", function()
      sprite:set_animation("walking")
      enemy:start_movement(m_direction, true)
    end)
  end)
  trident_sprite:set_animation("swing_load", "swing")
end

function enemy:on_restarted()
  self:start_movement(0)
  sol.timer.start(self, 1000, function()
    enemy:swing()
  end)
end
