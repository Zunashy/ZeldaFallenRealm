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
local random = gen.random

local function collision_callback(e, other)
  if other:get_type() == "enemy" then
    local cons = other:get_attack_consequence("fire")
    if type(cons) == "function" then
      cons(other)
    elseif type(cons) == "number" then
      other:hurt(cons)
      local kb = sol.movement.create("straight")
      kb:set_speed(160)
      kb:set_max_distance(16)
      kb:set_angle(e:get_angle(other))
      kb:start(other)
    end
  elseif other:get_type() == "hero" then 
    local state = other:get_state()
    if state == "hurt" then
      return
    end
    other:start_hurt(e.x, e.y, 1)
  end 
end

local function timer_callback()
  entity:remove()
end

function entity:on_created()
  self:create_sprite("entities/items_effects/flame")

  self:add_collision_test("overlapping", collision_callback)

  sol.timer.start(self, 2000, timer_callback)
  self.x, self.y = self:get_position()
  
  for e in map:get_entities_by_type("destructible") do
    if e:overlaps(self) and e:is_flammable() then
      e:get_sprite():set_animation("burning")
      sol.timer.start(e, 2000, function()
        e:on_destroyed()
        e:remove()
      end)
    end
  end

end
