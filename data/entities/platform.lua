-- Lua script of custom entity platform.
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
local px, py, x, y, dx, dy, hx, hy = 0, 0, 0, 0, 0, 0

-- Event called when the custom entity is initialized.
function entity:on_created()
  local sprite = entity:get_sprite()
  local w, h = sprite:get_size()
  local x, y = sprite:get_origin()
  entity:set_size(w,h)
  entity:set_origin(x,y)
  entity:set_modified_ground("traversable")
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("traversable", false)
  self:set_can_traverse_ground("shallow_water", true)
  self:set_can_traverse_ground("wall", false)

  self.speed = self:get_property("speed") and tonumber(self:get_property("speed")) or 16
  self.dir = self:get_property("direction") and tonumber(self:get_property("direction")) or entity:get_sprite():get_direction() or 1
  print(self.dir)
  local m = sol.movement.create("straight")
  m:set_speed(self.speed)
  m:set_angle((math.pi / 2) * self.dir)
  m:start(self)
  
  entity:add_collision_test("overlapping", entity.collision_callback)
  entity.on_position_changed = entity.movement_callback
  px, py = entity:get_position()

  self.is_moving_platform = true
  self.initial_movement = true
end

function entity:collision_callback(other)
  
  if other:get_type() == "hero" then
    hero.is_on_nonsolid_ground = true
  end
end

local function hero_can_be_moved()
  local s = hero:get_state()
  return s ~= "falling" and s ~= "jumping" and s ~= "plunging"
end 

function entity:movement_callback()
  x, y = entity:get_position()
  dx, dy = x - px, y - py
  if entity:overlaps(hero) and hero_can_be_moved() then
    hero.is_on_nonsolid_ground = true
    if not hero:test_obstacles(dx, dy) and hero_can_be_moved() then 
      hx, hy = hero:get_position()
      hero:set_position(hx + dx, hy + dy)
    end
  end
  px, py = x, y
  
  for e in map:get_entities() do
    if entity:overlaps(e, "overlapping") and 
      not e.static and 
      not e.airborne and
      not e:test_obstacles(dx, dy) and
      e:get_type() ~= "hero" and
      e ~= entity then
  
      hx, hy = e:get_position()
      e:set_position(hx + dx, hy + dy)    
    end
  end
  
end