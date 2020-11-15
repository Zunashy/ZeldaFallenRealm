-- Lua script of enemy blade_trap.
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

local speed = 144
local back_speed = 48

local back_movement = sol.movement.create("target")
local movement = sol.movement.create("straight")

movement.on_obstacle_reached = function() 
  enemy:back()
end
movement.on_finished = function() 
  enemy:back()
end
back_movement.on_finished = function()
  enemy.dashing = false
end

-- Event called when the enemy is initialized.
function enemy:on_created()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  self.distance = self:get_property("distance") or 160
  self:set_invincible()
  self:set_damage(2)
end

function enemy:check_hero()
  if eg.line_detect(self, hero, self.direction, math.huge, true) then
    self.dashing = true
    movement:set_speed(speed)
    movement:set_angle(self.direction * (math.pi / 2))
    movement:is_smooth(false)
    movement:set_max_distance(self.distance)
    movement:start(self)
  end
end

function enemy:back()
  back_movement:set_target(self.startPos.x, self.startPos.y)
  back_movement:set_speed(back_speed)
  back_movement:is_smooth(false)
  back_movement:start(enemy) 
end


function enemy:on_restarted()

  self.direction = self:get_sprite():get_direction()
  self.startPos = {}
  self.startPos.x, self.startPos.y = self:get_position()
  self.detect_timer = sol.timer.start(self, 10, function()
    if not self.dashing then

      enemy:check_hero()
    end
    return true
  end)
end

function enemy:on_reset()
  self.dashing = false
end
