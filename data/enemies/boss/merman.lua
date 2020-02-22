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
local swing_detect_distance = 48
local swing_cooldown = 800

local base_y, travel, last_x, m_direction = 0, 0, 0, -1
local hit_count = 0

enemy.blink = eg.blink
enemy.zone_detect = eg.zone_detect

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

function enemy:start_movement(direction)
  --note : direction is 0 (right) or 1 (left)

  if m_direction == -1 then
    local _, y = self:get_position()
    base_y = y
    travel = 0
  end

  local m = sol.movement.create("straight")
  m:set_speed(mov_speed)
  m:set_angle(math.pi * direction)
  m_direction = direction
  m.on_obstacle_reached = base_movement_obstacle_cb
  m.on_position_changed = wave
  m:start(self)
end

local function hurt_cb()
  enemy:set_invincible()
  enemy:blink(100, 500, function()
    enemy:set_attacks_consequence(hurt_cb)
  end)
  enemy:remove_life(1)
end

local function swing_frame_cb(s, frame)
  if frame == 3 then
    local properties = {}
    properties.model = "merman_wave"
    properties.x, properties.y, properties.layer = enemy:get_position()
    properties.y = properties.y + 32
    properties.width = 16
    properties.height = 16
    properties.direction = 0
    local arrow = map:create_custom_entity(properties)
  end
end

function enemy:swing()
  local m = self:get_movement()
  if m then
    m:stop()
  end
  self:set_attacks_consequence("protected")
  sprite:set_animation("swing_load", function()
    trident_sprite:set_animation("swing")
    self:set_attacks_consequence(hurt_cb)
    hit_count = hit_count + 1
    if hit_count > 2 then
      sprite.on_frame_changed = frame_cb
      hit_count = 0
    else
      sprite.on_frame_changed = nil
    end
    sprite:set_animation("swing", function()
      sprite:set_animation("walking")
      trident_sprite:set_animation("walking")
      enemy:start_movement(m_direction, true)
      sol.timer.start(enemy, swing_cooldown, function () enemy:start_swing_detect() end)
    end)
  end)
  trident_sprite:set_animation("swing_load")
end

function enemy:check_hero()
  return self:zone_detect(hero, swing_detect_distance, false)
end

function enemy:start_swing_detect()
  self.swing_detect_timer = sol.timer.start(self,4,function()
    if enemy:check_hero() then
      enemy:swing()
      self.swing_detect_timer = nil
      return false
    end
    return true
  end)
end

function enemy:reset_state()
  if self.swing_detect_timer then
    self.swing_detect_timer:stop()
    self.swing_detect_timer = nil
  end
end

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  trident_sprite = enemy:create_sprite("enemies/boss/merman_trident")
  enemy:set_life(6)
  enemy:set_damage(1)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_attacks_consequence(hurt_cb)
  wave_period = wave_period / math.pi

end

function enemy:on_restarted()
  self:set_visible(true)
  self:start_movement(0)
  self:start_swing_detect()
end
