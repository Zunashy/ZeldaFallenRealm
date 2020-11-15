-- Lua script of enemy moblin_sword.
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
local sprite, sword_sprite

local movement
local movement_distance = 32
local movement_speed = 48
local movement_speed_target = 48

local detect_angle = math.pi/2
local detect_distance = 64
local detect_state

local dirCoef = gen.dirCoef
local dir_from_angle = mg.dir_from_angle

enemy.choose_random_direction = mg.choose_random_direction
enemy.test_obstacles_dir = mg.test_obstacles_dir
enemy.cone_detect = eg.cone_detect

-- Event called when the enemy is initialized.

function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  --sprite = enemy:create_sprite("enemies/moblin")
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  sword_sprite = enemy:create_sprite("enemies/moblin_sword_sword")
  sprite:set_direction(math.random(0,3))
  sword_sprite:set_direction(sprite:get_direction())
  enemy:set_life(4)
  enemy:set_damage(3)
  enemy:set_attack_consequence_sprite(sprite, "sword", 2)
  enemy:set_attack_consequence_sprite(sword_sprite, "sword", 1)
  enemy.detect_state = false
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  if self.detect_state then
    enemy:target_hero()
  else
    sol.timer.start(enemy,10,function()
      enemy:check_hero()
      return true
    end)

    enemy:movement_cycle()
  end
end

function enemy:movement_cycle()
  sprite:set_animation("idle")
  sword_sprite:set_animation("idle")
  sol.timer.start(enemy,1000,function()
    enemy:move(movement_speed, movement_distance)
    return false
  end)
end

local function movement_pos_change_callback(m)
  local dir = m:get_direction4()
  if enemy:test_obstacles(dirCoef[dir + 1].x * 8, dirCoef[dir + 1].y * 8) then
    m:stop()
    enemy:movement_cycle()
  end
end

local function movement_obstacle_callback(m)
  m:stop()
  enemy:movement_cycle()
end

function enemy:move(speed, distance)
 movement = sol.movement.create("straight")
  movement:set_speed(speed)
  local mdir = enemy.choose_random_direction(enemy,
   function(dir, enemy) return not enemy:test_obstacles_dir(dir,8) end)
  enemy:get_sprite():set_direction(mdir)
  movement:set_angle(mdir*math.pi/2)
  movement:set_max_distance(distance)  
  movement:start(enemy, enemy.movement_cycle)

  sprite:set_animation("walking")
  sprite:set_direction(mdir)
  sword_sprite:set_animation("walking")
  sword_sprite:set_direction(mdir)

  movement.on_position_changed = movement_pos_change_callback
  movement.on_obstacle_reached = movement_obstacle_callback

end

function enemy:check_hero()
  if self.detect_state == false then
    if enemy:cone_detect(hero, detect_distance, sprite:get_direction(), detect_angle, true) then
       enemy:target_hero()
    end
  end
end

local function target_move_pos_callback(m)
  sprite:set_direction(dir_from_angle(enemy:get_angle(hero)))
  sword_sprite:set_direction(sprite:get_direction())
end

function enemy:target_hero()
  enemy:stop_movement()
  self.detect_state = true   
  
  local m = sol.movement.create("target")
  sol.timer.stop_all(enemy)
  m:set_target(hero)
  m:set_speed(movement_speed_target)

  m.on_position_changed = target_move_pos_callback

  sprite:set_animation("walking")
  sword_sprite:set_animation("walking")
  m:start(enemy)
end

enemy:register_event("on_hurt", function (self, atk)
  if atk == "sword" then
    self:get_movement().on_finished = function(self)
      enemy:target_hero()
    end
  end
end)

function enemy:on_reset()
  self.detect_state = false
  sword_sprite:set_direction(sprite:get_direction())
end
