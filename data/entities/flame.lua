-- Lua script of custom entity flame.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local separator_manager = require("scripts/api/separator_manager")
local random = gen.random

local function collision_callback(e, other)
  print(random())
  if other:get_type() == "enemy" then
    other:hurt(1)
    local kb = sol.movement.create("straight")
    kb:set_speed(128)
    kb:set_max_distance(16)
    kb:set_angle(e:get_angle(other))
    kb:start(other)
  elseif other:is_flammable and other:is_flammable() then
    other:set_animation("burning", other.remove)
  elseif other:get_type() == "hero" then 
    local state = other:get_state()
    if state == "jumping" or state == "hurt" then
      return
    end
    other:start_hurt(e.x, e.y, 1)
end

local function timer_callback()
  self:remove()
end

function entity:on_created()
  self:create_sprite("entities/flame")
  separator_manager:destroy_on_separator()

  self:add_collision_test("overlapping", collision_callback)

  sol.timer.start(self, 2000, timer_callback)
  self.x, self.y = self:get_position()
end
