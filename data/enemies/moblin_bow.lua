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
local sprite

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
  sprite:set_direction(math.random(0,3))
  enemy:set_life(4)
  enemy:set_damage(2)
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
  sol.timer.start(enemy,1000,function()
    enemy:move(movement_speed, movement_distance)
    return false
  end)
end

local function movement_pos_change_callback(m)
  local dir = m:get_direction4()
  if enemy:test_obstacles(dirCoef[dir + 1].x * 8, dirCoef[dir + 1].y * 8) then
    print("obstacle detected")
    m:stop()
    enemy:movement_cycle()
  end
end

local function movement_obstacle_callback(m)
  print("obstacle reached")
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

  movement.on_position_changed = movement_pos_change_callback
  movement.on_obstacle_reached = movement_obstacle_callback

end


function enemy:check_hero()
  local x,y,w,h = enemy:get_bounding_box()
  local dir = sprite:get_direction()
  if (dir == 0) then x = x + w end
  if (dir == 1) then y = y - detect_distance end
  if (dir == 2) then x = x - detect_distance end
  if (dir == 3) then y = y + h end
  if (dir % 2 == 0) then w = detect_distance else h = detect_distance end


  if (hero:overlaps(x,y,w,h) and not enemy.arrow_cooldown) then
    enemy:fire_arrow(dir)
  end
end

function enemy:fire_arrow(direction)
  local properties = {}
  properties.model = "arrow"
  properties.x, properties.y, properties.layer = enemy:get_position()
  properties.width = 16
  properties.height = 16
  properties.direction = direction
  local arrow = map:create_custom_entity(properties)
  arrow:set_hurts_hero()
  enemy.arrow_cooldown = true
  sol.timer.start(enemy,3000, function() enemy.arrow_cooldown = false end)
end

function enemy:on_hurt(atk)
  if atk == "sword" then
    detect_state = true
  end
end
-----------