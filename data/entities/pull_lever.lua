-- Lua script of custom entity pull_lever.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()

local pull_speed = 32
local reset_speed = 16

-- Event called when the custom entity is initialized.

local function create_rod_part(self, x, y, layer, sprite, index)
  local e = self:get_map():create_custom_entity({
    direction = 0,
    layer = layer,
    x = x,
    y = y - (index * 16),
    sprite = sprite,
    enabled_at_start = index == 1,
    width = 8,
    height = 16
  })
  e:get_sprite():set_animation("pull")
  e:set_modified_ground("wall")
  e:set_origin(4, 13)
  self.rod_parts[index] = e
end

function entity:on_created()
  self.rod_parts = {}

  local prop = self:get_property("distance")
  self.distance = prop and tonumber(prop) or 64
  self:set_modified_ground("wall")

  local x, y, layer = self:get_position()
  local sprite = self:get_sprite():get_animation_set()
  local i = 1
  print( self.distance)
  while (i - 2) * 16 < self.distance do
    create_rod_part(self, x, y, layer, sprite, i)
    i = i + 1
  end

  self.og_y = y
  self.state = 0 --0 = idle | 1 = pulling | 2 = reset
end

function entity:on_position_changed(x, y)
  for i, e in ipairs(self.rod_parts) do
    y = y - 16
    e:set_position(x, y)
    if y > self.og_y - 31 then
      e:set_enabled(true)
    else
      e:set_enabled(false)
    end
  end

end

local function start_movement(target)
  local m = sol.movement.create("straight")
  m:set_angle(math.pi * 1.5)
  m:set_speed(pull_speed)
  m:start(target)
  return m
end

local function pull_end_callback(self)
  entity:release()
  local state = hero:get_state_object()
  if state then
    state:stop()
  end
end

function entity:on_hero_state_pulling()
  if self:overlaps(hero, "facing") and hero:get_direction() == 1 then
    sol.timer.start(self, 250, function() 
      if hero:get_state() == "pulling" and entity.state == 0 then
        entity.state = 1
        
        local x, y = hero:get_position()
        local state = hero:start_pull_lever()
        state.lever = entity
        local m = start_movement(hero)
        start_movement(self)

        m:set_max_distance(entity.distance)
        m.on_obstacle_reached = pull_end_callback
        m.on_finished = pull_end_callback
      end
    end)
  end
end

local function reset_end_callback(self)
  entity.state = 0
  entity:on_reset()
  self:stop()
end

function entity:release()
  local m = self:get_movement()
  if m then
    m:stop()
  end
  local x = self:get_position()
  m = sol.movement.create("target")
  m:set_target(x, self.og_y)
  m:set_speed(reset_speed)
  m:set_ignore_obstacles(true)
  m:start(self)
  m.on_finished = reset_end_callback
  self.state = 2
  self:on_released()
end

function entity:on_released()
  print("release")
end

function entity:on_reset()
  print("reset")
end