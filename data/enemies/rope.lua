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
local tested_dirs

local walk_speed = 48
local run_speed = 96
local walk_dist = 32

local function reset_tested_dirs()
  tested_dirs = {false, false, false, false}
end

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/rope")
  enemy:set_life(1)
  enemy:set_damage(2)
end

local function dir_callback(dir, enemy)
  return not mg.test_obstacles_dir(enemy, dir, 8)
end

local function on_obstacle_reached()
  enemy:start_walk()
end

local function on_finished()
  enemy:start_walk()
end

local function on_position_changed()
  reset_tested_dirs()
  local d = eg.lines_detect(enemy, hero, nil, true)
  if d then
    enemy:start_run(d)
  end
end

function enemy:start_walk()
  local m = sol.movement.create("straight")
  local dir = mg.choose_random_direction(enemy, dir_callback)
  m:set_speed(walk_speed)
  m:set_max_distance(walk_dist)
  m:set_angle(dir * math.pi / 2)
  m:start(enemy)
  sprite:set_animation("walking")
  sprite:set_direction(dir)

  m.on_finished = on_finished
  m.on_obstacle_reached = on_obstacle_reached
  m.on_position_changed = on_position_changed
end

function enemy:start_run(dir)
  print("run")
  local m = sol.movement.create("straight")
  m:set_speed(run_speed)
  m:set_angle(dir * math.pi / 2)
  m:start(enemy)
  sprite:set_animation("running")
  sprite:set_direction(dir)
  
  m.on_obstacle_reached = on_obstacle_reached
end

function enemy:on_restarted()
  enemy:start_walk()
end

function enemy:on_started()
  enemy:start_walk()
end