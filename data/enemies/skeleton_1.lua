-- Lua script of enemy crab.
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
local m = sol.movement.create("straight")
local tested_dirs

local function reset_tested_dirs()
  tested_dirs = {false, false, false, false}
end
-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/skeleton_1")
  enemy:set_life(2)
  enemy:set_damage(2)

  m.on_finished = m.refresh
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.

local function dir_callback(dir)
  return not mg.test_obstacles_dir(enemy, dir)
end

function m:refresh()
  math.randomseed(os.time())  
  local dir = mg.choose_random_direction(enemy, dir_callback)
  m:set_speed(48)
  m:set_max_distance(16)
  m:set_angle(dir * math.pi / 2)
  m:start(enemy)
end 

function m:on_obstacle_reached()
  m:refresh()
end

function enemy:on_restarted()
  m:refresh()
end

function enemy:on_started()
  m:refresh()
end

function enemy:on_position_changed()
  reset_tested_dirs()
end